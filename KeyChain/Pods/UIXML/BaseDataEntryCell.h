//
//  BaseDataEntryCell.h
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXML.h"
#import "NSDictionary+CellData.h"

// cell controls padding
#define LABEL_CONTROL_PADDING 5
// Control padding  
#define RIGHT_PADDING 5

// Nome della notifica di fine editing
#define CELL_ENDEDIT_NOTIFICATION_NAME @"CellEndEdit"



@class UIXMLFormViewController;

@protocol BaseDataEntryCellDelegate


// Helper per l'invio della notifica di fine editing
-(void)postEndEditingNotification;


@end

@interface BaseDataEntryCell : UITableViewCell<BaseDataEntryCellDelegate> {

}

@property (nonatomic, UIXML_WEAK) IBOutlet UILabel *_Nullable textLabel;
@property (nonatomic, UIXML_WEAK) NSString * _Nullable dataKey;
@property (nonatomic) BOOL enabled;

-(void)prepareToAppear:(UIXMLFormViewController * _Nonnull)controller datakey:(NSString* _Nonnull)key cellData:(NSDictionary*_Nullable)cellData;

// Imposta il valore del controllo gestito (TextField, ...)
-(void) setControlValue:(id _Nonnull )value;

// Legge il valore dal controllo
-(id _Nullable ) getControlValue;

// helper for check string
+(BOOL)isNullOrEmpty:(NSString*_Nullable)value;

-(void)prepareLabelToAppear:(NSDictionary*_Nonnull)cellData;

-(void)processLabelConfig:(NSDictionary*_Nonnull)cellData
                   dataView:(UIView *_Nullable)view;
@end



@interface BaseDataEntryCellWithResponder : BaseDataEntryCell {

}

@property (nonatomic, UIXML_WEAK, readonly, getter = getResponder) UIResponder * _Nullable  responder;

- (void)registerForKeyboardNotifications;
- (void)unregisterForKeyboardNotifications;

@end
