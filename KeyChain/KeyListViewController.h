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
        KeyListDataSource,
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
    
    NSIndexPath *selectedSection;
    
}


-(void)initWithNavigationController:(UINavigationController *)controller;

-(IBAction)insertNewObject:(id)sender;
- (NSArray *)fetchedObjects;
- (void)filterContentByPredicate:(NSPredicate *)predicate scope:(NSString *)scope;

//@property (nonatomic, copy) void (^clickedButtonAtIndexAlert)( UIAlertViewInputSection *alertView, NSInteger buttonIndex) ;
@property (nonatomic, copy) void (^clickedButtonAtIndex)( UIActionSheet *actionSheet, NSInteger index );

@property (nonatomic, readonly) NSArray *sectionTitlesArray;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) IBOutlet KeyEntityFormController *keyEntityFormController;
@property(nonatomic,readonly) UINavigationController *navigationController; // If this view controller has been pushed onto a navigation controller, return it.

@property(nonatomic,copy) NSIndexPath *selectedSection;

@end


@interface UIDetachButton : UIButton {

@private

    NSIndexPath *index;
}

@property(nonatomic,copy) NSIndexPath *index;

- (id)initFromCell:(UITableViewCell *)cell;

@end



