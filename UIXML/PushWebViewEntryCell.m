//
//  WebViewController.m
//  ZZGridView
//
//

#import "PushWebViewEntryCell.h"
#import "UIXMLFormViewController.h"

@interface WebViewController(Private) 

-(void)startEdit;
-(void)endEdit:(UIBarButtonItem *)button hideTextURL:(BOOL)hideTextURL;
-(void)editURL;
-(void)saveURL;
-(void)showURL;

@end
    
@implementation WebViewController

@synthesize webView, url, addressView,txtURL=txtURL_, delegate;

#pragma mark Custom

-(void)startEdit {
    
    isPossibleSave = YES;
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [UIView beginAnimations:@"startEdit" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGRect addressViewRC = self.addressView.frame;
 
    addressViewRC.size.height = 41;
    
    CGFloat addressViewheight = addressViewRC.size.height;
    
    [self.addressView setFrame: addressViewRC];
    
    
    CGRect rc = self.webView.frame;
    
    rc.origin.y = self.view.frame.origin.y + addressViewRC.size.height;
    rc.size.height = self.view.frame.size.height - addressViewheight;
    [self.webView setFrame:rc];    
    
    [UIView commitAnimations];
    
}
-(void)endEdit:(UIBarButtonItem *)button hideTextURL:(BOOL)hideTextURL {
    
    isPossibleSave = NO;

    if (hideTextURL) {
        [UIView beginAnimations:@"endEdit" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
        CGRect addressViewRC = self.addressView.frame;
    
        CGFloat addressViewheight = addressViewRC.size.height;
    
        addressViewRC.size.height = 0;
    
        [self.addressView setFrame: addressViewRC];
    
    
        CGRect rc = self.webView.frame;
    
        rc.origin.y = self.view.frame.origin.y + addressViewRC.size.height;
        rc.size.height = self.view.frame.size.height + addressViewheight;
        [self.webView setFrame:rc];    
    
        [UIView commitAnimations];
    }
    
    if( button != nil ) {
        self.navigationItem.rightBarButtonItem = button; //[button release];        
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }

    
}


-(WaitMaskController *) waitController {

    if (waitController_ == nil ) {
        waitController_ = [[WaitMaskController alloc] init];
    }
    
    return waitController_;
}

-(void)editURL {
    
    [self startEdit];
    
}

-(void)saveURL {
    
    if (self.delegate!=nil) {
        [self.delegate postEndEditingNotification];
    }
    [self.navigationController popViewControllerAnimated:true];

    
}

- (NSString *)url {
    
    NSString *result =  self.txtURL.text;

    NSLog( @"url [%@]", result );

    return result;
}

- (void)setUrl:(NSString*)value {
    
    [self.txtURL setText:value];
}

-(void)showURL {
    
    NSLog( @"show url [%@]", self.url );
    
	NSURL *link = [NSURL URLWithString:self.url];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:link 
												cachePolicy:NSURLRequestReloadIgnoringCacheData
											timeoutInterval:60.0];
	[[self webView] loadRequest:requestObj];
    
}

#pragma mark UIViewController

-(void)viewDidAppear:(BOOL)animated {
    isPossibleSave = NO;
    
	[super viewDidAppear:animated];
	
    [self showURL];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [self endEdit:editButton_ hideTextURL:YES];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect addressViewRC = self.addressView.frame;
    addressViewRC.size.height = 0;
    [self.addressView setFrame: addressViewRC];
    
    
    saveButton_ = 
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                  target:self 
                                                  action:@selector(saveURL)];
    editButton_ = 
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                                      target:self 
                                                      action:@selector(editURL)];
    
    self.navigationItem.rightBarButtonItem = editButton_; //[editButton_ release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [saveButton_ release];
    [editButton_ release];

    [waitController_ release];
    [super dealloc];
}

#pragma mark UITextFieldDelegate

// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    NSLog(@"textFieldShouldClear");
    return YES;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSLog(@"textFieldShouldReturn");
    
    if( [textField isFirstResponder] ) {
		[textField resignFirstResponder];
	}

    [self showURL];
    return YES;
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)txtField {
	if( [txtField isFirstResponder] ) {
		[txtField resignFirstResponder];
	}
	return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [self startEdit];
}

/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
*/


#pragma mark UIWebViewDelegate 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.waitController mask: @"Loading ..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.waitController unmask];    
    
    if (isPossibleSave) {
        [self endEdit:saveButton_ hideTextURL:FALSE];
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self endEdit:editButton_ hideTextURL:FALSE];
}



@end


@implementation PushWebViewEntryCell

@synthesize viewController, textLabel, textValue;

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
	
	CGRect rect = [super getRectRelativeToLabel:self.textValue.frame padding:LABEL_CONTROL_PADDING rpadding:RIGHT_PADDING];
	[self.textValue setFrame:rect];
}

#pragma mark Inherit from BaseDataEntryCell

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData{
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {
        
        // initialization
    }
	
    
    return self;
}


- (void) postEndEditingNotification {
    
    self.textValue.text = self.viewController.url;
    
    [super postEndEditingNotification];
}


-(void) setControlValue:(id)value {
	
	if (![self isStringEmpty:value]) {
	
        NSLog(@"PushWebViewEntryCell.setControlValue([%@])", value );
    
        viewController.url = value;
        self.textValue.text = value;

    }
}

-(id) getControlValue {
	
	NSString * result = viewController.url;
	
	NSLog(@"PushWebViewEntryCell.getControlValue [%@]", result );
	
	return result; 
}

#pragma mark PushControllerDataEntryCell

-(UIViewController *)viewController:(NSDictionary*)cellData {
	
	//detailViewController.delegate = super.owner.delegate;
	
	//[viewController initWithCell:self];
    
    viewController.delegate = self;

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

/*
 
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
 
 
*/



@end





