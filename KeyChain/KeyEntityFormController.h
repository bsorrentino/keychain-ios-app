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

@protocol KeyEntityFormControllerDelegate

-(BOOL)doSaveObject:(KeyEntity*)entity;

@end

@interface KeyEntityFormController : UIXMLFormViewController {

@private 
	id<KeyEntityFormControllerDelegate> formDelegate_;
	KeyEntity *entity_;
	UIBarButtonItem *btnSave;
	BOOL saved_;
}

@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnSave;
- (void)initWithEntity:(KeyEntity*)entity delegate:(id<KeyEntityFormControllerDelegate>)delegate;

- (IBAction)save:(id)sender;
-(IBAction) cancel:(id)sender;

@end
