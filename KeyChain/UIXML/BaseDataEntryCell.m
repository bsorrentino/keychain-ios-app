//
//  BaseDataEntryCell.m
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import "BaseDataEntryCell.h"
#import "UIXMLFormViewController.h"	

@interface BaseDataEntryCell()

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

-(BOOL)isLabelSupported {
    return NO;
}

- (void) prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString*)key cellData:(NSDictionary*)cellData {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.dataKey = key;
    
    
    if( [self isLabelSupported] ) {

        NSString *label = cellData[@"Label"];
        
        if ( ![self isStringEmpty:label] ) {
            self.textLabel.text = label;
            self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
            
        }
        
    }
	
}


-(BOOL)isStringEmpty:(NSString*)value {
	return ( value==nil ||
            [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 );
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

    if( [self isLabelSupported] ) {
        
        CGFloat size_percentage = .25;
        CGFloat x = 10.0; // self.textLabel.frame.origin.x ;
    
        // The label size is the 35% of container
        CGRect labelRect = CGRectMake(x,
								  self.textLabel.frame.origin.y, 
								  self.contentView.frame.size.width * size_percentage, 
								  self.textLabel.frame.size.height);
        [self.textLabel setFrame:labelRect];
    }
	
}

-(CGRect) getRectRelativeToLabel:(CGRect)controlFrame padding:(NSInteger)padding rpadding:(NSInteger)rpadding {
    
	return CGRectMake(  self.textLabel.frame.origin.x + self.textLabel.frame.size.width  + padding, 
						controlFrame.origin.y, 
						self.contentView.frame.size.width-(self.textLabel.frame.size.width + padding + self.textLabel.frame.origin.x)-rpadding, 
						controlFrame.size.height);
}



@end



@interface BaseDataEntryCellWithResponder(Keyboard)

- (void)keyboardWillShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (void)scrollUpToKeyboard:(CGRect)keyboardRect;

@end

@implementation BaseDataEntryCellWithResponder
@dynamic responder;

#pragma mark - Keyboard notifications

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    if( !self.responder.isFirstResponder) return;
    
    NSDictionary* info = [aNotification userInfo];
    
    id infoKey = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    [self scrollUpToKeyboard:[infoKey CGRectValue]];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{

    [UIView animateWithDuration:0.2 animations:^() {
        
        UITableView * scrollView = (UITableView *)self.superview;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        
    }];
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)scrollUpToKeyboard:(CGRect)keyboardRect
{
#define MAGIC_NUMBER 18.0
    
    UITableView * scrollView = (UITableView *)self.superview;
    
    CGSize kbSize = keyboardRect.size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    
    CGRect aRect = scrollView.bounds; aRect.size.height -= kbSize.height;
    
    CGRect fRect = self.frame ; fRect.origin.y += fRect.size.height + MAGIC_NUMBER; 
    
    /*
    NSLog( @"\nKeyb height=[%f]\ntable rect y=[%f] h=[%f]\ncell  rect y=[%f] h=[%f]\nCONTAINED=[%d]" ,
          kbSize.height,
          aRect.origin.y, aRect.size.height,
          fRect.origin.y, fRect.size.height,
          CGRectContainsPoint(aRect, fRect.origin)
          );
    */
    
    if (!CGRectContainsPoint(aRect, fRect.origin) ) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        CGPoint scrollPoint = CGPointMake(0.0, fRect.origin.y-kbSize.height );
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
    
}

- (void) prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData {

    [super prepareToAppear:controller datakey:key cellData:cellData];
    
    if (![[cellData valueForKey:@"ignoreKeyboard"] boolValue] ) {
        
        [self registerForKeyboardNotifications];
    }
}

@end
