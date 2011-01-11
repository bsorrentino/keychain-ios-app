//
//  KeyEntityFormController.m
//  KeyChain
//
//  Created by softphone on 11/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyEntityFormController.h"
#import "KeyEntity.h"


@implementation KeyEntityFormController

#pragma mark Custom

- (void)initWithEntity:(KeyEntity*)entity {

}

- (IBAction)save:(id)sender {

}

#pragma mark UIXMLFormViewControllerDelegate

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell {
}

-(void)cellControlDidInit:(BaseDataEntryCell *)cell {
	
}


#pragma mark UINavigationBarDelegate

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {

	NSLog(@"didPopItem");

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
	
}

- (void)viewDidDisappear:(BOOL)animated { // Called after the view was dismissed, covered or otherwise hidden. Default does nothing

	NSLog(@"viewDidDisappear");
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
    [super dealloc];
}


@end
