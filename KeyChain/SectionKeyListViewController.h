//
//  SectionKeyListViewController.h
//  KeyChain
//
//  Created by softphone on 02/08/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "UIXML/UIXMLFormViewControllerDelegate.h"
#import "KeyEntityFormController.h"
#import "KeyListDataSource.h"
#import "ZKRevealingTableViewCell/ZKRevealingTableViewCell.h"

@class KeyEntityFormController;
@class KeyListViewController;
@class UIAlertViewInputSection;
@class ZKRevealingTableViewCell;


@interface SectionKeyListViewController : UITableViewController
    <
        NSFetchedResultsControllerDelegate,
        KeyListDataSource,
        KeyEntityFormControllerDelegate,
        UIActionSheetDelegate,
        UIAlertViewDelegate,
        ZKRevealingTableViewCellDelegate
    > 
{
    
@private
    NSFetchedResultsController *fetchedResultsController_;	
    KeyEntityFormController *keyEntityFormController_;
	NSArray *sectionIndexTitles_;
    UINavigationController *navigationController_;
    
    BOOL reloadData_;
    
    void (^clickedButtonAtIndex_)( UIActionSheet *actionSheet, NSInteger index );
    
    UIBarButtonItem *addButton_;
    
    NSIndexPath *selectedSection;
    
    dispatch_block_t _onDisappear;
}


-(IBAction)insertNewObject:(id)sender;
-(void)filterContentByPredicate:(NSPredicate *)predicate scope:(NSString *)scope;
-(void)prepareForAppear:(KeyEntity *)section onDisappear:(dispatch_block_t)onDisappear;

@property (nonatomic, copy) void (^clickedButtonAtIndex)( UIActionSheet *actionSheet, NSInteger index );
@property (nonatomic, readonly) NSArray *sectionTitlesArray;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) IBOutlet KeyEntityFormController *keyEntityFormController;

@property (unsafe_unretained, nonatomic) IBOutlet ZKRevealingTableViewCell *keyCell;

@end



@interface UIDetachButton : UIButton {
    
@private
    
    NSIndexPath *index;
}

@property(nonatomic,copy) NSIndexPath *index;

- (id)initFromCell:(UITableViewCell *)cell;

@end

