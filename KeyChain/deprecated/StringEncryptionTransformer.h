//
//  StringEncryptionTransformer.h
//  KeyChain
//
//  Created by softphone on 20/09/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringEncryptionTransformer : NSValueTransformer


+ (NSData *)encryptData:(NSString *)source password:(NSString *)key; // raise exception

@end
