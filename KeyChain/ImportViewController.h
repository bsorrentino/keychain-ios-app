//
//  ImportViewController.h
//  KeyChain
//
//  Created by softphone on 09/10/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeyListDataSource.h"

@interface ImportViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate> {

@private
    id<KeyListDataSource> __unsafe_unretained delegate_;
    
    NSArray/*(NSString*)*/ *fileArray_;
}

@property (unsafe_unretained,nonatomic) id<KeyListDataSource> delegate;

@end
