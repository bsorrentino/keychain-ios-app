//
//  MainDelegate.swift
//  KeyChain
//
//  Created by softphone on 16/08/2018.
//  Copyright © 2018 SOFTPHONE. All rights reserved.
//

import Foundation
import AVFoundation;

//@UIApplicationMain
//@objc
class KeyChainAppDelegate : _KeyChainAppDelegate {

    private var clickSound:AVAudioPlayer?
    
    func playClick() {
        clickSound?.play()

    }
    
    override func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let musicFile = Bundle.init(identifier: "com.apple.UIKit")?.url(forResource: "Tock", withExtension: "aiff") {
            
            if let sound = try? AVAudioPlayer( contentsOf: musicFile ) {
                sound.setVolume( 0.15, fadeDuration: 0.5)
                self.clickSound = sound
            }

        }
        
        checkEntities()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

                
        return true
    }

    /**
     applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
     */
    override func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
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
