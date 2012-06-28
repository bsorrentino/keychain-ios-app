//
//  UIAlertViewInputSection.h
//  KeyChain
//
//  Created by softphone on 14/02/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertViewInputSection : NSObject<UIAlertViewDelegate> {
   
@private    
    
    NSString *groupName;
    NSString *groupPrefix;
}

+ (UIAlertView *)alertViewWithBlock:(void(^)( UIAlertViewInputSection *alertView, NSInteger buttonIndex))clickedButtonAtIndexBlock;

@property (nonatomic,readonly) NSString *groupName;
@property (nonatomic,readonly) NSString *groupPrefix;

@end
