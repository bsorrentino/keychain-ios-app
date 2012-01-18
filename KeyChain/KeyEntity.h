//
//  KeyEntity.h
//  KeyChain
//
//  Created by softphone on 10/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface KeyEntity : NSManagedObject {

}

- (NSDictionary *)toDictionary:(NSMutableDictionary*)target;
- (void)fromDictionary:(NSDictionary *)source;
- (BOOL)isEqualForImport:(id)object;

@property (nonatomic,readonly) BOOL isNew;
@property (nonatomic,readonly) NSString * sectionId;
@property (nonatomic,retain) NSString *mnemonic; 

@property (nonatomic,retain) NSString *groupPrefix;
@property (nonatomic,retain) NSNumber *group;

@end
