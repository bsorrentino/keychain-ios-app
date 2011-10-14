//
//  RootViewController.h
//  KeyChain
//
//  Created by softphone on 15/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UIXMLFormViewControllerDelegate.h"
#import "KeyEntityFormController.h"
#import "KeyEntity.h"
#import "KeyListDataSource.h"

@class KeyEntityFormController;
@class KeyListViewController;
@class ExportViewController;
@class ImportViewController;

@interface RootViewController : UIViewController<KeyListDataSource>  {
    
@private
    KeyListViewController *keyListViewController_;
    ExportViewController *exportViewController_;
    ImportViewController *importViewController_;
	
}

@property (nonatomic, retain) IBOutlet KeyListViewController *keyListViewController;
@property (nonatomic, retain) IBOutlet ExportViewController *exportViewController;
@property (nonatomic, retain) IBOutlet ImportViewController *importViewController;

-(IBAction)changePassword:(id)sender;
-(IBAction)export:(id)sender;
-(IBAction)import:(id)sender;


@end



@interface KeyListViewController : UITableViewController <NSFetchedResultsControllerDelegate,KeyEntityFormControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate> {

@private
    NSFetchedResultsController *fetchedResultsController_;
	
    KeyEntityFormController *keyEntityFormController_;
	
	NSArray *sectionIndexTitles_;
    
    UINavigationController *navigationController_;
}

-(void)initWithNavigationController:(UINavigationController *)controller;

-(IBAction)insertNewObject:(id)sender;

@property (nonatomic, retain, readonly) NSArray *sectionTitlesArray;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet KeyEntityFormController *keyEntityFormController;

@property(nonatomic,readonly,retain) UINavigationController *navigationController; // If this view controller has been pushed onto a navigation controller, return it.

@end
