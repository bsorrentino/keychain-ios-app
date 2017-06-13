    //
//  PushDateEntryCell.m
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PushDateEntryCell.h"

@implementation PushDateEntryCell

@synthesize viewController,txtValue, dateFormatter=dateFormatter_;
//@synthesize textLabel;



#pragma mark -
#pragma mark inherit from PushControllerDataEntryCell 

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect rect = [super getRectRelativeToLabel:txtValue.frame padding:LABEL_CONTROL_PADDING rpadding:RIGHT_PADDING];
	[self.txtValue setFrame:rect];
}


-(void)postEndEditingNotification {
	
	NSString * result =  [dateFormatter_ stringFromDate:viewController.datePicker.date ];

	NSLog(@"date to String [%@]", result );
	
	self.txtValue.text = result;
	
	[super postEndEditingNotification];
}

-(UIViewController *)viewController:(NSDictionary*)cellData {
	
	//detailViewController.delegate = super.owner.delegate;
	
	[viewController initWithCell:self];
	return viewController;
}

- (void) prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString*)key cellData:(NSDictionary*)cellData{
	
    [super prepareToAppear:controller datakey:key cellData:cellData];
    // Initialization code
    NSString *placeholder = [cellData objectForKey:@"placeholder"];
    
    if( ![self isStringEmpty:placeholder] ) {
        
        [txtValue setPlaceholder:placeholder];
    }

    NSString *format = [cellData objectForKey:@"format"];
    
    if( ![self isStringEmpty:format] ) {
        
        [self.dateFormatter setDateFormat:format];
    }
    else {
        [self.dateFormatter setDateStyle:kCFDateFormatterMediumStyle];
    }
		
}

// Getter
-(NSDateFormatter *)dateFormatter {
	if (dateFormatter_ == nil ) {
		dateFormatter_ = [[NSDateFormatter alloc] init];
	}
	return dateFormatter_;
}

- (NSString *) stringFromDate:(NSDate *)value {
	if (value==nil) {
		return @"";
	}

	NSString * result =  [self.dateFormatter stringFromDate:value ];
	
	return result;
}

-(void) setControlValue:(id)value {
	
	if (value==nil) {
		self.txtValue.text = @"";
		return;
	}
	NSString * result =  [self stringFromDate:value ];

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
	
	return self.dateFormatter.locale;
	
}


@end


@implementation PushDateViewController;

@synthesize datePicker, btnSave, txtValue;


- (void) initWithCell:(PushDateEntryCell*)cell {

	_cell = cell;
	
	[self setTitle:cell.textLabel.text];
	
}

- (IBAction) selectValue: (id)sender {
	
	NSLog( @"selectValue [%@]", self.datePicker );
	
	NSString * value = [_cell stringFromDate:self.datePicker.date];
	
	txtValue.text = value;
	
 }

- (IBAction) saveValue: (id)sender {
	
	NSLog( @"saveValue [%@]", self.datePicker );
	
	[_cell postEndEditingNotification];
	
	[self.navigationController popViewControllerAnimated:YES];
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


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 [btnSave setTarget:self];
	 self.navigationItem.rightBarButtonItem = self.btnSave;


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
