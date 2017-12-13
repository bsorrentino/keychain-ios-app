//
//  PushTextEntryCell.m
//  UIXML
//
//  Created by softphone on 19/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "PushTextEntryCell.h"
#import <QuartzCore/QuartzCore.h>

#define NOTE_MAGIC_NUMBER 7

@implementation UINoteView

- (void)awakeFromNib 
{
    lineColor = 
        [UIColor colorWithRed:202/255.0f green:167/255.0 blue:131/255.0f alpha:1.0];
    //UIColor *lineColor = [UIColor blackColor];
    [super awakeFromNib];
}
- (void)drawRect:(CGRect)rect { 
    
    CGFloat line_offset = 24.0;
    
    CGPoint startPoint  = CGPointMake(line_offset, rect.origin.y);
    CGPoint endPoint    = CGPointMake(line_offset, rect.origin.y + rect.size.height);
  
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, NO);
    
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    
    CGContextSetLineWidth(context, 1);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextMoveToPoint(context, startPoint.x + 2.0f, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x + 2.0f, endPoint.y);
    
    CGContextDrawPath(context, kCGPathStroke);
    
	// Get the height of a single text line 
	NSString *alpha = @"ABCD"; 
	CGSize textSize = 
        [alpha  sizeWithFont:self.font 
                constrainedToSize:self.contentSize 
                lineBreakMode:UILineBreakModeWordWrap]; 
	
    NSUInteger height = textSize.height;
	
	// Get the height of the view or contents of the view whichever is bigger 
	textSize = 
        [self.text  sizeWithFont:self.font 
                    constrainedToSize:self.contentSize 
                    lineBreakMode:UILineBreakModeWordWrap];
    
	NSUInteger contentHeight = 
        (rect.size.height > textSize.height) ? 
                (NSUInteger)rect.size.height : 
                textSize.height;
	
	NSUInteger offset = NOTE_MAGIC_NUMBER + height; 
        // MAGIC Number 6 to offset from 0 to get first line OK ??? 
	contentHeight += offset; 
	
    // Draw ruled lines CGContextSetRGBStrokeColor(ctx, .8, .8, .8, 1); 
	for(long i=offset;i < contentHeight;i+=height) { 
		CGPoint lpoints[2] = { CGPointMake(0, i), CGPointMake(rect.size.width, i) };
		CGContextSetLineWidth(context, .5);
		CGContextStrokeLineSegments(context, lpoints, 1); 
	} 
}


@end

@interface PushTextEntryCell (private)

- (void)updateEditIcon:(NSString*)value;

@end


@implementation PushTextEntryCell

@synthesize viewController, editIcon=editIcon_, imgWrite, imgEdit;
//@synthesize textLabel;

- (void)updateEditIcon:(NSString*)value {

	if ([self.class isNullOrEmpty:value]) {
        self.editIcon.image = self.imgWrite;
	}
	else {
        self.editIcon.image = self.imgEdit;
	}
    
}


#pragma mark BaseDataEntryCell

-(UIImage*) imgWrite {
    if( imgWrite_==nil ) {
    
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"write32x32" ofType:@"png"];
    
        imgWrite_ = [UIImage imageWithContentsOfFile:resourcePath];
    }
    
    return imgWrite_;
    
}
-(UIImage*) imgEdit {
    if( imgEdit_==nil ) {
        
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"edit32x32" ofType:@"png"];
        
        imgEdit_ = [UIImage imageWithContentsOfFile:resourcePath];
    }
    
    return imgEdit_;
    
}

- (void) postEndEditingNotification {
    
    [self updateEditIcon:[self getControlValue]];
    
    [super postEndEditingNotification];
}

-(void) setControlValue:(id)value {
	
	NSString * result = nil;
	
    [self updateEditIcon:value];
    
	if ([self.class isNullOrEmpty:value]) {
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
	return viewController;
}

#pragma mark UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
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
    
    UIColor *color = [UIColor colorWithRed:251/255.0f green:248/255.0f blue:148/255.0f alpha:1.0];
    self.view.backgroundColor = color;

    self.txtValue.backgroundColor = color;
    
	//[self.txtValue.layer setCornerRadius:20.0f];
	[self.txtValue.layer setMasksToBounds:YES];
	self.txtValue.delegate = self;
	[btnSave setTarget:self];
	self.navigationItem.rightBarButtonItem = self.btnSave;
    

}

- (void) viewWillAppear:(BOOL)animated {
	// Show Keyboard
    [self.txtValue becomeFirstResponder];
    [super viewWillAppear:animated];
}
- (void) viewWillDisappear:(BOOL)animated {
	// Hide Keyboard
	[self.view.window endEditing: YES];
    [super viewWillDisappear:animated];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// NSLog(@"scrollViewDidScroll The scroll offset is ---%f",scrollView.contentOffset.y); 
	[txtValue setNeedsDisplay]; 
}


@end




