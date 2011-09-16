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

@interface KeyChainAppDelegate : PersistentAppDelegate {
    
    UIWindow *window;
    UINavigationController *navigationController;

@private
    AVAudioPlayer *click;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


- (void)playClick;

@end

