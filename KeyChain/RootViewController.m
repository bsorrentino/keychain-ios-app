//
//  RootViewController.m
//  KeyChain
//
//  Created by softphone on 15/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "KeyListViewController.h"
#import "KeyEntityFormController.h"
#import "BaseDataEntryCell.h"
#import "KeyChainAppDelegate.h"
#import "KeyChainLogin.h"
#import "ExportViewController.h"
#import "ImportViewController.h"

#import "WaitMaskController.h"

#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#import "YISplashScreen+Migration.h"
#import "AccountCredential.h"
#import "StringEncryptionTransformer.h"

@interface RootViewController (Private)
-(void)insertNewObject;
@end


@implementation RootViewController

@synthesize keyListViewController=keyListViewController_;
@synthesize exportViewController=exportViewController_;
@synthesize importViewController=importViewController_;
@synthesize encryptButton;
@synthesize decryptButton;

#pragma mark - private implementation

- (KeyChainAppDelegate *)appDelegate {
    return (KeyChainAppDelegate *)[[UIApplication sharedApplication] delegate];
}


-(NSManagedObjectContext *)managedObjectContext {
    return [[self appDelegate] managedObjectContext];
}

#pragma mark - KeyListDataSource implementation


- (NSArray *)fetchedObjects
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity =
    [NSEntityDescription    entityForName:@"KeyInfo"
                   inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor =
    [NSSortDescriptor sortDescriptorWithKey:@"mnemonic" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[self managedObjectContext]
                                          sectionNameKeyPath:@"sectionId"
                                                   cacheName:nil];
    
    NSError *error = nil;
    
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
        return nil;
    }
    
    return [aFetchedResultsController fetchedObjects];
    
}

- (NSEntityDescription *)entityDescriptor 
{
 
    return [self.keyListViewController entityDescriptor];
}

- (void)filterReset:(BOOL)reloadData
{
    [self.keyListViewController filterReset:reloadData];
    
}

#pragma mark - RootViewController private methods

- (void)insertNewObject {
    [self.keyListViewController insertNewObject:self];
}


#pragma mark - RootViewController private methods

-(IBAction)import:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    
    //setting animation for the current view
    //[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    
    //Push the next viewcontroller to NavigationController
    
    [self.navigationController pushViewController:self.importViewController animated:NO];
    //[detailViewController release];
    
    //Start the Animation
    [UIView commitAnimations];
}



- (IBAction)encrypt:(id)sender {

    __block RootViewController *_self = self;
    
    if ([AccountCredential sharedCredential].encryptionEnabled ) {
        return;
    }
    
    [YISplashScreen show];
    
    [YISplashScreen waitForMigration:^{
        
        [[_self fetchedObjects] makeObjectsPerformSelector:@selector(encryptPassword)];
        
        [AccountCredential sharedCredential].encryptionEnabled = YES;
        
        [[_self appDelegate] saveContext ];
        
        [_self filterReset:YES];
        
    } completion:^{
        
        _self.encryptButton.enabled = NO;
        _self.decryptButton.enabled = YES;
        
        [YISplashScreen hide];
        
    }];

}

- (IBAction)decrypt:(id)sender {
    __block RootViewController *_self = self;
    
    if (![AccountCredential sharedCredential].encryptionEnabled ) {
        return;
    }
    
    [YISplashScreen show];
    
    [YISplashScreen waitForMigration:^{
        
        [[_self fetchedObjects] makeObjectsPerformSelector:@selector(decryptPassword)];
        
        [AccountCredential sharedCredential].encryptionEnabled = NO;
        
        [[_self appDelegate] saveContext ];
        
        [_self filterReset:YES];
        
    } completion:^{
        
        _self.encryptButton.enabled = YES;
        _self.decryptButton.enabled = NO;

        [YISplashScreen hide];
        
    }];
    
}

-(IBAction)export:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    
    //setting animation for the current view
    //[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    
    //Push the next viewcontroller to NavigationController
    
    [self.navigationController pushViewController:self.exportViewController animated:NO];
    //[detailViewController release];
    
    //Start the Animation
    [UIView commitAnimations];
    

}

-(IBAction)changePassword:(id)sender {
    
    KeyChainLogin *login = [[KeyChainLogin alloc] initForChangePassword];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    
    //setting animation for the current view
    //[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    
    //Push the next viewcontroller to NavigationController
    
    [self.navigationController pushViewController:login animated:NO];
    //[detailViewController release];
    
    //Start the Animation
    [UIView commitAnimations];

}

#pragma mark - RootViewController lifecycle

-(void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	
    // Set up the edit and add buttons.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                  target:self 
                                  action:@selector(insertNewObject)];
    self.navigationItem.leftBarButtonItem = addButton;
    
	self.title = NSLocalizedString(@"KeyListViewController.title", @"main title");
    
    [self.keyListViewController initWithNavigationController:self.navigationController];
    
    self.exportViewController.delegate = self;
    self.importViewController.delegate = self;

}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyListViewController viewWillAppear:animated];
   
    self.encryptButton.enabled =
        ![AccountCredential sharedCredential].encryptionEnabled;
    self.decryptButton.enabled =
        [AccountCredential sharedCredential].encryptionEnabled;
}

/*
 override to forward requesto to keyListViewController 
 
 Updates the appearance of the Edit|Done button item as necessary. Clients who override it must call super 
*/
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    [self.keyListViewController setEditing:editing animated:animated];
}



- (void)viewDidUnload {
    [self setEncryptButton:nil];
    [self setDecryptButton:nil];
    [super viewDidUnload];
}
@end


