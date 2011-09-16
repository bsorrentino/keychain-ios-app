//
//  BaseDataEntryCell.m
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import "BaseDataEntryCell.h"
#import "UIXMLFormViewController.h"	

@interface BaseDataEntryCell(Private)

@end

@implementation BaseDataEntryCell

@synthesize dataKey;

#pragma - private implementation

#pragma - public implementation

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

		// extra configuration
    }
    return self;
}

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.dataKey = key;
    
    if (![self isStringEmpty:label] ) {
        self.textLabel.text = label;
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];

    }
	
	return self;
}


-(BOOL)isStringEmpty:(NSString*)value {
	return ( value==nil || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 );
}



-(void) setControlValue:(id)value
{
	NSLog( @"[%@].setControlValue[%@]", dataKey, value ) ;
}

-(id) getControlValue
{
	NSLog( @"[%@].getControlValue", dataKey );
	return nil;
}

-(void)postEndEditingNotification
{
	NSLog(@"[%@].postEndEditingNotification", dataKey);
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:CELL_ENDEDIT_NOTIFICATION_NAME
	 //object:[(UITableView *)self.superview indexPathForCell: self]];
	 object:self];
	
}

-(void)setEnabled:(BOOL)value {

}

-(BOOL)enabled {
	return YES;
}

#pragma mark inherit from NSObject

- (void)dealloc {
	[dataKey release];
    [super dealloc];
}

#pragma mark inherit from UITableViewCell

/*
// if the cell is reusable (has a reuse identifier), this is called just before the cell is returned from the table view method dequeueReusableCellWithIdentifier:.  If you override, you MUST call super.
- (void)prepareForReuse {
 }
*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	NSLog(@"[%@].setSelected [%d]", dataKey, selected);
    [super setSelected:selected animated:animated];
	
}

#pragma mark inherit from UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGFloat size_percentage = .25;
    CGFloat x = 10.0; // self.textLabel.frame.origin.x ;
    
	// The label size is the 35% of container
	CGRect labelRect = CGRectMake(x, 
								  self.textLabel.frame.origin.y, 
								  self.contentView.frame.size.width * size_percentage, 
								  self.textLabel.frame.size.height);
	[self.textLabel setFrame:labelRect];
	
}

-(CGRect) getRectRelativeToLabel:(CGRect)controlFrame padding:(NSInteger)padding rpadding:(NSInteger)rpadding {

	return CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width  + padding, 
						controlFrame.origin.y, 
						self.contentView.frame.size.width-(self.textLabel.frame.size.width + padding + self.textLabel.frame.origin.x)-rpadding, 
						controlFrame.size.height);
}



@end
