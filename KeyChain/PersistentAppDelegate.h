//
//  PersistentAppDelegate.h
//  KeyChain
//
//  Created by softphone on 06/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define _PERSISTENT_APP_NAME "KeyChain"
#define _PERSISTENT_APP_MODEL "KeyChain-1.2"

@class KeyEntity;

@interface PersistentAppDelegate : NSObject <UIApplicationDelegate> {

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	
    NSSearchPathDirectory applicationSearchPathDirectory_;
}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDataDirectory;
- (void)saveContext;
- (void) checkEntities;

- (KeyEntity *)findKeyEntityByName:(NSString *)mnemonic;

+ (NSManagedObject *) clone:(NSManagedObject *)source inContext:(NSManagedObjectContext *)context;

@end
