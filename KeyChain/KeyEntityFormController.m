//
//  KeyEntityFormController.m
//  KeyChain
//
//  Created by softphone on 11/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyEntityFormController.h"
#import "BaseDataEntryCell.h"
#import "TextDataEntryCell.h"
#import "KeyChainAppDelegate.h"
#import "iToast.h"

@interface KeyEntityFormController( /*Private*/ )

- (void) handleLongPress:(UILongPressGestureRecognizer *)gesture;
- (void)copyToClipboard:(BaseDataEntryCell*)cell;
- (void)playClick;
- (void) setupLongGesture:(BaseDataEntryCell *)cell;
- (BOOL) isPassword:(BaseDataEntryCell *)cell;
@property (assign) BOOL valid;

@end

@implementation KeyEntityFormController

@synthesize toolbar=toolbar_, btnSave=btnSave_, segShowHidePassword=segShowHidePassword_;
@synthesize valid=_valid;

#pragma mark - private implementation

- (BOOL) isPassword:(BaseDataEntryCell *)cell
{
    return [cell.dataKey compare:@"password"]==NSOrderedSame ;
}

-(void)setValid:(BOOL)valid
{
    _valid = valid;
    
    self.btnSave.enabled = valid;
    
}

- (BOOL)valid {
    return _valid;
}

- (void)playClick {
    
    [(KeyChainAppDelegate*)[UIApplication sharedApplication].delegate playClick];
}

- (void)copyToClipboard:(BaseDataEntryCell*)cell {
    [[UIPasteboard generalPasteboard] setValue:[cell getControlValue] forPasteboardType:@"public.utf8-plain-text"];    
    
}

-(void) handleLongPress:(UILongPressGestureRecognizer *)gesture {
    BaseDataEntryCell *cell = (BaseDataEntryCell*)gesture.view;
    
    if(UIGestureRecognizerStateBegan == gesture.state) {
        NSLog(@"UIGestureRecognizerStateBegan");
        [self copyToClipboard:cell];
        iToast *msg = [[iToast alloc] initWithText:NSLocalizedString(@"Toaster.copyToClipboard", @"")];
        [msg show:cell origin:[gesture locationInView:cell]];
        
        return;
    }
    
    if(UIGestureRecognizerStateChanged == gesture.state) {
        NSLog(@"UIGestureRecognizerStateChanged");
        return;
    }
    
    if(UIGestureRecognizerStateEnded == gesture.state) {
        NSLog(@"UIGestureRecognizerStateEnded");
        [self playClick];
        
    }
    
}

- (void) setupLongGesture:(BaseDataEntryCell *)cell {
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self 
                                               action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.2;
    [cell addGestureRecognizer:longPress];
    
}

#pragma mark - public implementation

- (void)showError:(NSString *)title msg:(NSString*)msg {


	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:msg
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];

}

- (void)initWithEntity:(KeyEntity*)entity delegate:(NSObject<KeyEntityFormControllerDelegate>*) delegate {
	
	entity_ = entity;
	
    self.valid = NO;
	
    formDelegate_ = delegate;
	
	[self.tableView reloadData];
	[self.segShowHidePassword sendActionsForControlEvents:UIControlEventValueChanged];
	
	BaseDataEntryCell *cell  = [super cellForIndexPath:0 section:0];
		
	cell.enabled = entity_.isNew;
	
}

- (IBAction)showHidePassword:(id)sender {

	NSInteger index = [(UISegmentedControl*)sender selectedSegmentIndex];
	
	TextDataEntryCell *cell = (TextDataEntryCell*)[self cellForIndexPath:2 section:0];
		
	NSLog(@"showHidePassword selectedSegmentIndex=[%ld] [%@]", (long)index, cell );
	
	cell.textField.secureTextEntry = (index==0);
	
	//[ip release]; 
	
}

- (IBAction)save:(id)sender {

	NSLog( @"save" );

	[self.view.window endEditing: YES];
	
	NSError *error = nil;
	
	if (!self.valid) {
		return;
	}
    
	if (entity_.isNew) {
		_valid = [entity_ validateForInsert:&error];
	}
	else {
		_valid = [entity_ validateForUpdate:&error];
	}
	
	if (!_valid) {
		
		NSLog(@"entity not valid for insert/update error %@, %@", error, [error userInfo]);

		//[self showError:@"Error" msg:[NSString stringWithFormat:@"Data not valid !\n error %@", [error description]] ];
        
        [KeyChainAppDelegate showMessagePopup:@"Input Data are not valid!" title:@"Error"];
        
		return;
	}
    
    
	if (formDelegate_!=nil && [formDelegate_ respondsToSelector:@selector(doSaveObject:)]) {
		_valid = [formDelegate_ doSaveObject:entity_];
	}
	
	[self.navigationController popViewControllerAnimated:true];
}

-(IBAction) cancel:(id)sender {

	NSLog(@"cancel");
	
	[super unregisterControEditingNotification];
	
	[self.view.window endEditing: YES];
	
	[self.navigationController popViewControllerAnimated:true];

	[super registerControEditingNotification];
}


#pragma mark UIXMLFormViewControllerDelegate

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell {

	id value = [cell getControlValue];

	NSLog(@"[%@].cellControlDidEndEditing [%@]", cell.dataKey, value);

	NSError *error = nil;
	
	self.valid = [entity_ validateValue:&value forKey:cell.dataKey error:&error];

	if (!self.valid) {
		
		NSLog(@"value [%@] is not valid! error %@", error, [error userInfo]);
		
		// SHOW ERROR POPUP
		//[self showError:@"Error" msg:[NSString stringWithFormat:@"value for field [%@] is not valid!", cell.dataKey] ];
        [KeyChainAppDelegate showMessagePopup:[NSString stringWithFormat:@"value for field [%@] is not valid!", cell.dataKey] title:@"error"];
        
        
        if( [self isPassword:cell]  ) {
            [cell setControlValue:entity_.password2 ];
        }
        else {
            [cell setControlValue:[entity_ valueForKey:cell.dataKey]];
        }
	}
	else {
        if( [self isPassword:cell]  ) {
            entity_.password2 = value;
        }
        else {
            [entity_ setValue:value forKey:cell.dataKey];
        }
	}
}

-(void)cellControlDidInit:(BaseDataEntryCell *)cell cellData:(NSDictionary *)cellData {
	
	NSLog(@"[%@].cellControlDidInit ", cell.dataKey  );
	
    if( [self isPassword:cell]  ) {
        [cell setControlValue:entity_.password2 ];
        
    }
    else {
        id value = [entity_ valueForKey:cell.dataKey];
        [cell setControlValue:value];
    }
}

-(void)cellControlDidLoad:(BaseDataEntryCell *)cell cellData:(NSDictionary *)cellData {
	
	NSLog(@"[%@].cellControlDidLoad", [cellData objectForKey:@"DataKey"]  );
	
    NSNumber *allowLongGesture = [cellData objectForKey:@"allowLongGesture"];
    
    if ( allowLongGesture!=nil && [allowLongGesture boolValue]) {
        
        [self setupLongGesture:cell];
    }
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
	
	//

	UIBarButtonItem *leftButton = 
		[[UIBarButtonItem alloc] initWithTitle:@"Back"
									 style:UIBarButtonItemStyleBordered
									target:self
									action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = leftButton;
	
	UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithCustomView:self.toolbar];
	
	self.navigationItem.rightBarButtonItem = rightButton;
	
}


/*
 - (void)viewDidAppear:(BOOL)animated {     // Called when the view has been fully transitioned onto the screen. Default does nothing
    
    [self.navigationController setNavigationBarHidden:NO]; 
    [super viewDidAppear:animated];
    
}


- (void)viewDidDisappear:(BOOL)animated { // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
}


*/
- (void)viewWillAppear:(BOOL)animated { // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
    [self.navigationController setNavigationBarHidden:NO]; 
	[super viewWillAppear:animated];

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




@end
