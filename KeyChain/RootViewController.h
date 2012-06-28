//
//  RootViewController.h
//  KeyChain
//
//  Created by softphone on 15/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UIXMLFormViewControllerDelegate.h"
#import "KeyEntityFormController.h"
#import "KeyEntity.h"
#import "KeyListDataSource.h"

@class KeyEntityFormController;
@class KeyListViewController;
@class ExportViewController;
@class ImportViewController;

@interface RootViewController : UIViewController<KeyListDataSource, UINavigationControllerDelegate>  {
    
@private
    KeyListViewController *keyListViewController_;
    ExportViewController *exportViewController_;
    ImportViewController *importViewController_;
	
}

@property (nonatomic) IBOutlet KeyListViewController *keyListViewController;
@property (nonatomic) IBOutlet ExportViewController *exportViewController;
@property (nonatomic) IBOutlet ImportViewController *importViewController;

-(IBAction)changePassword:(id)sender;
-(IBAction)export:(id)sender;
-(IBAction)import:(id)sender;


@end


