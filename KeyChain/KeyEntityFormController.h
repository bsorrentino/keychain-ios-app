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
	UIView *toolbar_;
	UIBarButtonItem *btnSave_;
	UISegmentedControl *segShowHidePassword_;
	
	BOOL valid_;

}

@property (nonatomic,retain) IBOutlet UIView *toolbar;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnSave;
@property (nonatomic,retain) IBOutlet UISegmentedControl *segShowHidePassword;

- (void)initWithEntity:(KeyEntity*)entity delegate:(id<KeyEntityFormControllerDelegate>)delegate;

-(IBAction)save:(id)sender;
-(IBAction) cancel:(id)sender;
-(IBAction)showHidePassword:(id)sender;

@end
