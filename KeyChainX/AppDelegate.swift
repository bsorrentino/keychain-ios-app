//
//  AppDelegate.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI
import Combine
import KeychainAccess
import Shared


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        logger.trace( "> didFinishLaunchingWithOptions" )

        startObservingManagedObjectContextObjectsDidChangeEvent()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        logger.trace( "> applicationWillTerminate" )
        
        stopObservingManagegObjectContextObjectsDidChangeEvent()
        
        saveContext()

    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        logger.trace( "> configurationForConnecting")

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        
        logger.trace( "> didDiscardSceneSessions")
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        
        do {
        
            let container = try SharedModule.getPersistentContainer()
            
            
            //let container = NSPersistentContainer(name: "KeyChain")
            container.loadPersistentStores() { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                     
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                    //logger.critical( "Unresolved error \(error), \(error.userInfo)" )
                }
                container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                container.viewContext.automaticallyMergesChangesFromParent = true
                
                logger.info(
                    """
                    Data Model version: \(container.persistentStoreCoordinator.managedObjectModel.versionIdentifiers)
                    Persistent Store Descriptions: \(container.persistentStoreDescriptions)
                    """
                )
                
                if isInPreviewMode {
                    
                    [
                        "A0",
                        "B0",
                        "C0",
                        "B1",
                        "B2",
                    ].forEach {
                        let record = KeyEntity(context: container.viewContext)
                        record.username = "bartolomeo.sorrentino@soulsoftware.it"
                        record.mnemonic = $0
                    
                        container.viewContext.insert( record )
                    }
                    
                    
                    Dictionary( grouping: [ "AG0-A0",
                                            "AG0-B0",
                                            "AG0-C0",
                                            "AG0-B1",
                                            "AG0-B2",
                                          ], by: { String($0[..<$0.index( $0.startIndex, offsetBy: 3 )]) })
                        .forEach { keyValue in
                            let record = KeyEntity(context: container.viewContext)
                            record.mnemonic = keyValue.key
                            record.groupPrefix = keyValue.key
                            record.group = false
                            container.viewContext.insert( record )
                            
                            keyValue.value.forEach { value in
                                let record = KeyEntity(context: container.viewContext)
                                record.username = value
                                record.mnemonic = value
                                record.group = true
                                record.groupPrefix = keyValue.key
                                
                                container.viewContext.insert( record )
                            }
                            
                        }
                }
            }
            return container
        }
        catch {
            fatalError( error.localizedDescription )
        }
    }()
     

}
