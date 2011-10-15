//
//  ExportViewController.m
//  KeyChain
//
//  Created by softphone on 07/10/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import "ExportViewController.h"
#import "WaitMaskController.h"
#import "KeyEntity.h"
#import "KeyChainAppDelegate.h"

@interface ExportViewController(Private)

-(void)exportToITunes;

@end


@implementation ExportViewController

@synthesize exportToITunesButton;
@synthesize delegate;

#pragma - ExportViewController UIAlertViewDelegate implementation 

/*
 // Called when a button is clicked. The view will be automatically dismissed after this call returns
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
 
 // Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
 // If not defined in the delegate, we simulate a click in the cancel button
 - (void)alertViewCancel:(UIAlertView *)alertView;
 
 - (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
 - (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation
 
 - (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
 */

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {  // after animation
    [self.navigationController popViewControllerAnimated:YES];    
}

#pragma - ExportViewController private implementation 


-(void)exportToITunes {
    
    if( self.delegate == nil ) return;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    WaitMaskController *wait = [[WaitMaskController alloc] init ];
    
    @try {
        
        [wait mask:@"Export to ITunes...."];
        
        NSMutableArray *root = [[[NSMutableArray alloc ]init] autorelease];
        
        NSArray * keys = [NSArray  arrayWithObjects:@"version",nil];
        NSArray * values = [NSArray arrayWithObjects:@"1.2",nil];
        
        NSMutableDictionary * header = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
        
        [root addObject:header];
        
        
        NSArray *items = [self.delegate fetchedObjects];
        
        for (KeyEntity *entity in items) {
            
            NSMutableDictionary * d = [[NSMutableDictionary new] autorelease];
            [root addObject:[entity toDictionary:d]];
        }
        
        
        NSString *errorDescription;
        
        NSData *data = [NSPropertyListSerialization dataFromPropertyList:root format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDescription ];
        
        if (data== nil ) {
            NSString *msg = [NSString stringWithFormat:@"error creating NSPropertyListSerialization [%@]", errorDescription ];
            
            [KeyChainAppDelegate showMessagePopup:msg title:@"error"];
            return;
        }
        
        BOOL expandTilde = YES;
        
        //NSSearchPathDirectory destination = NSLibraryDirectory;
        NSSearchPathDirectory destination = NSDocumentDirectory;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(destination, NSUserDomainMask, expandTilde);
        
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSLog(@"Document paths[0]=[%@]", documentDirectory);
        
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        
        
        NSString *fileName = [NSString stringWithFormat:@"keylist-%@.plist", [dateFormat stringFromDate:[NSDate date]]  ];
        
        NSString *outputPath = [documentDirectory stringByAppendingPathComponent:fileName];
        
        //BOOL writeResult = [data writeToFile:outputPath atomically:YES];
        NSError *error = nil;
        BOOL writeResult = [data writeToFile:outputPath options:NSDataWritingAtomic error:&error];
        if( !writeResult ) {
            [KeyChainAppDelegate showErrorPopup:error];
            return;
        }
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Export" 
                                                         message:@"Completed!"
                                                        delegate:self 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil] autorelease];
        [alert show];

        
        
    }
    @finally {
        
        [wait unmask];
        
        [pool drain];
        
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.exportToITunesButton addTarget:self action:@selector(exportToITunes) forControlEvents:UIControlEventTouchDown];
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
