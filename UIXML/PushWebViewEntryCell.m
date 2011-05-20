//
//  WebViewController.m
//  ZZGridView
//
//

#import "PushWebViewEntryCell.h"
#import "UIXMLFormViewController.h"

@implementation WebViewController

@synthesize webView, url;


-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
    NSLog( @"show url [%@]", self.url );
                              
	NSURL *link = [NSURL URLWithString:self.url];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:link 
												cachePolicy:NSURLRequestReloadIgnoringCacheData
											timeoutInterval:60.0];
	[[self webView] loadRequest:requestObj];
}

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
    [super dealloc];
}


@end


@implementation PushWebViewEntryCell

@synthesize viewController, textLabel,textField;

#pragma mark BaseDataEntryCell


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
        
        // initialization
    }
	
    
    return self;
}

/*
- (void) postEndEditingNotification {
    
    [super postEndEditingNotification];
}
*/

-(void) setControlValue:(id)value {
	
	if (![self isStringEmpty:value]) {
	
        NSLog(@"PushWebViewEntryCell.setControlValue([%@])", value );
    
        self.textField.text = value;

    }
}

-(id) getControlValue {
	
	NSString * result = self.textField.text;
	
	NSLog(@"PushWebViewEntryCell.getControlValue [%@]", result );
	
	return result; 
}

#pragma mark PushControllerDataEntryCell

-(UIViewController *)viewController:(NSDictionary*)cellData {
	
	//detailViewController.delegate = super.owner.delegate;
	
	//[viewController initWithCell:self];
    
    viewController.url = [self getControlValue];

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





