//
//  KeyChainAppDelegate.h
//  KeyChain
//
//  Created by softphone on 15/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@import UIKit;
@import CoreData;
@import AVFoundation;

#import "PersistentAppDelegate.h"

@class RootViewController;
//
// DEFINE IN THE PREPROCESSOR MACRO (DOESN'T WORK WITH XCODE 4.2)
//
//#define __IPHONE_OS_VERSION_MAX_ALLOWED=40200
//
//
@interface _KeyChainAppDelegate : PersistentAppDelegate {
    
    UIWindow *window;
    UINavigationController *navigationController;

@private
    AVAudioPlayer *click;
}

@property (nonatomic,retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) IBOutlet UINavigationController *navigationController;
@property (unsafe_unretained, nonatomic) IBOutlet RootViewController *rootViewController;


- (void)playClick;

+ (void)processKeysToIdentifySections;


@end

