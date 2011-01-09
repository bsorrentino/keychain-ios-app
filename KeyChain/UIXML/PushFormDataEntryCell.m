//
//  PushDataEntryCell.m
//  TableViewDataEntry
//
//  Created by Bartolomeo Sorrentino on 12/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PushFormDataEntryCell.h"
#import "UIXMLFormViewController.h"

@implementation PushFormDataEntryCell

@synthesize textLabel;

#pragma mark -
#pragma mark UIXMLFormViewControllerDelegate 

-(void)cellControlDidEndEditingNotify:(NSNotification *)notification {

	NSLog(@"PushDataEntryCell cellControlDidEndEditingNotify");

}

#pragma mark -
#pragma mark inherit from PushControllerDataEntryCell 

-(UIViewController *)viewController:(NSDictionary*)cellData {

	NSString *controller = [cellData objectForKey:@"controller"];
	
	UIXMLFormViewControllerEx *detailViewController = [[UIXMLFormViewControllerEx alloc] initFromFile: controller registerNotification:NO];
	
	detailViewController.delegate = super.owner;
	
	return detailViewController;
}

#pragma mark -

/*
- (id) init:(UIXMLFormViewController*)controller dataKey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData {

    if ((self = [super init:controller datakey:key label:label])) {
        // Initialization code
		
    }
	
	return self;
}
*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

	if( selected == YES ) {
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(cellControlDidEndEditingNotify:)
			name:CELL_ENDEDIT_NOTIFICATION_NAME
			object:nil];      
	}
	else {
		[[NSNotificationCenter defaultCenter] 
			removeObserver:self 
			name:CELL_ENDEDIT_NOTIFICATION_NAME 
			object:nil];
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
