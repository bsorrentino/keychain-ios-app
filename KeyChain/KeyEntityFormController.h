//
//  KeyEntityFormController.h
//  KeyChain
//
//  Created by softphone on 11/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXMLFormViewController.h"

@class KeyEntity;

@interface KeyEntityFormController : UIXMLFormViewController {

@private 
	KeyEntity *entity_;
	UIBarButtonItem *btnSave;
	BOOL saved_;
}

@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnSave;
- (void)initWithEntity:(KeyEntity*)entity;

- (IBAction)save:(id)sender;

@end
