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
	NSObject<KeyEntityFormControllerDelegate> *formDelegate_;
	KeyEntity *entity_;
	UIView *toolbar_;
	UIBarButtonItem *btnSave_;
	UISegmentedControl *segShowHidePassword_;
	
	BOOL _valid;

}

@property (nonatomic) IBOutlet UIView *toolbar;
@property (nonatomic) IBOutlet UIBarButtonItem *btnSave;
@property (nonatomic) IBOutlet UISegmentedControl *segShowHidePassword;

- (void)initWithEntity:(KeyEntity*)entity delegate:(NSObject<KeyEntityFormControllerDelegate> *)delegate;

-(IBAction)save:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)showHidePassword:(id)sender;

@end
