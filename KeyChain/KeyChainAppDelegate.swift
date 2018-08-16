//
//  MainDelegate.swift
//  KeyChain
//
//  Created by softphone on 16/08/2018.
//  Copyright © 2018 SOFTPHONE. All rights reserved.
//

import Foundation
import WatchConnectivity

//@UIApplicationMain
//@objc
class KeyChainAppDelegate : _KeyChainAppDelegate {

    override func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if( !super.application(application, didFinishLaunchingWithOptions: launchOptions) ) {
            return false
        }
                
        return true
    }

    public static func showMessagePopup( _ message:String, title:String ) {
    
        
        guard let mainWindow = UIApplication.shared.delegate?.window, let rootController = mainWindow?.rootViewController else {
            return
        }
        
        let alert = UIAlertController( title:title, message:message, preferredStyle:.alert)
        let okButton = UIAlertAction( title:"OK", style: .default)
        alert.addAction(okButton)
        
        alert.present(rootController, animated: true )

    }

    public static func showErrorPopup( _ error:Error ) {

        showMessagePopup( error.localizedDescription, title:"Error" )
    }

}
