//
//  KeyChainAppDelegate.m
//  KeyChain
//
//  Created by softphone on 15/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "KeyChainAppDelegate.h"
#import "RootViewController.h"
#import "KeyChainLogin.h"

@implementation KeyChainAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark - Application custom implementation

- (void)playClick {
    
    if (click!=nil) [click play];
}

#pragma mark - Application lifecycle

- (void)awakeFromNib {    
    
    //RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
    //rootViewController.managedObjectContext = self.managedObjectContext;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    NSURL* musicFile = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] URLForResource:@"Tock" withExtension:@"aiff"];
    if (musicFile!=nil ) {
        click = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
        [click setVolume:0.15f];

    }

    [self checkEntities];
    
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {

    /*
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Message" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show];
	[alert release];
	 */
	/*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	KeyChainLogin *login = [[KeyChainLogin alloc] initWithNibName:@"KeyChainLogin" bundle:nil] ;
	[login	doModal:navigationController];
	
	[login release];
	
	
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
	
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [click release];
    [navigationController release];
    [window release];

    [super dealloc];
}


@end

