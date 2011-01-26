//
//  TextDataEntryCell.m
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import "TextDataEntryCell.h"


@implementation TextDataEntryCell

@synthesize textField;
@synthesize textLabel;

#pragma mark Inherit from UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// Rect area del textbox
	/*
	CGRect rect = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width  + LABEL_CONTROL_PADDING, 
							 12.0, 
							 self.contentView.frame.size.width-(self.textLabel.frame.size.width + LABEL_CONTROL_PADDING + self.textLabel.frame.origin.x)-RIGHT_PADDING, 
							 25.0);
	*/
	
	CGRect rect = [super getRectRelativeToLabel:textField.frame padding:LABEL_CONTROL_PADDING rpadding:RIGHT_PADDING];
	[textField setFrame:rect];
}

#pragma mark Inherit from BaseDataEntryCell

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData{
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {		
        // Initialization code
		
		NSString *placeholder = [cellData objectForKey:@"placeholder"];
		
		if( ![self isStringEmpty:placeholder] ) {
			
			[textField setPlaceholder:placeholder];
		}
		
    }
	
	return self;
}

-(void) setControlValue:(id)value
{
	if (value==nil) {
		self.textField.text = @"";
	}
	else {
		self.textField.text = value;
	}
}

-(id) getControlValue
{
	return self.textField.text;
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)txtField {
	
	UITableView * tv = (UITableView *)self.superview;
	
	NSIndexPath * indexPath = [tv indexPathForCell: self];
	
	[tv scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	//[indexPath release];
	
	return YES;
	
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)txtField {
	if( [txtField isFirstResponder] ) {
		[txtField resignFirstResponder];
	}
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)txtField {
	if( [txtField isFirstResponder] ) {
		[txtField resignFirstResponder];
	}
	return YES;
	
}

- (void)textFieldDidEndEditing:(UITextField *)txtField
{
	[self postEndEditingNotification];
}



@end
