//
//  ListDataEntryCell.h
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 8/30/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushControllerDataEntryCell.h"


@interface MailListDataViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,NSFetchedResultsControllerDelegate> {

@private
    BaseDataEntryCell *__unsafe_unretained cell_;
    NSFetchedResultsController *fetchedResultsController_;
    NSRegularExpression *regex_;
    
}

@property (nonatomic,unsafe_unretained) BaseDataEntryCell *cell;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@interface MailListDataEntryCell : PushControllerDataEntryCell {
    
@private 
    MailListDataViewController *listViewController_;
    UITextField *textValue_;
}

@property (nonatomic) IBOutlet MailListDataViewController *listViewController;
@property (nonatomic) IBOutlet UITextField *textValue;
@end


