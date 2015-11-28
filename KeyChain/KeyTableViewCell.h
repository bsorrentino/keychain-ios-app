//
//  KeyTableViewCell.h
//  KeyChain
//
//  Created by softphone on 09/08/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "ZKRevealingTableViewCell/ZKRevealingTableViewCell.h"

@class KeyEntity;

@interface KeyTableViewCell : ZKRevealingTableViewCell


@property (KEYCHAIN_WEAK,nonatomic) KeyEntity *entity;
@end
