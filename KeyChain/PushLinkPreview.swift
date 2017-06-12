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


class PushLinkPreviewController : UIViewController, UITextFieldDelegate {
    
    var cell : PushLinkPreviewCell?
    var slp : SwiftLinkPreview?
    
    var delegate : BaseDataEntryCellDelegate?
    
    @IBOutlet weak var textURL: UITextField!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelCanonicalUrl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slp = SwiftLinkPreview()
        
        textURL.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func textFieldDidChange(textField: UITextField){
        
        print("Text changed \(textURL.text!)"  )
        
        slp?.preview(
            textURL.text!,
            onSuccess: { result in
                
                if let title = result[.title] as? String {
                    self.labelTitle.text = title;
                }
                if let description = result[.description] as? String {
                    self.labelDescription.text = description;
                }
                if let canonicalUrl = result[.canonicalUrl] as? String {
                    self.labelCanonicalUrl.text = canonicalUrl;
                }
        },
            onError: { error in
                
                print("\(error)")
                
        }
        )
        
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
