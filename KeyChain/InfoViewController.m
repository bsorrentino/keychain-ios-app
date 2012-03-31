//
//  InfoViewController.m
//  KeyChain
//
//  Created by softphone on 29/03/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (IBAction)showVideo:(id)sender {
 
    NSURL *url = 
        [[NSURL alloc] 
         initWithString:@"http://www.youtube.com/watch?v=KsNFdkibU44&context=C407c249ADvjVQa1PpcFNS8ap2Q6YqkUIjLRK-kiKU_Q1k0KgzSdc=A" ];
                  
    [[UIApplication sharedApplication] openURL:url ];
    [url release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
