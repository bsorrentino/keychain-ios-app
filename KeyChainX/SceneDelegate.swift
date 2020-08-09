//
//  SceneDelegate.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let loginStates:LoginView.States = LoginView.States()
    var window: UIWindow?

    var appDelegate:AppDelegate? {
         (UIApplication.shared.delegate as? AppDelegate)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // @see https://stackoverflow.com/a/56862325/521197
        // Use a UIHostingController as window root view controller
        
        
        #if NO_UNIT_TEST
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let view = ContentView( loginStates: loginStates )
                .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext) // CoreData integrations
            
            window.rootViewController = UIHostingController(rootView: view  )

            self.window = window
            window.makeKeyAndVisible()
        }
        #endif
    
        // Use a UIHostingController as window root view controller
        //let window = UIWindow(frame: UIScreen.main.bounds)
        //window.rootViewController = UIHostingController(rootView: ContentView(items: []))
        //self.window = window
        //window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    
        print( "> sceneDidDisconnect" )
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.

        print( "> sceneDidBecomeActive" )
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        print( "> sceneWillResignActive" )

        self.loginStates.show = true

    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.

        print( "> sceneWillEnterForeground" )
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.

        print( "> sceneDidEnterBackground" )
    }


}

