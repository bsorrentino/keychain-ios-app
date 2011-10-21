//
//  OptionPane.h
//  KeyChain
//
//  Created by softphone on 20/10/11.
//  Copyright (c) 2011 SOFTPHONE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionPane : NSObject<UIAlertViewDelegate> {
  
@private    
    void (^okBlock_)() ;  
    void (^cancelBlock_)() ;  
}

- (id)initWithOKBlock:(void (^)())okBlock CancelBlock:(void (^)())cancelBlock;

+ (void) showOKCancelAlert:(NSString *)title 
                        message:(NSString *)message
                        OKTitle:(NSString *)OKtitle OKBlock:(void (^)())OKBlock 
                        CancelTitle:(NSString*)CancelTitle CancelBlock:(void (^)())CancelBlock;

@end

