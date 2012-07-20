//
//  KeyListViewController.m
//  KeyChain
//
//  Created by softphone on 10/02/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "KeyListViewController.h"
#import "KeyEntityFormController.h"
#import "BaseDataEntryCell.h"
#import "KeyChainAppDelegate.h"
#import "KeyChainLogin.h"
#import "ExportViewController.h"
#import "ImportViewController.h"
#import "KeyEntity.h"

#import "WaitMaskController.h"
#import "UIAlertViewInputSection.h"

#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>


#define TOOLBAR_TAG 20
#define SWIPEBACK_TAG 21

#define IS_SECTION_CRITERIA @"(groupPrefix != nil AND (group == nil OR group == NO))"
#define IS_GROUPED_CRITERIA @"(groupPrefix != nil AND group != nil AND group == YES)"

static NSString *SEARCHTEXT_CRITERIA = @"(mnemonic BEGINSWITH %@ OR mnemonic BEGINSWITH %@)"; // AND (groupPrefix == nil OR (group != nil AND group == YES))";
static NSString *SEARCHRESET_CRITERIA = @"group == NO or group == nil";
static NSString *SEARCHSECTION_CRITERIA = @"groupPrefix == %@ AND group == YES";

@interface KeyListViewController ( /*Private*/ )
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell entity:(KeyEntity *)managedObject;

- (void)insertNewObject2 __attribute__ ((deprecated));

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

- (void)hideSearchBar:(BOOL)animated;
- (PersistentAppDelegate *) appDelegate;
//- (NSArray *)fetchedObjects;

-(NSManagedObjectContext *)managedObjectContext;

- (void)initGestureRecognizer;

-(BOOL)isSearchTableView:(UITableView*)tableView;

@end



@interface KeyListViewController (Section) {
    
}

- (IBAction)dismissViewSection:(id)sender;
- (void)pushViewSection:(KeyEntity *)keyEntity;
- (NSRange)getSectionPrefix:(NSString*)key;
- (void)createSectionChoosingCustomSectionPrefix:(KeyEntity *)source target:(KeyEntity*)target replaceSource:(BOOL)replaceSource replaceTarget:(BOOL)replaceTarget;
- (void)setNavigationTitle:(NSString*)title;
- (BOOL)touchUpInsideEditButton;

- (IBAction)detachFromSection:(id)sender;

@end


@implementation KeyListViewController

//@synthesize managedObjectContext=managedObjectContext_;
@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize keyEntityFormController=keyEntityFormController_;
@synthesize navigationController;

//@synthesize clickedButtonAtIndexAlert=clickedButtonAtIndexAlert_;
@synthesize clickedButtonAtIndex=clickedButtonAtIndex_;
@synthesize selectedSection;

#pragma mark -
#pragma mark KeyListDataSource implementation
#pragma mark -


- (NSEntityDescription *)entityDescriptor {
    return [[self.fetchedResultsController fetchRequest] entity];    
}

- (NSArray *)fetchedObjects {
    
    NSError *error;
    BOOL result = [self.fetchedResultsController performFetch:&error ];
    
    if( !result ) {
        [KeyChainAppDelegate showErrorPopup:error];
        return nil;
    }
    
    return [self.fetchedResultsController fetchedObjects];
    
    
}

- (void)filterReset {
    
    [self filterContentByPredicate:
     [NSPredicate predicateWithFormat:SEARCHRESET_CRITERIA ] //@"group == NO or group == nil"*/
                             scope:nil];
    reloadData_ = YES;
}


#pragma mark - 
#pragma mark Section implementation
#pragma mark -

- (void)setNavigationTitle:(NSString*)title {

    self.navigationController.navigationBar.topItem.title = title;
    //self.navigationItem.title = value;
  
}

- (void)hideNavigationRightButton:(BOOL)value {
    
    if (value) {
        addButton_ = self.navigationController.navigationBar.topItem.rightBarButtonItem;
        [self.navigationController.navigationBar.topItem setRightBarButtonItem:nil];
    }
    else {
        [self.navigationController.navigationBar.topItem setRightBarButtonItem:addButton_];   
    }
    
}

- (void)pushViewSection:(KeyEntity *)keyEntity {
    
    if (![keyEntity isSection] ) return;
    
    
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.navigationController.view.layer addAnimation:animation forKey:@"pushViewSection"];
    dispatch_async(dispatch_get_main_queue(), ^{

        UIView *toolbar     = [self.navigationController.view viewWithTag:TOOLBAR_TAG];
        UIView *sectionToolbar = [self.navigationController.view viewWithTag:SWIPEBACK_TAG];

        // RESIZE TABLE
        //CGRect frame = self.tableView.frame;
        //frame.size.height += toolbar.frame.size.height;
        //[self.tableView setFrame:frame];
 
        [self setNavigationTitle:keyEntity.mnemonic];
                
        // HIDE ADD BUTTON ITEM
        [self hideNavigationRightButton:YES];
            
        // HIDE ADD BUTTON
        toolbar.hidden = YES;
        
        // SEARCH BAR
        //[self searchBarCancelButtonClicked:self.searchDisplayController.searchBar];
        [self.searchDisplayController setActive:NO];
        [self hideSearchBar:NO]; //self.searchDisplayController.searchBar.hidden = YES;
        [self.searchDisplayController.searchBar setUserInteractionEnabled:NO];


        // SHOW SECTION TOOLBAR (AT BOTTOM)
        [sectionToolbar setFrame:toolbar.frame];
        sectionToolbar.hidden = NO;    
        UIPageControl *pageControl = (UIPageControl *)[sectionToolbar viewWithTag:2];
        pageControl.currentPage = 1;
        
        
        NSPredicate *predicate = nil;
        
        // set predicate if a searchText has been set
        predicate = [NSPredicate 
                     predicateWithFormat:SEARCHSECTION_CRITERIA, 
                     keyEntity.groupPrefix ]; // autorelease    
        
        
        [self filterContentByPredicate:predicate scope:nil];
        
        [self.tableView reloadData];
        
        swipe_.enabled = YES;
        
        dd_.enabled = NO;
        
    });
    
    
}


- (IBAction)dismissViewSection:(id)sender {
    
    //UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)recognizer;
    
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.navigationController.view.layer addAnimation:animation forKey:@"dismissViewSection"];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        UIView *toolbar = [self.navigationController.view viewWithTag:TOOLBAR_TAG];

        // RESIZE TABLE
        //CGRect frame = self.tableView.frame;
        //frame.size.height -= toolbar.frame.size.height;
        //[self.tableView setFrame:frame];

        [self setNavigationTitle: NSLocalizedString(@"KeyListViewController.title", @"main title")];

        // SHOW ADD BUTTON ITEM
        [self hideNavigationRightButton:NO];

        // SHOW TOOLBAR
        toolbar.hidden = NO;

        swipe_.enabled = NO;
        
        dd_.enabled = YES;
        
        [self filterReset]; [self.tableView reloadData];
        
        if (self.selectedSection != nil ) {
            //[self.tableView scrollToRowAtIndexPath:self.selectedSection atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [self.tableView selectRowAtIndexPath:self.selectedSection animated:NO scrollPosition:UITableViewScrollPositionMiddle];        
        }
        
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{

        //self.searchDisplayController.searchBar.hidden = NO;
        [self.searchDisplayController.searchBar setUserInteractionEnabled:YES];        

        [self hideSearchBar:YES];
        
    });
}


- (void)createSectionChoosingCustomSectionPrefix:(KeyEntity *)source target:(KeyEntity*)target replaceSource:(BOOL)replaceSource replaceTarget:(BOOL)replaceTarget
{
    
    UIAlertView *inputView = [UIAlertViewInputSection alertViewWithBlock: ^(UIAlertViewInputSection *alert, NSInteger buttonIndex) {
       
        NSLog(@"clickedButtonAtIndex [%d]", buttonIndex );
        
        if (buttonIndex == 1) {
            NSLog(@"clickedButtonAtIndex groupName=[%@] grouPrefix[%@]", alert.groupName, alert.groupPrefix ); 
            
            if( alert.groupName != nil && alert.groupPrefix != nil) {
                
                [KeyEntity createSection:alert.groupName groupPrefix:alert.groupPrefix inContext:[self managedObjectContext] ];
                
                /*
                if (replaceSource) {
                    [KeyEntity groupByReplacingPrefix:source groupKey:alert.groupName prefix:alert.groupPrefix];
                }
                else {
                    [KeyEntity groupByAppendingPrefix:source prefix:alert.groupPrefix];                    
                    
                }                
                if( replaceTarget ) {
                    [KeyEntity groupByReplacingName:target mnemonic:[alert.groupPrefix stringByAppendingString:target.mnemonic]];
                }
                else {
                    [KeyEntity groupByAppendingPrefix:target prefix:alert.groupPrefix];                    
                }
                */
                [source groupByPrefix:alert.groupPrefix];
                [target groupByPrefix:alert.groupPrefix];
               
                
            }
        }
        
    }];
    
    [inputView show];
 
}

//
// fireEvent UIControlEventTouchUpInside to edit button
//
- (BOOL)touchUpInsideEditButton {
    
    for (UIView *subview in self.navigationController.navigationBar.subviews) 
    {
        NSLog(@"class [%@]", [subview class].description );
        
        if ([[subview class].description isEqualToString:@"UINavigationButton"])
        {
            
            UIButton * button = (UIButton *)subview;
            
            NSLog(@"button.text [%@]", button.titleLabel.text);
            
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            return YES;
            
        }
        
    }   
    return NO;
}

- (IBAction)detachFromSection:(id)sender {
    
    UIDetachButton *detachView = sender;
    
    KeyEntity *managedObject = [self.fetchedResultsController objectAtIndexPath: detachView.index];
    NSLog(@"detach [%@]", managedObject.mnemonic);
    
    [managedObject detachFromGroup];
    
   
    if( ![self touchUpInsideEditButton] ) {
        [self.tableView setEditing:NO animated:YES];    
        //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:detachView.index] withRowAnimation:YES];
    }

    
}

#pragma mark UIActionSheetDelegate implementation 

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (clickedButtonAtIndex_ != nil) {
        clickedButtonAtIndex_( actionSheet, buttonIndex);
    }
}

#pragma mark UIAlertViewDelegate implementation

// Called when a button is clicked. The view will be automatically dismissed after this call returns
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
//- (void)alertViewCancel:(UIAlertView *)alertView;

//- (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
//- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

// Called after edits in any of the default fields added by the style
//- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView ;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
//- (void)actionSheetCancel:(UIActionSheet *)actionSheet 

//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet  // before animation and showing view

//- (void)didPresentActionSheet:(UIActionSheet *)actionSheet  // after animation

// - (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex // before animation and hiding view

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation

#pragma mark - DDTableViewManagerDelegate implementation

//- (BOOL) possibleDropTo:(NSIndexPath *)target 
    
- (BOOL) beginDrag:(NSIndexPath *)from {
    
    KeyEntity *e = [self.fetchedResultsController objectAtIndexPath:from];

    return ![e isSection];
}

- (void) dropTo:(NSIndexPath *)source target:(NSIndexPath *)target {
    
    
    KeyEntity *eTarget = [self.fetchedResultsController objectAtIndexPath:target];
    
    KeyEntity *eSource = [self.fetchedResultsController objectAtIndexPath:source];
    

    NSLog(@"Drop from [%@] to [%@]", eSource.mnemonic, eTarget.mnemonic  );
    
    
    if ([eTarget isSection]) { 
        
        ///////////////////////////////////////////////
        //    
        // IF TARGET IS A SECTION
        //    
        ///////////////////////////////////////////////
        
        NSRange rPrefix = [KeyEntity getSectionPrefix:eSource checkIfIsSectionAware:YES];

        if( !NSEqualRanges( rPrefix, NSMakeRange(NSNotFound, 0) ) ){

            NSString *groupKey = [eSource.mnemonic substringWithRange:rPrefix];
            
            NSLog(@"groupkey [%@]", groupKey);
            
            if ( [eTarget.groupPrefix compare:groupKey options:NSCaseInsensitiveSearch] == NSOrderedSame ) {
                
                /////////////////////////////////////////////////////////
                //    
                // THE PREFIX OF TARGET IS EQUAL TO PREFIX OF GROUP 
                //    
                /////////////////////////////////////////////////////////
                
                //eSource.group = [NSNumber numberWithBool:YES];
                //[[self appDelegate] saveContext];

                self.clickedButtonAtIndex = ^( UIActionSheet *as, NSInteger i ){
                    
                    NSLog(@"clickedButtonAtIndex [%d]", i );
                    
                    switch (i) {
                        case 0: // ADD TO SECTION  
                        {
                            //NSString *newMnemonic = [eTarget.groupPrefix stringByAppendingString:eSource.mnemonic];                            
                            //[KeyEntity groupByReplacingName:eSource mnemonic:newMnemonic];
                            //[[self appDelegate] saveContext];
                            
                            [eSource groupByPrefix:eTarget.groupPrefix];
                        }
                            break;
                    }
                    
                };
                
                UIActionSheet * sheet = 
                [[UIActionSheet alloc] initWithTitle:@"Move to section" delegate:self 
                                    cancelButtonTitle:@"Cancel" 
                               destructiveButtonTitle:@"Confirm" 
                                    otherButtonTitles: nil];
                
                [sheet showInView:self.navigationController.view];
               
                
            }
            else {  

                /////////////////////////////////////////////////////////
                //    
                // THE PREFIX OF TARGET IS DIFFERENT TO PREFIX OF GROUP
                //    
                /////////////////////////////////////////////////////////

                self.clickedButtonAtIndex = ^( UIActionSheet *as, NSInteger i ){
                      
                      NSLog(@"clickedButtonAtIndex [%d]", i );
                      
                      switch (i) {
                          case 0: // REMOVE PREFIX
                          {
                              [eSource groupByPrefix:eTarget.groupPrefix];
                              
                              //[KeyEntity groupByReplacingPrefix:eSource groupKey:groupKey prefix:eTarget.groupPrefix];
                              //[[self appDelegate] saveContext];
                          }
                            break;
                          case 1: // ADD TO SECTION  
                          {
                              //NSString *newMnemonic = [eTarget.groupPrefix stringByAppendingString:eSource.mnemonic];                              
                              //[KeyEntity groupByReplacingName:eSource mnemonic:newMnemonic];                              
                              //[[self appDelegate] saveContext];

                          }
                              break;
                      }
                      
                  };
                
                UIActionSheet * sheet = 
                [[UIActionSheet alloc] initWithTitle:@"Move to section" delegate:self 
                                    cancelButtonTitle:@"Cancel" 
                               destructiveButtonTitle:@"Confirm" 
                                    otherButtonTitles: nil];
                
                
                
                [sheet showInView:self.navigationController.view];
                
            }
                        
        }
        else { 
            
            ///////////////////////////////////////////////
            //    
            // IF SOURCE HAS NOT PREFIX
            //    
            ///////////////////////////////////////////////
 
            
            self.clickedButtonAtIndex = ^( UIActionSheet *as, NSInteger i ){
                  
                      NSLog(@"clickedButtonAtIndex [%d]", i );
                      
                      if (i == 0) // ADD PREFIX 
                      {
                          //NSString *newMnemonic = [eTarget.groupPrefix stringByAppendingString:eSource.mnemonic];                          
                          //[KeyEntity groupByReplacingName:eSource mnemonic:newMnemonic];
                          //[[self appDelegate] saveContext];
                          
                          [eSource groupByPrefix:eTarget.groupPrefix];

                      }
                                            
                  };
            
            UIActionSheet * sheet = 
            [[UIActionSheet alloc] initWithTitle:@"Move to section" delegate:self 
                                cancelButtonTitle:@"Cancel" 
                                destructiveButtonTitle:@"Confirm"
                                otherButtonTitles:  nil];
            
            
            
            [sheet showInView:self.navigationController.view];
            
        }
        
    }
    else { 
    
        ///////////////////////////////////////////////
        //    
        // IF TARGET IS NOT A SECTION
        //    
        ///////////////////////////////////////////////
     
        NSRange rFromPrefix = [KeyEntity getSectionPrefix:eSource checkIfIsSectionAware:YES];

        NSRange rTargetPrefix = [KeyEntity getSectionPrefix:eTarget checkIfIsSectionAware:YES];
        
        BOOL sourceHasPrefix = !NSEqualRanges( rFromPrefix, NSMakeRange(NSNotFound, 0));
        BOOL targetHasPrefix = !NSEqualRanges( rTargetPrefix, NSMakeRange(NSNotFound, 0));
                                              
        if( !targetHasPrefix && !sourceHasPrefix ) { 
        
            ///////////////////////////////////////////////
            //    
            // EITHER SOURCE & TARGET HAVEN'T PREFIX            
            //    
            ///////////////////////////////////////////////
            [self createSectionChoosingCustomSectionPrefix:eSource target:eTarget replaceSource:NO replaceTarget:NO];
        }
        else if( targetHasPrefix && sourceHasPrefix) { 
            
            ///////////////////////////////////////////////
            //    
            // BOTH SOURCE & TARGET HAVE PREFIX
            //    
            ///////////////////////////////////////////////
            NSString *sTargetPrefix = [eTarget.mnemonic substringWithRange:rTargetPrefix];
            NSString *sSourcePrefix   = [eSource.mnemonic substringWithRange:rFromPrefix];

            __block id _self = self;

             self.clickedButtonAtIndex = ^( UIActionSheet *as, NSInteger i ){
                 
                 NSLog(@"clickedButtonAtIndex [%d]", i );
                 
                 switch (i) {
                     case 0: // USE CUSTOM PREFIX  
                     {
                         NSLog(@"use custom prefix " );
                         
                         [_self createSectionChoosingCustomSectionPrefix:eSource target:eTarget replaceSource:YES replaceTarget:YES];
                     }
                         break;                         
                     case 1: // USE TARGET PREFIX  
                     {
                         NSLog(@"use target prefix [%@]", sTargetPrefix );
                         
                         NSString *groupKey = [KeyEntity sectionNameFromPrefix:sTargetPrefix trim:YES];
                         
                         [KeyEntity createSection:groupKey groupPrefix:sTargetPrefix inContext:[_self managedObjectContext]];

                         //eTarget.group = [NSNumber numberWithBool:YES];
                         //[KeyEntity groupByReplacingPrefix:eSource groupKey:groupKey prefix:sTargetPrefix];
                         
                         [eTarget groupByPrefix:sTargetPrefix];
                         [eSource groupByPrefix:sTargetPrefix];
 
                     }
                         break;
                     case 2: // USE SOURCE PREFIX  
                     {
                         NSLog(@"use source prefix [%@]", sSourcePrefix );
                         
                         NSString *groupName = [KeyEntity sectionNameFromPrefix:sSourcePrefix trim:YES];
                         
                         [KeyEntity createSection:groupName groupPrefix:sSourcePrefix inContext:[_self managedObjectContext]];
                         
                         //eSource.group = [NSNumber numberWithBool:YES];
                         //[KeyEntity groupByReplacingPrefix:eTarget groupKey:groupName prefix:sFromPrefix];
                         
                         [eSource groupByPrefix:sSourcePrefix];
                         [eTarget groupByPrefix:sSourcePrefix];
                     }
                         break;
                 }
                 
             };
            
            UIActionSheet * sheet = 
            [[UIActionSheet alloc] initWithTitle:@"Move to section" delegate:self 
                                cancelButtonTitle:@"Cancel" 
                           destructiveButtonTitle:@"Use custom prefix"
                                otherButtonTitles: 
                                    [NSString stringWithFormat:@"Use prefix [%@]", sTargetPrefix ], 
                                    [NSString stringWithFormat:@"Use prefix [%@]", sSourcePrefix ], nil];
            
            
            
            [sheet showInView:self.navigationController.view];
            
        }
        else if( sourceHasPrefix ) { 
            
            ///////////////////////////////////////////////
            //    
            // ONLY SOURCE HAS PREFIX
            //    
            ///////////////////////////////////////////////
            
            NSString *sSourcePrefix = [eSource.mnemonic substringWithRange:rFromPrefix];

            NSLog(@"ONLY SOURCE HAS PREFIX [%@]", sSourcePrefix );

            __block id _self = self;
            
            self.clickedButtonAtIndex = ^( UIActionSheet *as, NSInteger i ){
                  
                  
                  switch (i) {
                      case 0: // USE CUSTOM PREFIX  
                      {
                          NSLog(@"USE CUSTOM PREFIX" );
                          
                          [_self createSectionChoosingCustomSectionPrefix:eSource target:eTarget replaceSource:YES replaceTarget:NO];
                      }
                          break;
                      case 1: // USE FROM PREFIX  
                      {
                          NSLog(@"USE SOURCE PREFIX [%@]", sSourcePrefix );
                          
                          NSString *groupName = [KeyEntity sectionNameFromPrefix:sSourcePrefix trim:YES];
                          
                          [KeyEntity createSection:groupName groupPrefix:sSourcePrefix inContext:[_self managedObjectContext]];
                          
                          //eSource.group = [NSNumber numberWithBool:YES];
                          //[KeyEntity groupByAppendingPrefix:eTarget prefix:sSourcePrefix];
 
                          [eSource groupByPrefix:sSourcePrefix];
                          [eTarget groupByPrefix:sSourcePrefix];
                          
                      }
                          break;
                  }
                  
              };
            
            UIActionSheet * sheet = 
            [[UIActionSheet alloc] initWithTitle:@"Move to section" delegate:self 
                                cancelButtonTitle:@"Cancel" 
                           destructiveButtonTitle:@"Use custom prefix"
                                otherButtonTitles:
                                        [NSString stringWithFormat:@"Use prefix [%@]", sSourcePrefix ], nil];
            
            
            
            [sheet showInView:self.navigationController.view];
            
        }
        else { 
            
            ///////////////////////////////////////////////
            //    
            // ONLY TARGET HAS PREFIX
            //    
            ///////////////////////////////////////////////

            __block id _self = self;

            NSString *sTargetPrefix = [eTarget.mnemonic substringWithRange:rTargetPrefix];

            self.clickedButtonAtIndex = ^( UIActionSheet *as, NSInteger i ){
                  
                  NSLog(@"clickedButtonAtIndex [%d]", i );
                  
                  switch (i) {
                      case 0: // USE CUSTOM PREFIX  
                      {
                          NSLog(@"use custom prefix " );
                          
                          [_self createSectionChoosingCustomSectionPrefix:eSource target:eTarget replaceSource:NO replaceTarget:YES];
                         
                      }
                          break;
                      case 1: // USE FROM PREFIX  
                      {
                          NSLog(@"use target prefix [%@]", sTargetPrefix );
                          
                          NSString *groupKey = [KeyEntity sectionNameFromPrefix:sTargetPrefix trim:YES];
                          
                          [KeyEntity createSection:groupKey groupPrefix:sTargetPrefix inContext:[_self managedObjectContext]];
                          
                          //eTarget.group = [NSNumber numberWithBool:YES];
                          //[KeyEntity groupByAppendingPrefix:eSource prefix:sTargetPrefix];
                          
                          [eSource groupByPrefix:sTargetPrefix];
                          [eTarget groupByPrefix:sTargetPrefix];

                      }
                          break;
                  }
                  
              };
            
            UIActionSheet * sheet = 
            [[UIActionSheet alloc] initWithTitle:@"Move to section" delegate:self 
                                cancelButtonTitle:@"Cancel" 
                           destructiveButtonTitle:@"Use custom prefix"
                                otherButtonTitles: 
                                    [NSString stringWithFormat:@"Use prefix [%@]", sTargetPrefix ], nil];
            
            
            
            [sheet showInView:self.navigationController.view];
            
        }
    }
    
}

#pragma mark - KeyListViewController properties

-(UINavigationController *)navigationController {
    
    if( navigationController_!=nil ) {
        return navigationController_;
    }
    
    return super.navigationController;
}

#pragma mark - actions

- (void)insertNewObject:(id)sender {
    
    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
	KeyEntity *e = [[KeyEntity alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
	
	[self.keyEntityFormController initWithEntity:e delegate:self];
	
    [self.navigationController pushViewController:self.keyEntityFormController animated:YES];
    
	//[e release];
}

#pragma mark - custom implementation

-(BOOL)isSearchTableView:(UITableView*)tableView
{
    return [tableView isEqual:self.searchDisplayController.searchResultsTableView];    
}

-(void)initGestureRecognizer {
    
    swipe_ = [[UISwipeGestureRecognizer alloc] init];
    
    [swipe_ addTarget:self action:@selector(dismissViewSection:)];

    [self.tableView addGestureRecognizer:swipe_];
    
    
}

-(void)initWithNavigationController:(UINavigationController *)controller {
    
    navigationController_ = controller;
}

- (PersistentAppDelegate *)appDelegate {
    
    return (PersistentAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSManagedObjectContext *)managedObjectContext {
    return [[self appDelegate] managedObjectContext];
}

- (void)hideSearchBar:(BOOL)animated {
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];    
    //self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height) animated:animated];
    
}


#pragma mark KeyListViewController - KeyEntityFormControllerDelegate

-(BOOL)doSaveObject:(KeyEntity*)entity {
	
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];	
    
	if (entity.isNew) {
		[context insertObject:entity];
        reloadData_ = YES;
	}
	
 
	NSError *error = nil;
    
	// Save the context.
	if (![context save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//abort();
		
		return NO;
	}

	
	return YES;
}

#pragma mark - KeyListViewControllerView lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    reloadData_ = NO;
	
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
    self.searchDisplayController.searchBar.delegate = self;
    
    [self hideSearchBar:NO];
    
    [self initGestureRecognizer];
    
    dd_ = [[DDTableViewManager alloc ] initFromTableView:self.tableView]; dd_.delegate = self;
    
}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	if( reloadData_ ) {    
        [super.tableView reloadData];
        reloadData_ = NO;
    }
    
    //[self hideSearchBar];
}


/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)configureCell:(UITableViewCell *)cell entity:(KeyEntity *)managedObject {
    
    cell.textLabel.text = [managedObject.mnemonic description];
    
    if (managedObject.isSection) {
        //cell.detailTextLabel.text = NSLocalizedString(@"CellGroup.detailTextLabel", nil);
        cell.detailTextLabel.text = managedObject.groupPrefix;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if( managedObject.isGrouped ) {
        cell.detailTextLabel.text = managedObject.groupPrefix;        
    }
    else {
        cell.textLabel.text = [managedObject.mnemonic description];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    KeyEntity *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self configureCell:cell entity:managedObject];
}

#pragma mark Add/Update a new object


// Deprecated
- (void)insertNewObject2 {
    
	
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier         = @"Cell";
    static NSString *CellGroupIdentifier    = @"CellGroup";
    static NSString *CellSectionIdentifier  = @"CellSection";
    
    KeyEntity *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = nil;
    
    NSLog(@"groupPrefix [%@]", managedObject.groupPrefix);
    
    if ( [managedObject isSection] ) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellSectionIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] 
                     initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellSectionIdentifier];
            cell.imageView.image = [UIImage imageNamed:@"section22x22.png"];
        }        
        
    }
    else if( [managedObject isGrouped] ) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellGroupIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] 
                     initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellGroupIdentifier];

            //[[NSBundle mainBundle] loadNibNamed:@"keygrouped" owner:self options:nil];
            //cell.editingAccessoryView = self.customEditView;
            //self.customEditView = nil;

            // CREATE CUSTOM CLASS TO KEEP TRACK OF SELECTED INDEX
            UIDetachButton *detachView = [[UIDetachButton alloc] initFromCell:cell];
            
            detachView.index = indexPath;
            
            [detachView addTarget:self action:@selector(detachFromSection:) forControlEvents:UIControlEventTouchDown];
            
            cell.editingAccessoryView = detachView;
            
            cell.imageView.image = [UIImage imageNamed:@"key22x22.png"];
        }        

        
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] 
                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.imageView.image = [UIImage imageNamed:@"key22x22.png"];
        }
    }    
    
    [self configureCell:cell entity:managedObject];
    
    return cell;
}




 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    KeyEntity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Return NO if you do not want the specified item to be editable.
    return ![entity isSection];
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        KeyEntity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        [context deleteObject:entity];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray * sectionArray = [self.fetchedResultsController sections];
    
    if (sectionArray.count > section ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sectionArray objectAtIndex:section];	
        
        NSLog(@"titleForHeaderInSection section:[%d] [%@]", section, sectionInfo.name );
        
        return sectionInfo.name;
    }
	
	
	return @"";
	
	
}


#pragma mark - UITableView Index

- (NSArray *)sectionTitlesArray {
	
	if (sectionIndexTitles_==nil) {
		
		sectionIndexTitles_ = [NSMutableArray arrayWithObjects: 
							   @"A", 
							   @"B", 
							   @"C", 
							   @"D", 
							   @"E", 
							   @"F",
							   @"G",
							   @"H",
							   @"I",
							   @"J",
							   @"K",
							   @"L",
							   @"M",
							   @"N",
							   @"O",
							   @"P",
							   @"Q",
							   @"R",
							   @"S",
							   @"T",
							   @"U",
							   @"W",
							   @"V",
							   @"X",
							   @"Y",
							   @"Z",
							   nil ];
	}
	return sectionIndexTitles_;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	// return list of section titles to display in section index view (e.g. "ABCD...Z#")
    
	NSLog(@"sectionIndexTitlesForTableView");
	
	return self.sectionTitlesArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    // tell table which section corresponds to section title/index (e.g. "B",1))
	index = [self.fetchedResultsController.sectionIndexTitles indexOfObject:title];
	
	NSLog(@"sectionForSectionIndexTitle title:[%@] index:[%d]", title, index );
	
	return index;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    KeyEntity *e = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([e isSection] ) {
        
        self.selectedSection = indexPath;
        [self pushViewSection:e];
    }
    else {
        [self.keyEntityFormController initWithEntity:e delegate:self];
        
        [self.navigationController pushViewController:self.keyEntityFormController animated:YES];
	}
    
    
    
    // Navigation logic may go here -- for example, create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    [self filterReset];
    
    return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if( self.searchDisplayController.active ) return;
    
    [self.tableView beginUpdates];

}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if( self.searchDisplayController.active ) return;

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
 
    if( self.searchDisplayController.active ) return;

    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if( self.searchDisplayController.active ) {
        [self.searchDisplayController setActive:NO animated:YES];   
    }
    else {
        [self.tableView endUpdates];
        
    }
}

/*	 
 - (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName  {
 
 
 NSLog(@"sectionIndexTitleForSectionName sectionName:[%@]", sectionName );
 
 return sectionName;
 
 }
 */

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */
#pragma mark -
#pragma mark Content Filtering
#pragma mark -



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    NSPredicate *predicate = nil;
    
    // set predicate if a searchText has been set
    if( searchText !=nil && searchText.length>0 )  {
        predicate = [NSPredicate 
                     predicateWithFormat:SEARCHTEXT_CRITERIA, //@"(mnemonic BEGINSWITH %@ OR mnemonic BEGINSWITH %@) AND (group == NO OR group == nil)", 
                     searchText, [searchText uppercaseString] ]; // autorelease    
    }
    
    
    [self filterContentByPredicate:predicate scope:scope];
    
    
}


- (void)filterContentByPredicate:(NSPredicate *)predicate scope:(NSString *)scope {
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    @autoreleasepool {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = 
        [NSEntityDescription entityForName:@"KeyInfo" inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        
        if (predicate != nil ) {
            
            [fetchRequest setPredicate:predicate];
        }
        
        
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
                                             managedObjectContext:self.managedObjectContext 
                                               sectionNameKeyPath:@"sectionId" 
                                                        cacheName:nil]; 
        
        aFetchedResultsController.delegate = self;
        
        self.fetchedResultsController = aFetchedResultsController;
        
    }
    
    
    NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
}


#pragma mark -
#pragma mark UISearchBarDelegate implementation
#pragma mark -


- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {                    // called when cancel button pressed
    
    NSLog( @"searchBarCancelButtonClicked " );
    
    [self filterReset];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    
    dd_.enabled = YES; // WORKAROUND DD BUG 
}

#pragma mark - UISearchDisplayController Delegate Methods

//  @optional


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"shouldReloadTableForSearchString searchString=[%@]", searchString);
    
    //[self filterContentForSearchText:searchString scope:
    //    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    [self filterContentForSearchText:searchString scope:nil];
    
    dd_.enabled = NO; // WORKAROUND DD BUG  
    
    return YES; // Return YES to cause the search result table view to be reloaded.
}

// called when the table is created destroyed, shown or hidden. configure as necessary.
//- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView;
//- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;

/*
 // when we start/end showing the search UI
 - (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller;
 - (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller;
 - (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller;
 - (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller;
 
 
 // called when table is shown/hidden
 - (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView;
 - (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView;
 - (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView;
 - (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView;
 
 // return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
 - (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption;
 
 */

#pragma mark UIGestureRecognizerDelegate

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
/*
 - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
 }
 */

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
/*
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
 }
 */

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
/*
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
 
 }
 */

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

#pragma mark - UIDetachButton implementation

@implementation UIDetachButton;

@synthesize index;

- (id)initFromCell:(UITableViewCell *)cell 
{
    CGRect rc = CGRectMake(0, 0, 65, cell.frame.size.height-10 );
    
    if( self = [super initWithFrame:rc] ) {

        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0f; 

        
        [self setTitle:@"Detach" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.backgroundColor = [UIColor lightGrayColor];
        
    }
    
    return self;
}

@end
