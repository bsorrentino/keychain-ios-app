//
//  SectionKeyListViewController.m
//  KeyChain
//
//  Created by softphone on 02/08/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "SectionKeyListViewController.h"


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
#import "ZKRevealingTableViewCell/ZKRevealingTableViewCell.h"

static NSString *SEARCH_CRITERIA =
    @"(groupPrefix != nil AND group != nil AND groupPrefix == %@ AND group == YES)";

@interface SectionKeyListViewController ( /*Private*/ )

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell entity:(KeyEntity *)managedObject;

- (PersistentAppDelegate *) appDelegate;

- (NSManagedObjectContext *)managedObjectContext;

@property (unsafe_unretained, nonatomic) KeyEntity *section;

@end


@interface SectionKeyListViewController (Section) {
    
}

- (NSRange)getSectionPrefix:(NSString*)key;
- (void)setNavigationTitle:(NSString*)title;
- (BOOL)touchUpInsideEditButton;

- (IBAction)detachFromSection:(id)sender;

@end


@implementation SectionKeyListViewController

@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize keyEntityFormController=keyEntityFormController_;
@synthesize clickedButtonAtIndex=clickedButtonAtIndex_;
@synthesize keyCell;
@synthesize section=section_;

#pragma mark - KeyListDataSource implementation

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

- (void)filterReset:(BOOL)reloadData {

    
    NSAssert(self.section!=nil,@"section is nil");
    
    if( self.section == nil ) return;
    
    NSLog(@"filter data for section [%@] and prefix [%@]",
            self.section.mnemonic,
          self.section.groupPrefix );
    
    NSPredicate *predicate = [NSPredicate
                                predicateWithFormat:SEARCH_CRITERIA,
                                self.section.groupPrefix
                              ]; // autorelease

    [self filterContentByPredicate:predicate scope:nil];
    
    reloadData_ = reloadData;
}

#pragma mark - Content Filtering

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
        
        NSSortDescriptor *sortDescriptor =
        [NSSortDescriptor sortDescriptorWithKey:@"mnemonic" ascending:YES];
        
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



#pragma mark - Section implementation

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

-(void)prepareForAppear:(KeyEntity *)section onDisappear:(dispatch_block_t)onDisappear
{
    
    NSParameterAssert(section!=nil);
    
    if( section == nil ) {
        [NSException raise:NSInvalidArgumentException format:@"section is null!"];
    }
    
    _onDisappear = onDisappear;
    
    section_ = section;
    
    self.navigationItem.title = section.mnemonic;
    
    [self filterReset:YES];
    

    
}

- (PersistentAppDelegate *)appDelegate {
    
    return (PersistentAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSManagedObjectContext *)managedObjectContext {
    return [[self appDelegate] managedObjectContext];
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	if( reloadData_ ) {    
        [super.tableView reloadData];
        reloadData_ = NO;
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

 - (void)viewWillDisappear:(BOOL)animated {
     
     [super viewWillDisappear:animated];
     
     if (_onDisappear != nil ) {
         _onDisappear();
     }
 }



/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
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
    //cell.detailTextLabel.text = managedObject.groupPrefix;
   
    
    if ([cell isKindOfClass:[ZKRevealingTableViewCell class]]) {
        
        ZKRevealingTableViewCell *revealCell = (ZKRevealingTableViewCell *)cell;
        
        UILabel *label = (UILabel *)[revealCell.backView viewWithTag:1];
        
        label.text = [managedObject valueForKey:@"password"];
        
    }


}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    KeyEntity *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self configureCell:cell entity:managedObject];
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
    
    static NSString *CellGroupIdentifier    = @"Cell";
    
    KeyEntity *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ZKRevealingTableViewCell *cell = nil;
    
    NSLog(@"groupPrefix [%@]", managedObject.groupPrefix);
    
    NSAssert([managedObject isGrouped], @"Only grouped cell canbe displayed here!");
    
    if ( [managedObject isSection] ) {
        
        [NSException raise:@"Illegal call!" format:@"Section cell cannot be displayed here!"];
        
    }
    else if( [managedObject isGrouped] ) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellGroupIdentifier];
        if (cell == nil) {
 
            [[NSBundle mainBundle] loadNibNamed:@"KeyCell" owner:self options:nil];
            cell = self.keyCell; self.keyCell = nil;
                    
            UIDetachButton *detachView = [[UIDetachButton alloc] initFromCell:cell];
            
            detachView.index = indexPath;
            
            [detachView addTarget:self action:@selector(detachFromSection:) forControlEvents:UIControlEventTouchDown];
            
            cell.editingAccessoryView = detachView;
        }
        
        
    }
    else {
        [NSException raise:@"Illegal call!" format:@"Ungrouped  cell cannot be displayed here!"];
        
    }    
    
    [self configureCell:cell entity:managedObject];
    
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
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
        
        [NSException raise:@"Illegal call!" format:@"Section cell cannot be selected here!"];
    }
    else {
        [self.keyEntityFormController initWithEntity:e delegate:self];
        
        [self.navigationController pushViewController:self.keyEntityFormController animated:YES];
	}
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    NSAssert( fetchedResultsController_ != nil, @"fetched result controller is nil!");
    
    return fetchedResultsController_;
}


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
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
    [self.tableView endUpdates];
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

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [self setKeyCell:nil];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


#pragma mark - ZKRevealingTableViewCellDelegate

//@optional

/*
 - (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell;
 - (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell;
 - (void)cellDidReveal:(ZKRevealingTableViewCell *)cell;
 */


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
