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
    BaseDataEntryCell *cell_;
    NSFetchedResultsController *fetchedResultsController_;
    NSRegularExpression *regex_;
    
}

@property (nonatomic,assign) BaseDataEntryCell *cell;
@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;
@end

@interface MailListDataEntryCell : PushControllerDataEntryCell {
    
@private 
    MailListDataViewController *listViewController_;
    UILabel *textLabel_;
    UITextField *textValue_;
}

@property (nonatomic,retain) IBOutlet MailListDataViewController *listViewController;
@property (nonatomic,retain) IBOutlet UITextField *textValue;
@property (nonatomic,retain) IBOutlet UILabel *textLabel;
@end


