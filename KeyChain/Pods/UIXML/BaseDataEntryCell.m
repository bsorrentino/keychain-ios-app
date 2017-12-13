//
//  BaseDataEntryCell.m
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import "BaseDataEntryCell.h"
#import "UIXMLFormViewController.h"	

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

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

-(void)processLabelConfig:(NSDictionary*_Nonnull)cellData dataView:(UIView *_Nullable)view
{
    if( self.textLabel == nil ) return;

    [cellData getStringForKey:@"Label" next:^(NSString * _Nonnull value) {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.textLabel.text = value;
        
        CGFloat width = 0.25;
        
        NSNumber *lw = cellData[@"Label.Width%"];
        if( lw!=nil ) {
            width = [lw floatValue]/100;
        }
        
        NSLayoutConstraint *label_width =
        [NSLayoutConstraint constraintWithItem:self.textLabel
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:width
                                      constant:0.0];
        [self.contentView addConstraint:label_width];
        /*
         NSLayoutConstraint *text_width =
         [NSLayoutConstraint constraintWithItem:view
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.contentView
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:(1 - multiplier)
                                       constant:0.0];
         [self.contentView addConstraint:text_width];
         */
    } complete:^{
        
        self.textLabel.text = @"";
        
        if( view == nil ) return;
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *text_width =
        [NSLayoutConstraint constraintWithItem:view
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0 // 100%
                                      constant:0.0];
        [self.contentView addConstraint:text_width];
        
    }];

}

-(void)prepareLabelToAppear:(NSDictionary*_Nonnull)cellData
{
    [self processLabelConfig:cellData dataView:nil];
}

- (void) prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString*)key cellData:(NSDictionary*)cellData
{
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.dataKey = key;
    
    [self prepareLabelToAppear:cellData];
}


+(BOOL)isNullOrEmpty:(NSString*)value {
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
        /*
        UITableView * scrollView = nil;;
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            scrollView = (UITableView *)self.superview.superview;
        }
        else {
            scrollView = (UITableView *)self.superview;
        }
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        */
        
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
    
    UITableView * scrollView = nil;;
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        scrollView = (UITableView *)self.superview.superview;
    }
    else {
        scrollView = (UITableView *)self.superview;
    }
    
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

@implementation NSDictionary (CellData)

-(void)getStringForKey:(NSString *_Nonnull)key
                          next:(void (^ _Nonnull )(NSString * _Nonnull value))next
{

    id value = self[key];
    
    if( value != nil &&
       [value isKindOfClass:[NSString class]] &&
       ![BaseDataEntryCell isNullOrEmpty:value])
    {

        next( value );
    }
}

-(void)getStringForKey:(NSString *_Nonnull)key
                   next:(void (^ _Nonnull )(NSString * _Nonnull value))next
               complete:(void (^ _Nonnull )(void))complete
{
    id value = self[key];
    
    if( value != nil &&
       [value isKindOfClass:[NSString class]] &&
       ![BaseDataEntryCell isNullOrEmpty:value])
    {
        
        next( value );
    }
    else {
        complete();
        
    }

}

-(void)getNumberForKey:(NSString *_Nonnull)key
                  next:(void (^ _Nonnull )(NSNumber * _Nonnull value))next
{
    id value = self[key];
    
    if( value != nil && [value isKindOfClass:[NSNumber class]]) {
        
        next( value );
    }
}

-(void)getNumberForKey:(NSString *_Nonnull)key
                  next:(void (^ _Nonnull )(NSNumber * _Nonnull value))next
              complete:(void (^ _Nonnull )(void))complete
{
    id value = self[key];
    
    if( value != nil && [value isKindOfClass:[NSNumber class]] ) {
        
        next( value );
    }
    else {
        complete();
        
    }
    
}

-(void)getArrayForKey:(NSString *_Nonnull)key
                 next:(void (^ _Nonnull )(NSArray * _Nonnull value))next
{
    id value = self[key];
    
    if( value != nil && [value isKindOfClass:[NSArray class] ] ) {
        next( value );
    }

    
}


@end
