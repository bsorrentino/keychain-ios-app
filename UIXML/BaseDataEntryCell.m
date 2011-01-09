//
//  BaseDataEntryCell.m
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import "BaseDataEntryCell.h"
#import "UIXMLFormViewController.h"	

@implementation BaseDataEntryCell

@synthesize dataKey;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

		// extra configuration
    }
    return self;
}

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.dataKey = key;
	self.textLabel.text = label;
	
	return self;
}

-(void) setControlValue:(id)value
{
	NSLog( @"setControlValue [%@] = [%@]", dataKey, value ) ;
}

-(id) getControlValue
{
	NSLog( @"getControlValue [%@]", dataKey );
	return nil;
}

-(void)postEndEditingNotification
{
	NSLog(@"postEndEditingNotification");
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:CELL_ENDEDIT_NOTIFICATION_NAME
	 //object:[(UITableView *)self.superview indexPathForCell: self]];
	 object:self];
	
}

#pragma mark inherit from NSObject

- (void)dealloc {
    [super dealloc];
}

#pragma mark inherit from UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// La label occupaupa il 35% del container
	CGRect labelRect = CGRectMake(self.textLabel.frame.origin.x, 
								  self.textLabel.frame.origin.y, 
								  self.contentView.frame.size.width * .35, 
								  self.textLabel.frame.size.height);
	[self.textLabel setFrame:labelRect];
	
}

-(BOOL)isStringEmpty:(NSString*)value {
	return ( value==nil || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 );
}



@end
