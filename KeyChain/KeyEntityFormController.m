//
//  KeyEntityFormController.m
//  KeyChain
//
//  Created by softphone on 11/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyEntityFormController.h"
#import "KeyEntity.h"
#import "BaseDataEntryCell.h"

@implementation KeyEntityFormController
@synthesize btnSave;

#pragma mark Custom

- (void)initWithEntity:(KeyEntity*)entity {
	entity_ = entity;
	saved_ = NO;
}

- (IBAction)save:(id)sender {

	NSLog( @"save" );
	
	NSError *error = nil;
	
	BOOL valid;
	
	if (entity_.isNew) {
		valid = [entity_ validateForInsert:&error];
	}
	else {
		valid = [entity_ validateForUpdate:&error];
	}
	
	if (!valid) {
		NSLog(@"entity not valid for insert/update error %@, %@", error, [error userInfo]);
	}
	else {
		NSManagedObjectContext *context = entity_.managedObjectContext ;

		// Save the context.
		if (![context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//abort();
		}
	}
	
	saved_ = YES;
	[self.navigationController popViewControllerAnimated:true];
}

#pragma mark UIXMLFormViewControllerDelegate

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell {

	id value = [cell getControlValue];

	NSError *error = nil;
	
	BOOL valid = [entity_ validateValue:&value forKey:cell.dataKey error:&error]; 

	if (!valid) {
		// SHOW ERROR POPUP
		NSLog(@"value [%@] is not valid! error %@, %@", error, [error userInfo]);
		return;
	}
	[entity_ setValue:[cell getControlValue] forKey:cell.dataKey];
}

-(void)cellControlDidInit:(BaseDataEntryCell *)cell {
	
	NSLog(@"cellControlDidInit");
	[cell setControlValue:[entity_ valueForKey:cell.dataKey]];	
}



#pragma mark UIViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super loadFromFile:@"KeyEntityForm.plist"];
	
	[super viewDidLoad];
	
	[btnSave setTarget:self];
	self.navigationItem.rightBarButtonItem = self.btnSave;

	[self.navigationItem.backBarButtonItem setTarget:self];
	[self.navigationItem.backBarButtonItem setAction:@selector(cancel:)];
	
	
}

- (void)viewDidDisappear:(BOOL)animated { // Called after the view was dismissed, covered or otherwise hidden. Default does nothing

	NSLog(@"viewDidDisappear entity IUDF [%d%d%d%d] isNew [%d]", [entity_ isInserted], [entity_ isUpdated], [entity_ isDeleted], [entity_ isFault], [entity_ isNew]);
	
	NSManagedObjectContext *context = entity_.managedObjectContext ;
	
	if (!saved_ ) {
		if( entity_.isNew ) 
			[context deleteObject:entity_ ];
		return;
	}
	

}
- (void)viewWillAppear:(BOOL)animated { // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[entity_ release];
	[btnSave release];
    [super dealloc];
}


@end
