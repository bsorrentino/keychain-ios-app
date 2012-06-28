//
//  ListDataEntryCell.m
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 8/30/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "MailListDataEntryCell.h"
#import "KeyChainAppDelegate.h"
#import "AttributeInfo.h"
#import <AVFoundation/AVAudioPlayer.h>

#define TRACE_ENTER( m ) NSLog( @"enter in [%@]", @#m )

NSString * const regularExpression = @"(.*)@(.*)";

@interface MailListDataEntryCell(Private) 

@end


@implementation MailListDataEntryCell

@synthesize listViewController=listViewController_;
@synthesize textValue=textValue_;
@synthesize textLabel=textLabel_;

#pragma - private implementation


#pragma - DataEntryCell 


-(id)init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData
{
    if( [super init:controller datakey:key label:label cellData:cellData]!=nil ) {
         //self.detailTextLabel.text = @"test1";
    }
    
    return self;
    
}


-(UIViewController *)viewController:(NSDictionary*)cellData {
    
    self.listViewController.cell = self;
    
    return self.listViewController;
}

-(void) setControlValue:(id)value
{
	if (value==nil) {
		self.textValue.text = @"";
	}
	else {
		self.textValue.text = value;
	}
}

-(id) getControlValue
{
	return self.textValue.text;
}


@end



@interface MailListDataViewController(Private) 

- (void)insertNewObject;
- (PersistentAppDelegate *) appDelegate;
- (void)filterContent:(NSString*)scope;
- (NSInteger)numberOfObjectsInSection:(NSInteger)section;

- (void)insertManagedObject:(NSString *)value;
- (void)deleteManagedObject:(NSIndexPath *)indexPath;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)validateInput:(NSString *)input;
@end


@implementation MailListDataViewController

@synthesize cell=cell_;
@synthesize fetchedResultsController=fetchedResultsController_;

#pragma mark - private method

- (PersistentAppDelegate *)appDelegate {
 
    return (PersistentAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)deleteManagedObject:(NSIndexPath *)indexPath {
                             
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                             
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
        */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    

}


- (BOOL) validateInput:(NSString*)input {
    
    if (input == nil ) {
        return NO;
    }
    
    if( regex_ == nil ) {
        return YES;
    }
    
    
    NSUInteger numberOfMatches = [regex_ numberOfMatchesInString:input
                                                        options:0
                                                        range:NSMakeRange(0, [input length])];
    return numberOfMatches > 0;
}


- (void)insertManagedObject:(NSString *)value {
    
    
    if (![self validateInput:value]) {
        NSLog(@"input string not valid");
        return;
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];

    //NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    AttributeInfo *e = [NSEntityDescription insertNewObjectForEntityForName:@"AttributeInfo" inManagedObjectContext:context];
    e.value = value;
    e.type = [NSNumber numberWithInt:MAIL_TYPE];

    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error  
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during 
        // development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
    //[e release];


}


- (NSInteger) numberOfObjectsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSUInteger result =  [sectionInfo numberOfObjects];
   
    NSLog( @"numberOfObjectsInSection:%d=%d", section, result);
    
    return result;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    AttributeInfo *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (regex_ !=nil ) {
        NSArray *matches = [regex_ matchesInString:managedObject.value
                                                            options:0
                                                               range:NSMakeRange(0, [managedObject.value length])];
        if (matches!=nil && [matches count] > 0) {
            
            NSTextCheckingResult *domain = [matches objectAtIndex:0];
            
            cell.textLabel.text = [managedObject.value substringWithRange:[domain rangeAtIndex:2]];
            cell.detailTextLabel.text = managedObject.value;
            
            return;
            
        }     
    }
    
    cell.textLabel.text = managedObject.value;
    //cell.textLabel.text = [NSString stringWithFormat:@"[%d] %@ ", managedObject.type.intValue , managedObject.value];
}

- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
    cell.textLabel.text = @"";
}


- (void)filterContent:(NSString*)scope
{
    
    NSManagedObjectContext *_managedObjectContext = [self appDelegate].managedObjectContext;
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AttributeInfo" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // set predicate if a searchText has been set
    /*
    if( searchText !=nil && searchText.length>0 )  {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mnemonic BEGINSWITH %@", [searchText uppercaseString] ]; // autorelease    
        [fetchRequest setPredicate:predicate];
    }
    */
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithInt:MAIL_TYPE]]; // autorelease    
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:5];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    fetchedResultsController_ = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:_managedObjectContext 
															 sectionNameKeyPath:nil 
															 cacheName:nil];
    fetchedResultsController_.delegate = self;
    
    
    
    
}

- (void) insertNewObject
{
    ;
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle: NSLocalizedString(@"ListDataEntryCell.alertTitle", @"add new Item") 
						  message:NSLocalizedString(@"ListDataEntryCell.alertMessage", @"add item message") 
						  delegate:self
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"OK", nil];
    
	// Name field
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
    tf.tag = 100;
    tf.keyboardType = UIKeyboardTypeEmailAddress;
    tf.placeholder = NSLocalizedString(@"ListDataEntryCell.alertPlaceholder", @"add item placeholder");
    [tf setBackgroundColor:[UIColor whiteColor]]; 
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.keyboardType = UIKeyboardTypeAlphabet;
	tf.keyboardAppearance = UIKeyboardAppearanceAlert;
	tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
	tf.autocorrectionType = UITextAutocorrectionTypeNo;
    [tf becomeFirstResponder];
    [alert addSubview:tf];	

    //CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
    //[alert setTransform:transform];
    
	[alert show];
    
	
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1 ) {
        UITextField *tf = (UITextField*)[alertView viewWithTag:100];
        
        [self insertManagedObject:tf.text];
        
        //NSInteger count = [self numberOfObjectsInSection:0];
        
        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
        //NSArray *indexs = [[NSArray alloc] initWithObjects:indexPath, nil];
        
        //[self.tableView insertRowsAtIndexPaths:indexs withRowAnimation:YES];
        
        //[indexs release];
    }
    //[alertView release];
}



#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    [self filterContent:nil];
    
    return fetchedResultsController_;
}

#pragma mark - Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add Edit Button
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    */
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    regex_ = [[NSRegularExpression alloc] initWithPattern:regularExpression
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    if (error) {
        NSLog(@"error creating regexp for patter[%@]\n %@", regularExpression, [error userInfo]);
        regex_ = nil;
    }
    
    self.title = NSLocalizedString(@"ListDataEntryCell.title", @"select item title");}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    TRACE_ENTER(setEditing);
    
    if( editing==NO ) {
        NSInteger count = [self numberOfObjectsInSection:0];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];            
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = @"";
        
        //[indexPath release]; BUG FIX Issue #6

    }
    [super setEditing:editing animated:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    TRACE_ENTER(numberOfRowsInSection);
    
    return [self numberOfObjectsInSection:section] + 1;
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TRACE_ENTER(cellForRowAtIndexPath);
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ListDataEntryCell"];

    if( cell==nil )  {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ListDataEntryCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    NSInteger count = [self numberOfObjectsInSection:0];
    
    if ( indexPath.row < count ) {
        
        [self configureCell:cell atIndexPath:indexPath];
        
    }
    else {
        [self clearCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    TRACE_ENTER(commitEditingStyle);
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            [self deleteManagedObject:indexPath];
            
            //NSArray *indexs = [[NSArray alloc] initWithObjects:indexPath, nil];            
            //[tableView deleteRowsAtIndexPaths:indexs withRowAnimation:YES];     
            //[indexs release];

        }
        break;
        case UITableViewCellEditingStyleInsert:
        {
            NSLog( @"commitEditingStyle: UITableViewCellEditingStyleInsert");
            [self insertNewObject];
 
        }   
        break;
        case UITableViewCellEditingStyleNone: 
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
        if( indexPath.row >= [self numberOfObjectsInSection:indexPath.section] ) return; // Fix Issue 3
    
        AttributeInfo *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
        [cell_ setControlValue:managedObject.value];
        [cell_ postEndEditingNotification];
        
        [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    TRACE_ENTER(editingStyleForRowAtIndexPath);

    NSInteger count = [self numberOfObjectsInSection:0];
    
    if( indexPath.row == count  ) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        cell.detailTextLabel.text = NSLocalizedString(@"ListDataEntryCell.addItemMessage", @"add new item message");

        //[indexPath release]; // BUG FIX Issue #6
        
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleDelete;
    
}


 
#pragma mark - Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    TRACE_ENTER(controllerWillChangeContent);

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

	 
 - (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName  {
 
     NSLog(@"sectionIndexTitleForSectionName sectionName:[%@]", sectionName );
 
     return sectionName;
 
 }




@end
