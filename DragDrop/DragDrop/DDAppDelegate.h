//
//  DDAppDelegate.h
//  DragDrop
//
//  Created by softphone on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDTableViewController;
@class DDTableViewControllerUsingManager;

@interface DDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITableViewController *viewController;

@end
