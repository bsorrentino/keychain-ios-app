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
//
// Make Sting compliant with Error protocol
// @see https://www.hackingwithswift.com/example-code/language/how-to-throw-errors-using-strings
//
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

// GLOBAL DATA
// IT IS A CACHE
class ApplicationKeys: ObservableObject {
    typealias AType = KeyItem
    
    let objectWillChange = PassthroughSubject<AType,Never>()
    
    var items:Array<KeyItem> = []
    
    convenience init( items:Array<KeyItem> ) {
        self.init();
        
        self.items = items
    }
}

class ApplicationMails: ObservableObject {
    typealias AType = Any
    
    let objectWillChange = PassthroughSubject<AType,Never>()

    var items:Array<Any> = []
    
    convenience init( items:Array<Any> ) {
        self.init();
        
        self.items = items
    }
}

// KeyEntity Extension
extension KeyEntity {
    
    func toKeyItem() throws -> KeyItem {
        
        guard let id = self.mnemonic, let username = self.username else {
            throw "Invalid KeyEntity no mnemonic or username defined"
        }
        
        return KeyItem( id:id, username:username )
    }

    
    func from( item: KeyItem ) -> KeyEntity {
        self.mnemonic = item.id
        self.username = item.username
        return self
    }

    static func fromKeyItem( item: KeyItem, context:NSManagedObjectContext ) throws -> KeyEntity {
        
        let result = KeyEntity( context:context )

        return result.from( item:item )
    }

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let applicationKeys = ApplicationKeys()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.loadContext()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "KeyChainX")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        })
        return container
    }()
    
    // MARK: - Core Data Loading support
    
    private var cancellable:AnyCancellable?
    
    enum CoreDataError :Error {
        
        case KeyDoesNotExist( id:String )
        case DuplicateKey( id:String )
        case InvalidItem( id:String )
    }
    
    /**
        Fetch Single Value
     */
    func fetchSingle( entity:NSEntityDescription, predicateFormat:String, key:String  ) throws -> Any {
        let context = persistentContainer.viewContext;

        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity =  entity
        request.predicate = NSPredicate( format: predicateFormat, key)
        let fetchResult = try context.fetch( request )
        
        if( fetchResult.count == 0 ) {
            throw CoreDataError.KeyDoesNotExist(id: key)
            
        }
        if( fetchResult.count > 1 ) {
            throw CoreDataError.DuplicateKey(id: key)
            
        }
        return fetchResult[0]
    }
    
    /**
        Fetch KeyItem by id
     */
    func fetchKeyItemById( item:KeyItem ) throws -> KeyEntity {
        
        guard let result = try self.fetchSingle( entity:KeyEntity.entity(),
                              predicateFormat:"(mnemonic = %@)",
                              key:item.id) as? KeyEntity else {
                throw CoreDataError.InvalidItem(id: item.id)
        }
        return result

    }
    
    func loadContext() {
        
        let context = persistentContainer.viewContext;
        
        do {
            let request = NSFetchRequest<KeyEntity>(entityName: "KeyItem")
            
            let result = try context.fetch(request)
            
            self.applicationKeys.items =  try result.map{ try $0.toKeyItem() }
            
            self.cancellable = self.applicationKeys.objectWillChange.sink { item in
            
                print( "Changed Value: \(item)" )
                
                do {
                    switch( item.state ) {
                    case .new:
                        let record = try KeyEntity.fromKeyItem(item: item, context: context)
                        context.insert( record )
                        item.state = .neutral
                        break
                    case .updated:
                        let result = try self.fetchKeyItemById( item:item )
                        let _ = result.from(item: item)
                        item.state = .neutral
                        break
                    case .deleted:
                        let result = try self.fetchKeyItemById( item:item )
                        let _ = result.from(item: item)
                        context.delete(result)
                        break
                    default:
                        break
                    }
                }
                catch {
                    print( "Error updating Database \(error)" )
                }
            
            }
            
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")

        }
        
    }
    
    // MARK: - Core Data Saving support

    func saveContext () {
        
        /*
        if let cancellable = self.cancellable {
            cancellable.cancel()
        }
        */
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

