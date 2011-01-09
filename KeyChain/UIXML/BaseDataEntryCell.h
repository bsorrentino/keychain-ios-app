//
//  BaseDataEntryCell.h
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>


// Padding tra i controlli nella cella
#define LABEL_CONTROL_PADDING 5
// Padding del controllo rispetto al 
#define RIGHT_PADDING 5

// Nome della notifica di fine editing
#define CELL_ENDEDIT_NOTIFICATION_NAME @"CellEndEdit"

@class UIXMLFormViewController;

@interface BaseDataEntryCell : UITableViewCell {

}

@property (nonatomic, retain) NSString *dataKey;

-(id)init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData;

// Imposta il valore del controllo gestito (TextField, ...)
-(void) setControlValue:(id)value;

// Legge il valore dal controllo
-(id) getControlValue;

// Helper per l'invio della notifica di fine editing
-(void)postEndEditingNotification;

// helper for check string
-(BOOL)isStringEmpty:(NSString*)value;


@end