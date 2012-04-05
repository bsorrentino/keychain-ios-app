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
    UIAlertView *alert_;
    NSString *groupName;
    NSString *groupPrefix;

    void (^clickedButtonAtIndexBlock_)( UIAlertViewInputSection *alertView, NSInteger buttonIndex) ;
    
    //NSObject<UIAlertViewDelegate> *delegate;
}


- (id)initWithTitle:(NSString *)title;
- (id)init;
- (void)show;

//@property (nonatomic,assign) NSObject<UIAlertViewDelegate> *delegate;
@property (nonatomic,readonly) NSString *groupName;
@property (nonatomic,readonly) NSString *groupPrefix;
@property (nonatomic,copy) void (^clickedButtonAtIndexBlock)( UIAlertViewInputSection *alertView, NSInteger buttonIndex) ;

@end
