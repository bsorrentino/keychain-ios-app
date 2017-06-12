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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slp = SwiftLinkPreview()
        imageSlideshow.slideshowInterval = 5.0
        
        textURL.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func textFieldDidChange(textField: UITextField){
        
        print("Text changed \(textURL.text!)"  )
        
        overlayView?.frame = self.view.frame
        view.addSubview(overlayView!)
        
    
        let task = slp?.preview(
            textURL.text!,
            onSuccess: { result in
                self.overlayView?.removeFromSuperview()
                
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
           
            self.overlayView?.removeFromSuperview()

            print( "\(error)")
        })
        
        overlayView?.cancelBlock = {
            task?.cancel();
            self.overlayView?.removeFromSuperview()
        }

    }
}

@objc
class PushLinkPreviewCell : PushControllerDataEntryCell {
   
    @IBOutlet /*weak*/ var pushViewController: PushLinkPreviewController!

    /*
    override func awakeFromNib() {
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    */
    
    override func layoutSubviews() {
        
    }
    
    override func setControlValue(_ value: Any) {
        
        guard let value = value as? String else {
            pushViewController.textURL?.text = ""
            return
        }
        
        print( value )
        
        pushViewController.textURL?.text = value
    }
    
    override func getControlValue() -> Any {
        
        return pushViewController.textURL.text ?? ""
        
    }
    
    override func viewController(_ cellData: [AnyHashable : Any]) -> UIViewController? {
        
        pushViewController.delegate = self
        
        return pushViewController
        
    }
}
