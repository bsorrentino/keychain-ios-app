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
    void (^okBlock_)(void) ;  
    void (^cancelBlock_)(void) ;  
}

- (id)initWithOKBlock:(void (^)(void))okBlock CancelBlock:(void (^)(void))cancelBlock;

+ (void) showOKCancelAlert:(NSString *)title 
                        message:(NSString *)message
                   OKTitle:(NSString *)OKtitle OKBlock:(void (^)(void))OKBlock 
               CancelTitle:(NSString*)CancelTitle CancelBlock:(void (^)(void))CancelBlock;

@end

