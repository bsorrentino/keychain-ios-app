//
//  UIPopupController.swift
//  PasswordWallet
//
//  Created by Bartolomeo Sorrentino on 16/04/15.
//  Copyright (c) 2015 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


class AddEmailPopupController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var txtMail: UITextField!
    
    private var _isOpen = false
    private var _originalFrame:CGRect?
    
    var isOpen:Bool {
        get { return _isOpen }
    }
    
    var onClose: (( _ url:String? ) -> Void)?
    
    class func createPopup() -> AddEmailPopupController {
        
        return  AddEmailPopupController( nibName: "AddEmailPopupController", bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize( width:0.0, height:0.0)
        
        _originalFrame = self.view.frame
        
        #if __KEYBOARD
            
        _inputAccessoryView.responders = [
            txtProtocol,
            txtHost,
            txtPort,
            txtPath
        ]
        #endif
    }
    
  
    func showInView(aView: UIView!)
    {
        guard !self._isOpen else {
            return
        }
        aView.addSubview(self.view)
        
        var f = self.view.frame
        f.size.width = aView.frame.size.width
        
        //self.view.frame =  aView.frame
        self.view.frame =  f
        self.showAnimate()

        txtMail.text = ""
        
    }
    
    private func showAnimate()
    {
        _isOpen = true
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
        
        #if __KEYBOARD
        registerForKeyboardNotifications()
        #endif
    }
    
    @IBAction func removeAnimate()
    {
        guard self._isOpen else {
            return
        }
        
        #if __KEYBOARD
        unregisterForKeyboardNotifications()
        #endif
        
        UIView.animate(withDuration: 0.25, animations: {
            //self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                    self._isOpen = false
                }
        });
    }
    
    
    @IBAction func closePopup(sender: AnyObject? ) {
        guard self._isOpen else {
            return
        }
        
        self.removeAnimate()
        if let handler = self.onClose  {
            handler( txtMail.text )
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // called when 'return' key
    
        textField.resignFirstResponder()
        
        return true
    }

    // MARK: - Keyboard Management
   
    #if __KEYBOARD
    
    private var _inputAccessoryView = DevelopSettingsPopupAccessoryView()
    
    override var inputAccessoryView: UIView {
        return _inputAccessoryView
    }
    
    
    func registerForKeyboardNotifications()
    {
        NotificationCenter.defaultCenter().addObserver(self,
                                                         selector:#selector(AddEmailPopupController.keyboardDidShow(_:)),
                                                         name:UIKeyboardDidChangeFrameNotification,
                                                         object:nil)
        NotificationCenter.defaultCenter().addObserver(self,
                                                         selector:#selector(AddEmailPopupController.keyboardWillHide(_:)),
                                                         name:UIKeyboardWillHideNotification,
                                                         object:nil)
        
        
    }
    func unregisterForKeyboardNotifications()
    {
        NotificationCenter.defaultCenter().removeObserver(self,
                                                            name:UIKeyboardDidChangeFrameNotification,
                                                            object:nil)
        NotificationCenter.defaultCenter().removeObserver(self,
                                                            name:UIKeyboardWillHideNotification,
                                                            object:nil)
    }
    
    func keyboardDidShow( notification:NSNotification ) {
        
        let info = notification.userInfo
        
        //let o = info?[ UIKeyboardFrameBeginUserInfoKey ] as? NSValue
        let o = info?[ UIKeyboardFrameEndUserInfoKey ] as? NSValue
        
        if let kbRect = o?.CGRectValue {
            
            let kbRectConverted = self.view.convertRect(kbRect, toView:nil)
            
            print( "keyboard h \(kbRectConverted.height) y \(kbRectConverted.origin.y)")
            
            let result = _inputAccessoryView.activeResponder()
            
            if let activeField = result.responder as? UIView {
                
                let fieldRect = activeField.convertRect(activeField.bounds, toView: self.view)
                
                var frame = self.view.frame ; frame.size.height -= kbRectConverted.size.height + frame.origin.y
                print( "origin \(activeField.frame):\(fieldRect) - rect \(frame)")
                
                
                if( !CGRectContainsPoint(frame,fieldRect.origin) ) {
                    
                    let distance = fieldRect.origin.y - frame.size.height + fieldRect.size.height
                    print("is not contained \(distance)")
                    
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        
                        var newFrame = self.view.frame;
                        
                        newFrame.origin.y -= distance
                        
                        self.view.frame = newFrame
                    })
                    
                }
                
                
            }
            
        }
    }
    
    func keyboardWillHide( notification:NSNotification ) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            
            if let frame = self._originalFrame {
                self.view.frame = frame
            }
        })
    }

    #endif
    
}


// MARK: - Keyboard Accessory View


#if __KEYBOARD
    
class AddEmailPopupAccessoryView : UIView {
    
    var m_toolbar:UIToolbar = UIToolbar();
    
    private var _index = -1
    
    var responders:Array<UIResponder>?
    
    var onDone: (() -> Void)?
    
    init() {
        super.init(frame: CGRectZero)
        
        
        m_toolbar.autoresizingMask = .FlexibleWidth

        let l_prev =
        UIBarButtonItem( title:" < ", style:.Plain, target:self, action:#selector(DevelopSettingsPopupAccessoryView.prev))
        let l_next =
        UIBarButtonItem( title:" > ", style:.Plain, target:self, action:#selector(DevelopSettingsPopupAccessoryView.next))

        let l_space =
            UIBarButtonItem( barButtonSystemItem:.FlexibleSpace, target:nil, action:nil)
        let l_doneButton = UIBarButtonItem( barButtonSystemItem:.Done, target:self, action:#selector(DevelopSettingsPopupAccessoryView.done))
        
        m_toolbar.items = [ l_prev, l_next, l_space, l_doneButton ];
        
        self.addSubview(m_toolbar);
        
        let sizeFit = m_toolbar.sizeThatFits(CGSizeZero)
        
        self.frame = CGRect(origin:CGPointZero, size:sizeFit )
        m_toolbar.frame = self.frame
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    func activeResponder() -> (index:Int,responder:UIResponder?) {
        
        if let rr = responders  {
            
            for (index,r) in rr.enumerate()  {
                
                if r.isFirstResponder() {
                    return (index, r)
                }
            }
        }
        
        return (-1, nil)
        
    }
    
    func done()
    {
        if let f = onDone  {
            f()
        }
        
        if let r = activeResponder().responder {
            r.resignFirstResponder()
        }
        
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder),
            to:nil, from:nil, forEvent:nil);
    }
    
    func prev()
    {
        let result = activeResponder()
        
        if let r = result.responder {
            
            if( result.index > 0 ) {
                
                r.resignFirstResponder()
                
                if let rr = responders {
                
                    rr[result.index - 1].becomeFirstResponder()
                
                }
            }
        }
    }

    func next()
    {
        if let rr = responders {

            let result = activeResponder()
        
            if let r = result.responder {
            
                if( result.index < rr.count - 1 ) {
                
                    r.resignFirstResponder()
                
                    rr[result.index + 1].becomeFirstResponder()
                    
                }
            }
        }
    }
    
}
#endif
