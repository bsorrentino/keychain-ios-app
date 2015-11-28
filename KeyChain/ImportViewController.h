//
//  ImportViewController.h
//  KeyChain
//
//  Created by softphone on 09/10/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeyListDataSource.h"

@class WaitMaskController;

@interface ImportViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate> {

@private
    
    NSArray/*(NSString*)*/ *fileArray_;

    WaitMaskController *_wait;
}

@property (unsafe_unretained,nonatomic) id<KeyListDataSource> delegate;

@end
