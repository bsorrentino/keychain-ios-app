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

+ (KeyEntity *)createSection:  (NSString *)groupKey 
                                groupPrefix:(NSString *)groupPrefix
                                inContext:(NSManagedObjectContext *)context;

+ (BOOL)isSectionAware:(KeyEntity *)key;
+ (NSRange)getSectionPrefix:(KeyEntity*)key checkIfIsSectionAware:(BOOL)check;

+ (void)groupByAppendingPrefix:(KeyEntity *)key prefix:(NSString*)prefix;
+ (void)groupByReplacingName:(KeyEntity *)key mnemonic:(NSString*)name;
+ (void)groupByReplacingPrefix:(KeyEntity *)key groupKey:(NSString*)groupKey prefix:(NSString*)prefix;

+ (NSString *)sectionNameFromPrefix:(NSString *)prefix trim:(BOOL)trim;


@property (nonatomic,readonly) BOOL isNew;
@property (nonatomic,readonly) NSString * sectionId;
@property (nonatomic,retain) NSString *mnemonic; 

@property (nonatomic,retain) NSString *groupPrefix;
@property (nonatomic,retain) NSNumber *group;

@end
