//
//  ExportViewController.h
//  KeyChain
//
//  Created by softphone on 07/10/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyListDataSource.h"

@class WaitMaskController;

@interface ExportViewController : UIViewController<UIAlertViewDelegate> {

@private

    WaitMaskController *_wait;
    
}

@property (nonatomic ) IBOutlet UIButton *exportToITunesButton;

@property (unsafe_unretained,nonatomic) id<KeyListDataSource> delegate;
@end
