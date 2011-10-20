//
//  KeyChainAppDelegate.h
//  KeyChain
//
//  Created by softphone on 15/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PersistentAppDelegate.h"
#import <AVFoundation/AVAudioPlayer.h>


//
// DEFINE IN THE PREPROCESSOR MACRO (DOESN'T WORK WITH XCODE 4.2)
//
//#define __IPHONE_OS_VERSION_MAX_ALLOWED=40200
//
//
@interface KeyChainAppDelegate : PersistentAppDelegate {
    
    UIWindow *window;
    UINavigationController *navigationController;

@private
    AVAudioPlayer *click;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


- (void)playClick;
+ (void)showMessagePopup:(NSString *)message title:(NSString*)title;
+ (void)showErrorPopup:(NSError *)error;
@end

