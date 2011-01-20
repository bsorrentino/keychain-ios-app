//
//  PushTextEntryCell.m
//  UIXML
//
//  Created by softphone on 19/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "PushTextEntryCell.h"

@implementation PushTextEntryCell

@synthesize viewController, textLabel;

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData{
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {
        // Initialization code		
    }
	
	return self;
}

-(UIViewController *)viewController:(NSDictionary*)cellData {
	
	//detailViewController.delegate = super.owner.delegate;
	
	[viewController initWithCell:self];
	return [viewController retain];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[textLabel release];
	[viewController release];
    [super dealloc];
}

@end

@implementation PushTextViewController

@synthesize btnSave, txtValue;


- (void) initWithCell:(PushTextEntryCell*)cell {
	
	_cell = cell;
	
	[self setTitle:cell.textLabel.text];
	
}

- (IBAction) saveValue: (id)sender {
	
	NSLog( @"saveValue ");
	
	[_cell postEndEditingNotification];
	
	[self.navigationController popViewControllerAnimated:YES];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[btnSave setTarget:self];
	self.navigationItem.rightBarButtonItem = self.btnSave;
	
	
}

@end


