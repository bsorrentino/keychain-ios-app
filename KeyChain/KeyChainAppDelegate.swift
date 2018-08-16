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
class KeyChainAppDelegate : PersistentAppDelegate {
    
    @IBOutlet
    var  navigationController:UINavigationController!;

    var filterHasBeenReset = false
    
    private var _alreadyBecomeActive:Bool = false

    private var clickSound:AVAudioPlayer?

    var theRootViewController:RootViewController? {
        get {
            return navigationController.viewControllers.first as? RootViewController
        }
    }
    
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

    override func applicationDidEnterBackground(_ application: UIApplication) {
        _alreadyBecomeActive = false;
        
        saveContext()
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        
        if( _alreadyBecomeActive ) {
            return
        }
        
        KeyChainLogin.doModal(navigationController) { [unowned self] in 
            
            if( !self.filterHasBeenReset ) {
                if let controller = self.theRootViewController {
                    
                    DispatchQueue.main.async {
                        controller.filterReset(true)
                    }
                    self.filterHasBeenReset = true

                }
            }

        }
        _alreadyBecomeActive = true;

        
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
