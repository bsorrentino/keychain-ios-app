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
	
	NSURL *link = [NSURL URLWithString:url];
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

@synthesize viewController, textLabel;

#pragma mark BaseDataEntryCell


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
	
	NSString * result = nil;

	if (![self isStringEmpty:value]) {
	
        NSLog(@"PushWebViewEntryCell.setControlValue([%@]) asString [%@]", value, result );
    
        self.viewController.url = result;
    }
}

-(id) getControlValue {
	
	NSString * result = self.viewController.url;
	
	NSLog(@"PushWebViewEntryCell.getControlValue [%@]", result );
	
	return result; 
}

#pragma mark PushControllerDataEntryCell

-(UIViewController *)viewController:(NSDictionary*)cellData {
	
	//detailViewController.delegate = super.owner.delegate;
	
	//[viewController initWithCell:self];
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





