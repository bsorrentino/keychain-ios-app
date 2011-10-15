//
//  ExportViewController.h
//  KeyChain
//
//  Created by softphone on 07/10/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyListDataSource.h"

@interface ExportViewController : UIViewController<UIAlertViewDelegate> {

@private
    id<KeyListDataSource> delegate_;

    UIButton *exportToITunesButton;
}

@property (assign,nonatomic) id<KeyListDataSource> delegate;
@property (retain,nonatomic ) IBOutlet UIButton *exportToITunesButton;

@end
