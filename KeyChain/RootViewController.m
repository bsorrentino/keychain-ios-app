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


@interface RootViewController (Private)
-(void)insertNewObject;
@end


@implementation RootViewController

@synthesize keyListViewController=keyListViewController_;
@synthesize exportViewController=exportViewController_;
@synthesize importViewController=importViewController_;


#pragma mark - 
#pragma mark KeyListDataSource implementation
#pragma mark - 

- (NSArray *)fetchedObjects 
{
    
    [self.keyListViewController filterContentByPredicate:nil scope:nil];
    return [self.keyListViewController fetchedObjects];
}

- (NSEntityDescription *)entityDescriptor 
{
 
    return [self.keyListViewController entityDescriptor];
}

- (void)filterReset 
{
    [self.keyListViewController filterReset];
    
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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                  target:self 
                                  action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    
	self.title = NSLocalizedString(@"KeyListViewController.title", @"main title");
    
    [self.keyListViewController initWithNavigationController:self.navigationController];
    
    self.exportViewController.delegate = self;
    self.importViewController.delegate = self;
}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyListViewController viewWillAppear:animated];
}

/*
 override to forward requesto to keyListViewController 
 
 Updates the appearance of the Edit|Done button item as necessary. Clients who override it must call super 
*/
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.keyListViewController setEditing:editing animated:animated];
}



@end


