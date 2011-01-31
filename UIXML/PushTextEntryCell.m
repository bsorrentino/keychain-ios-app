//
//  PushTextEntryCell.m
//  UIXML
//
//  Created by softphone on 19/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "PushTextEntryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PushTextEntryCell

@synthesize viewController, textLabel;

#pragma mark BaseDataEntryCell

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData{
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {
        // Initialization code		
    }
	
	return self;
}
-(void) setControlValue:(id)value {
	
	NSString * result = nil;
	
	if (value==nil) {
		result = @"";
	}
	else {
		result = value;
	}
	
	NSLog(@"PushTextEntryCell.setControlValue([%@]) asString [%@]", value, result );

	self.viewController.txtValue.text = result;
}

-(id) getControlValue {
	
	NSString * result = self.viewController.txtValue.text;
	
	NSLog(@"PushTextEntryCell.getControlValue [%@]", result );
	
	return result; 
}

#pragma mark PushControllerDataEntryCell

-(UIViewController *)viewController:(NSDictionary*)cellData {
	
	//detailViewController.delegate = super.owner.delegate;
	
	[viewController initWithCell:self];
	return [viewController retain];
}

#pragma mark UITableViewCell

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
	
	[self.txtValue.layer setCornerRadius:20.0f];
	[self.txtValue.layer setMasksToBounds:YES];
	[btnSave setTarget:self];
	self.navigationItem.rightBarButtonItem = self.btnSave;

}

- (void) viewWillDisappear:(BOOL)animated {
	[self.view.window endEditing: YES];

}

@end


