//
//  FormViewController.h
//  TableViewDataEntry
//
//  Created by softphone on 20/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "UIXMLFormViewController.h"
#import "UIXMLFormViewControllerDelegate.h"

@class FormData ;

@interface FormViewController : UIXMLFormViewController {

	FormData *data;
}



@end
