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
#import "TextDataEntryCell.h"

@implementation KeyEntityFormController
@synthesize toolbar=toolbar_, btnSave=btnSave_, segShowHidePassword=segShowHidePassword_;

#pragma mark Custom
- (void)showError:(NSString *)title msg:(NSString*)msg {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:msg
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

- (void)initWithEntity:(KeyEntity*)entity delegate:(id<KeyEntityFormControllerDelegate>)delegate {
	entity_ = entity;
	saved_ = NO;
	formDelegate_ = delegate;
	
	[self.tableView reloadData];
	[self.segShowHidePassword sendActionsForControlEvents:UIControlEventValueChanged];
	
}

- (IBAction)showHidePassword:(id)sender {

	NSInteger index = [(UISegmentedControl*)sender selectedSegmentIndex];
	
	NSIndexPath *ip = [NSIndexPath indexPathForRow:2 inSection:0]; 
	
	TextDataEntryCell *cell = (TextDataEntryCell*)[self.tableView cellForRowAtIndexPath:ip];
		
	NSLog(@"showHidePassword selectedSegmentIndex=[%d] [%@]", index, cell );
	
	cell.textField.secureTextEntry = (index==0);
	
	[ip release]; 
	
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
		
		NSString *msg = [NSString stringWithFormat:@"Data not valid !\n error %@", [error description]];
		
		NSLog(@"entity not valid for insert/update error %@, %@", error, [error userInfo]);
		
		[self showError:@"Error" msg:msg ];
		
		return;
	}
	
	if (formDelegate_!=nil) {
		saved_ = [formDelegate_ doSaveObject:entity_];
	}
	
	[self.navigationController popViewControllerAnimated:true];
}

-(IBAction) cancel:(id)sender {

	NSLog(@"cancel");
}

#pragma mark UIXMLFormViewControllerDelegate

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell {

	id value = [cell getControlValue];

	NSError *error = nil;
	
	BOOL valid = [entity_ validateValue:&value forKey:cell.dataKey error:&error]; 

	if (!valid) {
		
		NSString *msg = [NSString stringWithFormat:@"value for field [%@] is not valid!", cell.dataKey];

		NSLog(@"value [%@] is not valid! error %@, %@", error, [error userInfo]);
		
		// SHOW ERROR POPUP
		[self showError:@"Error" msg:msg ];

		return;
	}
	[entity_ setValue:[cell getControlValue] forKey:cell.dataKey];
}

-(void)cellControlDidInit:(BaseDataEntryCell *)cell {
	
	NSLog(@"cellControlDidInit [%@]", cell.dataKey );
	id value = [entity_ valueForKey:cell.dataKey];
	
	[cell setControlValue:value];	
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
	
	[self.btnSave setTarget:self];
	[self.segShowHidePassword addTarget:self action:@selector(showHidePassword:) forControlEvents:UIControlEventValueChanged];
	
	UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithCustomView:self.toolbar];
	
	self.navigationItem.rightBarButtonItem = rightButton;
	
	[rightButton release];
	
}

/*
- (void)viewDidDisappear:(BOOL)animated { // Called after the view was dismissed, covered or otherwise hidden. Default does nothing

}
*/

- (void)viewWillAppear:(BOOL)animated { // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
	[super viewWillAppear:animated];
	//[self.tableView reloadData];
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
	[toolbar_ release];
	[btnSave_ release];
	[segShowHidePassword_ release];
    [super dealloc];
}


@end
