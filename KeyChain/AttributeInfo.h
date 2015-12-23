//
//  AttributeInfo.h
//  KeyChain
//
//  Created by Bartolomeo Sorrentino on 9/6/11.
//  Copyright (c) 2011 SOFTPHONE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define MAIL_TYPE 0

@interface AttributeInfo : NSManagedObject {
@private
}
@property (nonatomic) NSNumber * type;
@property (nonatomic) NSString * value;

@end
