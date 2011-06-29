//
//  UIWaitCompletionView.h
//  KeyChain
//
//  Created by softphone on 19/06/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitMaskController : NSObject<UIAlertViewDelegate> {
    
@private
    UIAlertView *waitView_;
}

- (void)mask:(NSString*)title;
- (void)unmask;

@end