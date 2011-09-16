    //
//  FormViewController.m
//  TableViewDataEntry
//
//  Created by softphone on 20/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FormViewController.h"
#import "BaseDataEntryCell.h"
#import "FormData.h"

@implementation FormViewController

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
	
	[self loadFromFile:@"form-structure.plist"];
	
	[self setTitle:@"FORM"];
	
	data = [[FormData alloc] init];
	
	//NSDate *today = [[NSDate alloc] init];
	
	NSDateFormatter * fmt = [[NSDateFormatter alloc] init]; fmt.dateFormat = @"yyyy-MM-dd";
							 
					   
	NSDate *birthDay = [fmt dateFromString:@"1997-10-03"];
	
	[data.model setValue: birthDay forKey:@"birthDay" ];
	[data.model setValue: @"M" forKey:@"gender" ];
	[data.model setValue: [NSNumber numberWithBool:NO] forKey:@"enabled" ];
	[data.model setValue: @"Simone" forKey:@"firstName" ];
	[data.model setValue: @"Sorrentino" forKey:@"lastName" ];
	[data.model setValue: @"list" forKey:@"list" ];
	[data.model setValue: @"about:blank" forKey:@"url" ];
	
	[fmt release];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) viewWillAppear:(BOOL)animated {
	//[self.tableView reloadData]; // initialize data
}

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
	[data release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIXMLFormViewController 

/*
-(void)cellControlDidEndEditingNotify:(NSNotification *)notification {

	// Need to avoid duplicate notification
}
*/

#pragma mark -
#pragma mark UIXMLFormViewControllerDelegate 

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell {
	
	NSLog(@"FormViewController value [%@] for key [%@]",  [cell getControlValue], cell.dataKey);
	
}

-(void)cellControlDidInit:(BaseDataEntryCell *)cell cellData:(NSDictionary *)cellData {
	
	
	id value = [data.model valueForKey:cell.dataKey];  

	NSLog(@"FormViewController Init cell for key [%@] value [%@]",  cell.dataKey, value);
	
	if( value != nil ) 
		[cell setControlValue:value];
	
}

@end
