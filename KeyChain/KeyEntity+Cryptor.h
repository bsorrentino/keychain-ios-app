//
//  KeyEntity+Crypto.h
//  KeyChain
//
//  Created by softphone on 25/09/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "KeyEntity.h"

extern const NSStringEncoding _ENCODING;

@interface KeyEntity (Cryptor)

-(void)encryptPassword;
-(void)decryptPassword;

-(BOOL)isPasswordDecrypted;

+(BOOL)isDataDecrypted:(NSData *)data;

-(NSString *)getPasswordDecrypted;
-(void)setPasswordToEncrypt:(NSString*)value;

@end
