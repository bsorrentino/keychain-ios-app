//
//  WebViewController.m
//  ZZGridView
//
//

#import "WebViewController.h"


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
