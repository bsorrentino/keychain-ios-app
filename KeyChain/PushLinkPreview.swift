//
//  PushLinkPreview.swift
//  KeyChain
//
//  Created by softphone on 09/06/2017.
//  Copyright © 2017 SOFTPHONE. All rights reserved.
//

import Foundation
import UIKit


class PushLinkPreviewController : UIViewController {
    var cell : PushLinkPreviewCell?
    
    override func viewDidLoad() {
        
        print( "load" )
    }
}

@objc class PushLinkPreviewCell : PushControllerDataEntryCell {
   
    @IBOutlet var _viewController: PushLinkPreviewController!
    override func setControlValue(_ value: Any!) {
        
    }
    
    override func getControlValue() -> Any! {
        return ""
    }
    
    override func viewController(_ cellData: [AnyHashable : Any]!) -> UIViewController! {
        
        return _viewController
        
    }
}
