//
//  KeyListViewController.h
//  KeyChain
//
//  Created by softphone on 10/02/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXMLFormViewControllerDelegate.h"
#import "KeyEntityFormController.h"
#import "KeyListDataSource.h"
#import "DDTableViewManager.h"

@class KeyEntityFormController;
@class KeyListViewController;
@class ExportViewController;
@class ImportViewController;
@class UIAlertViewInputSection;

@interface KeyListViewController : UITableViewController 
    <
        NSFetchedResultsControllerDelegate,
        KeyEntityFormControllerDelegate,
        UISearchDisplayDelegate,
        UISearchBarDelegate,
        UIGestureRecognizerDelegate,
        DDTableViewManagerDelegate, 
        UIActionSheetDelegate,
        UIAlertViewDelegate
    > 
{
    
@private
    NSFetchedResultsController *fetchedResultsController_;	
    KeyEntityFormController *keyEntityFormController_;
	NSArray *sectionIndexTitles_;
    UINavigationController *navigationController_;
    
    UISwipeGestureRecognizer *swipe_;
    
    DDTableViewManager *dd_; // Drag & Drop manager
    
    BOOL reloadData_;
    
    void (^clickedButtonAtIndex_)( UIActionSheet *actionSheet, NSInteger index );

    UIBarButtonItem *addButton_;
    
}


-(void)initWithNavigationController:(UINavigationController *)controller;

-(IBAction)insertNewObject:(id)sender;
- (NSArray *)fetchedObjects;

//@property (nonatomic, copy) void (^clickedButtonAtIndexAlert)( UIAlertViewInputSection *alertView, NSInteger buttonIndex) ;
@property (nonatomic, copy) void (^clickedButtonAtIndex)( UIActionSheet *actionSheet, NSInteger index );

@property (nonatomic, retain, readonly) NSArray *sectionTitlesArray;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet KeyEntityFormController *keyEntityFormController;
@property(nonatomic,readonly,retain) UINavigationController *navigationController; // If this view controller has been pushed onto a navigation controller, return it.
@end
