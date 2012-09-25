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

- (BOOL)isSection;
- (BOOL)isGrouped;

- (void)groupByPrefix:(NSString*)prefix;
- (void)detachFromGroup;


+ (KeyEntity *)createSection:  (NSString *)groupKey 
                                groupPrefix:(NSString *)groupPrefix
                                inContext:(NSManagedObjectContext *)context;

+ (BOOL)isSectionAware:(KeyEntity *)key;
+ (NSRange)getSectionPrefix:(KeyEntity*)key checkIfIsSectionAware:(BOOL)check;

//+ (void)groupByReplacingPrefix:(KeyEntity *)key groupKey:(NSString*)groupKey prefix:(NSString*)prefix;
//+ (void)groupByAppendingPrefix:(KeyEntity *)key prefix:(NSString*)prefix;
//+ (void)groupByReplacingName:(KeyEntity *)key mnemonic:(NSString*)name;

+ (NSString *)sectionNameFromPrefix:(NSString *)prefix trim:(BOOL)trim;


@property (nonatomic,readonly) BOOL isNew;
@property (unsafe_unretained, nonatomic,readonly) NSString * sectionId;

@property (nonatomic) NSString *mnemonic;
@property (nonatomic) NSString *groupPrefix;
@property (nonatomic) NSNumber *group;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *note;


@end
