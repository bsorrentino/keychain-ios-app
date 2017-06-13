//
//  PushLinkPreview.swift
//  KeyChain
//
//  Created by softphone on 09/06/2017.
//  Copyright © 2017 SOFTPHONE. All rights reserved.
//

import Foundation
import UIKit
import SwiftLinkPreview
import ImageSlideshow

extension String: Error {}

class OverlayView : UIView  {
    
    public var cancelBlock:(() -> Void)?
    
    @IBAction func onCancel(_ sender: Any) {
        if let cancelBlock = cancelBlock {
                cancelBlock()
        }
    }
}


class PushLinkPreviewController : UIViewController, UITextFieldDelegate {
    
    var cell : PushLinkPreviewCell?
    var slp : SwiftLinkPreview?
    
    var delegate : BaseDataEntryCellDelegate?
    
    @IBOutlet weak var textURL: UITextField!
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelCanonicalUrl: UILabel!
    
    @IBOutlet var overlayView : OverlayView?
    @IBOutlet weak var itemSave: UIBarButtonItem!

    @IBOutlet weak var buttonPreview: UIButton!
    
    public var url:String? {
        get {
            return textURL?.text
        }
        set {
            
            if( newValue != textURL?.text ) {
                resetUI()
                validateInput(text: newValue)
            }
            else {
                validateInput(text: nil) // invalidate input
            }
            textURL?.text = newValue
        }
    }
    private weak var currentTask:Cancellable?
    
    private func cancelRequest() {
        currentTask?.cancel()
        self.overlayView?.removeFromSuperview()

    }
    private func completeRequest() {
        if textURL.isFirstResponder {
            textURL.resignFirstResponder()
        }
        self.overlayView?.removeFromSuperview()
        
    }
    
    private func resetUI() {
        labelTitle?.text = ""
        labelDescription?.text = ""
        labelCanonicalUrl?.text = ""
        imageSlideshow.setImageInputs([])
        
    }
    
    private func validateInput( text:String?) {
        var url:URL?
        
        if let text = text {
            url = slp?.extractURL(text: text)
        }
        
        itemSave.isEnabled = (url != nil )
        buttonPreview.isEnabled = (url != nil )
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slp = SwiftLinkPreview()
        imageSlideshow.slideshowInterval = 5.0
        
        textURL.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        // Add Save Button
        self.navigationItem.rightBarButtonItem = itemSave
 
        resetUI()
    }

    @IBAction func save(_ sender: Any) {
        
        cancelRequest()

        if let delegate = self.delegate {
            delegate.postEndEditingNotification()
        }
        
        if textURL.isFirstResponder {
            textURL.resignFirstResponder()
        }

        self.navigationController?.popViewController(animated: true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(textField: UITextField){
        
        validateInput(text: textField.text )
        
    }
    
    @IBAction func preview(){
    
        
        overlayView?.frame = self.view.frame
        view.addSubview(overlayView!)
        
    
        self.currentTask = slp?.preview(
            textURL.text!,
            onSuccess: { result in
                self.completeRequest()
                
                if let title = result[.title] as? String {
                    self.labelTitle.text = title;
                }
                if let description = result[.description] as? String {
                    self.labelDescription.text = description;
                }
                if let canonicalUrl = result[.canonicalUrl] as? String {
                    self.labelCanonicalUrl.text = canonicalUrl;
                }
                if let images = result[.images] as? [String] {
                    
                    if let inputImages = try? images.flatMap({ (urlString:String) -> InputSource in
                        
                        guard let url = URL(string: urlString) else {
                            throw "url is null!"
                        }
                        guard let data = try? Data( contentsOf: url) else {
                            throw "data cannot be loaded from \(url)"
                        }
                        guard let image = UIImage(data : data ) else {
                            throw "cannot create image from \(url)"
                        }
                        return ImageSource( image: image )
                    })
                    {
                        self.imageSlideshow.setImageInputs(inputImages)
                    }
                }
        
        }, onError: { error in
           
            self.completeRequest()

            print( "\(error)")
        })
        
        overlayView?.cancelBlock = { [weak self] () in
            self?.cancelRequest()
        }

    }
}

@objc
class PushLinkPreviewCell : PushControllerDataEntryCell {
   
    @IBOutlet /*weak*/ var pushViewController: PushLinkPreviewController!

    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var textValue: UITextField!
    @IBOutlet weak var labelValueLeading: NSLayoutConstraint!
    
    override var textLabel: UILabel? {
        return labelValue
    }
    
    override func updateConstraints() {
        let frame = labelValue.frame
        
        labelValueLeading.constant = frame.origin.x

        super.updateConstraints()
    }

    override func prepare(toAppear controller: UIXMLFormViewController, datakey key: String, cellData: [AnyHashable : Any]) {
        
        super.prepare(toAppear: controller, datakey: key, cellData: cellData)
        
        if let placeholder = cellData["placeholder"] as? String  {
            
            textValue?.placeholder = placeholder
        }
    }

    override func setControlValue(_ value: Any) {
        
        guard let value = value as? String else {
            textValue?.text = ""
            return
        }
                
        textValue?.text = value
    }
    
    override func getControlValue() -> Any {
        
        return textValue?.text ?? ""
        
    }
    
    override func viewController(_ cellData: [AnyHashable : Any]) -> UIViewController? {
        
        pushViewController.delegate = self
        
        pushViewController.url = getControlValue() as? String
        
        return pushViewController
        
    }
    
    // MARK: BaseDataEntryCellDelegate
    
    override func postEndEditingNotification() {
        
        textValue?.text = pushViewController.url
        super.postEndEditingNotification()
    }
}
