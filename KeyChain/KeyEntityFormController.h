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

@interface KeyEntityFormController : UIXMLFormViewController<UINavigationBarDelegate> {

@private 
	KeyEntity *entity_;
}

- (void)initWithEntity:(KeyEntity*)entity;

- (IBAction)save:(id)sender;

@end
