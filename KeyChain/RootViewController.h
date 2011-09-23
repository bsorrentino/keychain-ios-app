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

@class KeyEntityFormController;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate,KeyEntityFormControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate> {

@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
	
    KeyEntityFormController *keyEntityFormController_;
	
	NSArray *sectionIndexTitles_;
    
    UIToolbar *toolbar_;
}

@property (nonatomic, retain, readonly) NSArray *sectionTitlesArray;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet KeyEntityFormController *keyEntityFormController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

-(IBAction)settings:(id)sender;
-(IBAction)insertNewObject:(id)sender;

@end
