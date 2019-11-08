//
//  PersistentAppDelegate.m
//  KeyChain
//
//  Created by softphone on 06/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PersistentAppDelegate.h"
#import "OptionPane.h"

#ifndef _PERSISTENT_APP_NAME 
#define _PERSISTENT_APP_NAME "MyApp"
#endif

#define REPLACE_DB

@interface PersistentAppDelegate(Private)

- (BOOL) isSchemaCompatible:(NSPersistentStoreCoordinator *)psc;
- (void)checkSearchPathDirectoryForDataFile;
- (void)moveDataFileSafe:(NSFileManager *)fileManager sourcePath:(NSString *)sourcePath targetPath:(NSString *)targetPath removeTarget:(BOOL)removeTarget;
@end


@implementation PersistentAppDelegate

@synthesize window;
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

#pragma - Private implementation

- (void)moveDataFileSafe:(NSFileManager *)fileManager sourcePath:(NSString *)sourcePath targetPath:(NSString *)targetPath removeTarget:(BOOL)removeTarget {

    NSLog(@"file [%@] exists.\n Try moving to [%@]", sourcePath, targetPath);
    
    if( removeTarget ){
        
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:targetPath error:&error];
        
        if( !success ) {
            NSLog(@"error removing target  [%@] ", [error description]);
            
            return ; 
        }
    }
    
    {
        
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error];
        
        if( !success ) {
            NSLog(@"error moving file [%@] ", [error description]);
         
            applicationSearchPathDirectory_ = NSDocumentDirectory;

            return;
        }
    }
    
    {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:sourcePath error:&error];
        
        if( !success ) {
            NSLog(@"error removing file [%@] ", [error description]);
            return ;
        }
    }
    
}

- (void)checkSearchPathDirectoryForDataFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    @autoreleasepool {
    @try {
        
        
        //NSArray *sourcePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString *sourceDirectory = [sourcePaths objectAtIndex:0];
        NSString *sourceDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

        NSString *sourcePath = [sourceDirectory stringByAppendingPathComponent:@_PERSISTENT_APP_NAME".sqlite"];
        

        
        
        if( [fileManager fileExistsAtPath:sourcePath] ) {

            
            //NSArray *targetPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            //NSString *targetPath = [targetPaths objectAtIndex:0];
            NSString *targetDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
            NSString *targetPath = [targetDirectory stringByAppendingPathComponent:@_PERSISTENT_APP_NAME".sqlite"];

#ifdef REPLACE_DB
            
            if([fileManager fileExistsAtPath:targetPath] ) {

                [OptionPane showOKCancelAlert:@"Warning" message:@"Data file already exist\nDo you want owerwrite it?"  
                                      OKTitle:@"Yes" OKBlock:[^{
                                            
                    
                                            [self moveDataFileSafe:fileManager sourcePath:sourcePath targetPath:targetPath removeTarget:YES] ;
                                            
                                        } copy]
                                  CancelTitle:@"No" CancelBlock:nil ] ;

                return;
            }    
#endif            
            [self moveDataFileSafe:fileManager sourcePath:sourcePath targetPath:targetPath removeTarget:NO];
            
            return;
        }
        
        return;
        
    }
    @finally {
    }
    }     
}

- (BOOL) isSchemaCompatible:(NSPersistentStoreCoordinator *)psc {
    
    NSString *sourceStoreType = NSSQLiteStoreType ;
    
    NSURL *sourceStoreURL =  
    [NSURL fileURLWithPath: 
     [[self applicationDataDirectory] stringByAppendingPathComponent: @_PERSISTENT_APP_NAME".sqlite"]];
    
    NSError *error = nil;
    
    NSDictionary *sourceMetadata =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:sourceStoreType
                                                               URL:sourceStoreURL
                                                             error:&error];
    
    if (sourceMetadata == nil) {
        // deal with error
    }
    
    NSString *configuration = nil;
    NSManagedObjectModel *destinationModel = [psc managedObjectModel];
    BOOL pscCompatibile = [destinationModel
                           isConfiguration:configuration
                           compatibleWithStoreMetadata:sourceMetadata];
    
    return (pscCompatibile);
}

#pragma - Custom implementation

- (void) checkEntities {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AttributeInfo" inManagedObjectContext:self.managedObjectContext];
    
    NSUInteger count = [[entity properties] count];
    
    NSLog(@"AttributeInfo entity name [%@] abstract [%d] count[%lu]", 
          entity.name, 
          [entity isAbstract], 
           (unsigned long)count);
    
        
    entity = [NSEntityDescription entityForName:@"KeyInfo" inManagedObjectContext:self.managedObjectContext];
    
    NSLog(@"KeyInfo entity name [%@] abstract [%d] count[%lu]", 
          entity.name, 
          [entity isAbstract], 
          (unsigned long)count  );

}


- (void)saveContext {
    
    if (managedObjectContext_ != nil) {
        
        if ([managedObjectContext_ hasChanges] ) {
            
            NSError *error = nil;
            if( ![managedObjectContext_ save:&error]) {
        
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@_PERSISTENT_APP_MODEL ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    applicationSearchPathDirectory_ = NSLibraryDirectory;
   
    [self checkSearchPathDirectoryForDataFile];
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDataDirectory] stringByAppendingPathComponent: @_PERSISTENT_APP_NAME".sqlite"]];
    
    NSLog(@"store URL\n%@", storeURL);
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *options = nil;
    
    BOOL schemaIsCompatible = [self isSchemaCompatible:persistentStoreCoordinator_];
    
    if (!schemaIsCompatible) {
        NSLog(@"schema is not compatible. try lightweight migration");        
        //
        // DATA MIGRATION
        //
        options = 
                [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil]
                ;
    }
    else {
        NSLog(@"schema is compatible.");
    }
 
    if (![persistentStoreCoordinator_
          addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) 
    {
        
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    

    
    if( schemaIsCompatible ) {

        //MIGRATE ENCRYPTED KEYS TO KEYCHAIN
    
        /*
        [[AccountCredential sharedCredential] checkCurrentVersion:^(NSUInteger prev, NSUInteger next) {
            
            if (next == 0) {
                
                [KeyEntity copyPasswordsToKeychain:self.managedObjectContext];
            }
        }];
        */
    }
    
    

    return persistentStoreCoordinator_;
}

#pragma mark query methods

- (KeyEntity *)findKeyEntityByName:(NSString *)mnemonic {
    
    @autoreleasepool {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = 
            [NSEntityDescription entityForName:@"KeyInfo" inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = 
            [NSPredicate predicateWithFormat:@"(group == NO or group == nil) and mnemonic == %@", mnemonic];
        
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setFetchBatchSize:1];

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"mnemonic" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = 
            [[NSFetchedResultsController alloc]    initWithFetchRequest:fetchRequest 
                                                    managedObjectContext:self.managedObjectContext 
                                                    sectionNameKeyPath:nil 
                                                    cacheName:nil]; 
        
        {
            NSError *error = nil;
            if (![aFetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                return nil;
            }
        }
        
        NSArray *result = [aFetchedResultsController fetchedObjects];

        NSLog(@"findKeyEntityByName fetchedObjects #[%lu]", (unsigned long)[result count]);

        return ( [result count] > 0 ) ? [result lastObject] : nil;

    } // autoreleasepool
    
}

#pragma mark clone methods


//
+(NSManagedObject *) clone:(NSManagedObject *)source inContext:(NSManagedObjectContext *)context{
    NSString *entityName = [[source entity] name];
    
    //create new object in data store
    NSManagedObject *cloned = [NSEntityDescription
                               insertNewObjectForEntityForName:entityName
                               inManagedObjectContext:context];
    
    //loop through all attributes and assign then to the clone
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:entityName
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        [cloned setValue:[source valueForKey:attr] forKey:attr];
    }
    
    //Loop through all relationships, and clone them.
    NSDictionary *relationships = [[NSEntityDescription
                                    entityForName:entityName
                                    inManagedObjectContext:context] relationshipsByName];
    
    for (NSString *relName in [relationships allKeys]) { 
        
        NSRelationshipDescription *rel = [relationships objectForKey:relName];
        
        NSString *keyName = [NSString stringWithFormat:@"%@",rel];
        //get a set of all objects in the relationship
        NSMutableSet *sourceSet = [source mutableSetValueForKey:keyName];
        NSMutableSet *clonedSet = [cloned mutableSetValueForKey:keyName];
        NSEnumerator *e = [sourceSet objectEnumerator];
        NSManagedObject *relatedObject;

        while ( relatedObject = [e nextObject]){
            //Clone it, and add clone to set
            NSManagedObject *clonedRelatedObject = [PersistentAppDelegate clone:relatedObject 
                                                                    inContext:context];
            [clonedSet addObject:clonedRelatedObject];
        }
        
    }
    
    return cloned;
}

#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDataDirectory {
    return [NSSearchPathForDirectoriesInDomains(applicationSearchPathDirectory_, NSUserDomainMask, YES) lastObject];
    //return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Memory management





@end
