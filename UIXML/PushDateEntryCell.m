    //
//  PushDateEntryCell.m
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PushDateEntryCell.h"

@implementation PushDateEntryCell

@synthesize viewController, textLabel,txtValue;



#pragma mark -
#pragma mark inherit from PushControllerDataEntryCell 



-(void)postEndEditingNotification {
	
	NSString * result =  [_dateFormatter stringFromDate:viewController.datePicker.date ];

	NSLog(@"date to String [%@]", result );
	
	self.txtValue.text = result;
	
	[super postEndEditingNotification];
}

-(UIViewController *)viewController:(NSDictionary*)cellData {
	
	//detailViewController.delegate = super.owner.delegate;
	
	[viewController initWithCell:self];
	return [viewController retain];
}

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData{
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {
        // Initialization code
		NSString *placeholder = [cellData objectForKey:@"placeholder"];
		
		if( ![self isStringEmpty:placeholder] ) {
			
			[txtValue setPlaceholder:placeholder];
		}
		_dateFormatter = [[NSDateFormatter alloc] init];

		NSString *format = [cellData objectForKey:@"format"];
		
		if( ![self isStringEmpty:format] ) {
			
			[_dateFormatter setDateFormat:format];
		}
		else {
			[_dateFormatter setDateStyle:kCFDateFormatterMediumStyle];
		}
		
    }
	
	return self;
}

-(void) setControlValue:(id)value {
	
	if (value==nil) {
		return;
	}
	NSString * result =  [_dateFormatter stringFromDate:value ];

	NSLog(@"PushDateEntryCell.setControlValue([%@]) asString [%@]", value, result );
	
	[viewController.datePicker setDate:value];
	
	self.txtValue.text = result;
}

-(id) getControlValue {
	
	NSDate *date = viewController.datePicker.date;

	NSLog(@"PushDateEntryCell.getControlValue [%@]", date );
	
	return date; 
}

-(NSLocale *)locale {
	
	return _dateFormatter.locale;
	
}


- (void) dealloc {
	
	[_dateFormatter release];
	[super dealloc];
}
@end


@implementation PushDateViewController;

@synthesize datePicker;


- (void) initWithCell:(PushDateEntryCell*)cell {

	_cell = cell;
	
	[self setTitle:cell.textLabel.text];
	
	
	
}

- (IBAction) selectValue: (id)sender {
	
	UIDatePicker *control = sender;
	
	NSLog( @"selectValue [%@]", control );
	
	[_cell postEndEditingNotification];
	
 }

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

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
    [super dealloc];
}

@end