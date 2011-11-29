//
//  WebViewController.m
//  ZZGridView
//
//

#import "PushWebViewEntryCell.h"
#import "UIXMLFormViewController.h"

static /*const*/ NSString * DEFAULT_URL = @"about:blank";

@interface WebViewController(Private) 

-(void)startEdit;
-(void)endEdit:(UIBarButtonItem *)button hideTextURL:(BOOL)hideTextURL;
-(void)editURL;
-(void)saveURL;
-(void)showURL;
-(void)back:(id)sender;
-(void)save:(id)sender;
-(void)clearContent;
-(UIView *)initInlineEditControls;
@end

@implementation WebViewController

@synthesize webView, addressView,txtURL=txtURL_, delegate;

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

-(void)save:(id)sender {
    
    [self endEdit:editButton_ hideTextURL:TRUE];
    [self saveURL];

}

-(void)back:(id)sender {
    
    [self endEdit:editButton_ hideTextURL:YES];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)showURL {
    
    NSLog( @"show url [%@]", self.txtURL.text );
    
	NSURL *link = [NSURL URLWithString: self.txtURL.text];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:link 
												cachePolicy:NSURLRequestReloadIgnoringCacheData
											timeoutInterval:60.0];
	[[self webView] loadRequest:requestObj];
    
}

-(void)clearContent {

[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:DEFAULT_URL]]];

}

- (NSString*)url {
 
    return self.txtURL.text;
}

- (void)setUrl:(NSString *)url {
    
    NSString * value = self.txtURL.text;
    
    if (url==nil ) {
        forceReload_ = YES;
        self.txtURL.text = DEFAULT_URL;
        return;
    }
    else if( value==nil ) {
        forceReload_ = YES;
    }
    else {
        
        forceReload_ = ([value compare:url options:NSCaseInsensitiveSearch]) ? YES : NO;
    }
    
    NSLog(@"WebViewController.setUrl new[%@] old[%@] compare[%d]", url, value, forceReload_  );
    
    self.txtURL.text = url;

    
}

-(UIView *)initInlineEditControls {
    UIView *inlineView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 24*2+2, 24)] autorelease];
    
    // ADD CONFIRM BUTTON
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(25,0,24,24)];
        [button setImage:[UIImage imageNamed:@"confirm24x24.png"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [button addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
        
        [inlineView addSubview:button];    
    }
    
    // ADD BACK BUTTON
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0,0,24,24)];
        [button setImage:[UIImage imageNamed:@"back24x24.png"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
        [inlineView addSubview:button];    
    }
    
    return inlineView;
}


#pragma mark WebView GestureRecognizer


#pragma mark - UIViewController

-(void)viewDidAppear:(BOOL)animated {
    isPossibleSave = NO;
    
	[super viewDidAppear:animated];
	
    if (forceReload_) {
        [self showURL];
        //[self.webView reload];
    }
    
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
    
    forceReload_ = FALSE;

    CGRect addressViewRC = self.addressView.frame;
    addressViewRC.size.height = 0;
    [self.addressView setFrame: addressViewRC];
    
    
    saveButton_ = 
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                  target:self 
                                                  action:@selector(saveURL)];
    editButton_ = 
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                                      target:self 
                                                      action:@selector(editURL)];
    
    self.navigationItem.rightBarButtonItem = editButton_; //[editButton_ release];
    
    
    self.txtURL.rightView = [self initInlineEditControls];
    self.txtURL.rightViewMode = UITextFieldViewModeAlways;
    //self.txtURL.clearButtonMode = UITextFieldViewModeAlways; // Doesn't Work - Probably depends the previous line

    
    self.title = NSLocalizedString(@"WebEntryCell.title", @"title of Web View Controller");
    
    
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if( [textField isFirstResponder] ) {
		[textField resignFirstResponder];
	}
	return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [self startEdit];
    
    if ([textField.text compare:DEFAULT_URL]==0) {
        [textField selectAll:self];
    }
    
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
    //[self.waitController mask: @"Loading ..."];
    [self.waitController maskWithCancelBlock:@"Loading ..." cancelBlock:^{
            
        [[self webView] stopLoading]; 
        
    }];
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

@synthesize viewController, textValue;
@synthesize textLabel=textLabel_;

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
	
	//CGRect rect = [super getRectRelativeToLabel:self.textValue.frame padding:LABEL_CONTROL_PADDING rpadding:RIGHT_PADDING];
	//[self.textValue setFrame:rect];
}

#pragma mark Inherit from BaseDataEntryCell

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData{
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {
        
        // initialization
        NSString *placeholder = [cellData objectForKey:@"placeholder"];
		
		if( ![self isStringEmpty:placeholder] ) {
			
			[self.textValue setPlaceholder:placeholder];
		}

    }
	
    
    return self;
}


- (void) postEndEditingNotification {
    
    self.textValue.text = self.viewController.url;
    
    [super postEndEditingNotification];
}


-(void) setControlValue:(id)value {
	
    NSLog(@"PushWebViewEntryCell.setControlValue([%@])", value );
    self.textValue.text = value;

/*    
	if (![self isStringEmpty:value]) {
	
        NSLog(@"PushWebViewEntryCell.setControlValue([%@])", value );
    
        self.textValue.text = value;

    }
*/ 
}

-(id) getControlValue {
	
	NSString * result = self.textValue.text;
	
	NSLog(@"PushWebViewEntryCell.getControlValue [%@]", result );
	
	return result; 
}

#pragma mark PushControllerDataEntryCell

-(UIViewController *)viewController:(NSDictionary*)cellData {
	

    self.viewController.delegate = self;
    
    self.viewController.url = [self getControlValue];

	return [viewController retain];
}

#pragma mark UITableViewCell

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
    
}
*/

- (void)dealloc {    
	//[textLabel release];
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

@implementation UIWebViewEx

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    NSLog(@"scrollViewWillBeginDragging");
    
    [super scrollViewWillBeginDragging:scrollView];
}

// called on finger up if user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    NSLog(@"scrollViewDidEndDragging [%d]", decelerate);

    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}
@end





