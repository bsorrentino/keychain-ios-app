//
//  KeyListDataSource.h
//  KeyChain
//
//  Created by softphone on 13/10/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol KeyListDataSource <NSObject>

@required

- (NSArray *)fetchedObjects;

- (NSEntityDescription *)entityDescriptor;

- (void)filterReset;

@end
