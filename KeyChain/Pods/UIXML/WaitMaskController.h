//
//  UIWaitCompletionView.h
//  KeyChain
//
//  Created by softphone on 19/06/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXML.h"

@interface WaitMaskController : NSObject<UIAlertViewDelegate> {
    
@private
    UIAlertView *waitView_;
    void (^cancelBlock_)(void);
    
}

- (void)mask:(NSString*)title;
- (void)maskWithCancelBlock:(NSString*)title cancelBlock:(void (^)(void))cancelBlock;
- (void)unmask;

@property (UIXML_STRONG,nonatomic) NSString *message;
@end
