//
//  KeyEntity+Crypto.h
//  KeyChain
//
//  Created by softphone on 25/09/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "KeyEntity.h"

@interface KeyEntity (Cryptor)

-(void)encryptPassword;
-(void)decryptPassword;

-(BOOL)isPasswordDecrypted;

+(BOOL)isDataDecrypted:(NSData *)data;

@end
