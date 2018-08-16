//
//  KeyChainAppDelegate.m
//  KeyChain
//
//  Created by softphone on 15/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "KeyListViewController.h"
#import "KeyChainLogin.h"

@implementation _KeyChainAppDelegate {
    
    BOOL _alreadyBecomeActive;
}

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;

#pragma mark class methods

static  NSString * _REGEXP = @"(\\w+)[-@/](\\w+)";
//
// Process keys to identify candidate sections
//
+ (void)processKeysToIdentifySections {

    _KeyChainAppDelegate *delegate = (KeyChainAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    @autoreleasepool {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = 
        [NSEntityDescription entityForName:@"KeyInfo" inManagedObjectContext:delegate.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = 
            [NSPredicate predicateWithFormat:@"(group == NO or group == nil) and mnemonic MATCHES %@",  _REGEXP];
        
        [fetchRequest setPredicate:predicate];
                
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:20];
        
        // Edit the sort key as appropriate.
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"mnemonic" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = 
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                             managedObjectContext:delegate.managedObjectContext 
                                               sectionNameKeyPath:@"sectionId" 
                                                        cacheName:nil]; 
        
        {
        NSError *error = nil;
        if (![aFetchedResultsController performFetch:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return;
        }}
            
        
        NSArray *sections = [aFetchedResultsController fetchedObjects];
        
        NSLog(@"number of sections [%lu]", (unsigned long)[sections count]);
        
        
        if ([sections count]>0) {
            
            NSError *error = nil;
            
            NSRegularExpression *pattern = [[NSRegularExpression alloc] 
                                            initWithPattern:_REGEXP 
                                            options:NSRegularExpressionCaseInsensitive 
                                            error:&error ];
            if (pattern!=nil) {
                
                for (KeyEntity *ki in sections) {
                    NSTextCheckingResult *match = 
                        [pattern firstMatchInString:ki.mnemonic 
                                                    options:0 
                                                    range:NSMakeRange(0, [ki.mnemonic length])];
                    
                    NSRange r1 = [match rangeAtIndex:1];
                    NSRange r2 = [match rangeAtIndex:2];
                    
                    NSString *groupKey = [ki.mnemonic substringWithRange:r1];
                    
                    NSLog(@"r1.location [%lu] r1.length [%lu] [%@]", (unsigned long)r1.location, (unsigned long)r1.length, groupKey);
                    NSLog(@"r2.location [%lu] r2.length [%lu] [%@]", (unsigned long)r2.location, (unsigned long)r2.length, [ki.mnemonic substringWithRange:r2]);
                    
                    KeyEntity * kk = [delegate findKeyEntityByName:groupKey];
                    
                    if( kk == nil ) {
                        
                        
                        /*kk = */[KeyEntity createSection:groupKey 
                                           groupPrefix:[groupKey stringByAppendingFormat:@"-"] 
                                             inContext:delegate.managedObjectContext];
                    }
                    
                    ki.group = [NSNumber numberWithBool:YES];
                    
                }
                
                [delegate saveContext];
            } 
            else {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                return;
                
            }
        }
        
    } // autoreleasepool
    
    
}



#pragma mark - Application lifecycle

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    NSLog(@"applicationDidEnterBackground");

    _alreadyBecomeActive = NO;
    
    [self saveContext];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    __BLOCKSELF;
    
    static dispatch_once_t onceToken;
  
    NSLog( @"applicationDidBecomeActive state [%ld]", application.applicationState );
	
    if( !_alreadyBecomeActive ) {
        [KeyChainLogin	doModal:navigationController onLoggedIn:^{
            
            dispatch_once(&onceToken, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [__self.rootViewController.keyListViewController filterReset:YES];
                });
            });
        }];
        _alreadyBecomeActive = YES;
    }
}

@end

