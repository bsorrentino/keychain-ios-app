//
//  TableViewDataEntryAppDelegate.h
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 31/08/10.
//  Copyright Infit S.r.l 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormViewController;

@interface TableViewDataEntryAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *viewController;

@end

