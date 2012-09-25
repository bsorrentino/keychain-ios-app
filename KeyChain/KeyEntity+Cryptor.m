//
//  KeyEntity+Crypto.m
//  KeyChain
//
//  Created by softphone on 25/09/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "KeyEntity+Cryptor.h"
#import "AccountCredential.h"
#import "StringEncryptionTransformer.h"

@implementation KeyEntity (Cryptor)

-(void)encryptPassword
{
    NSData *dataEncoded = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData * mutable = [NSMutableData dataWithCapacity:[dataEncoded length] + 2];
    
    Byte prefix[2] = { 10, 10 };
    
    [mutable appendBytes:prefix length:2];
    [mutable appendData:dataEncoded];
    
    self.password = [[NSString alloc] initWithData:mutable encoding:NSUTF8StringEncoding];
    
}

-(BOOL)isPasswordDecrypted
{

    NSData *dataEncoded = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    
    return [[self class] isDataDecrypted:dataEncoded];
    
}

+(BOOL)isDataDecrypted:(NSData *)data
{
    NSAssert( data!=nil, @"data is nil!" );
    if( data == nil ) return NO;
    NSAssert( [data length] > 2, @"data length is invalid!" );
    if( [data length] <= 2 ) return NO;
    
    Byte * bytes = (Byte *)[data bytes];
    
    return ( bytes[0]==10 && bytes[1]==10 );
    
}

@end
