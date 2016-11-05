//
//  StringEncryptionTransformer.m
//  KeyChain
//
//  Created by softphone on 20/09/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "StringEncryptionTransformer.h"
#import "RNCryptor/RNEncryptor.h"
#import "RNCryptor/RNDecryptor.h"
#import "KeyEntity+Cryptor.h"

#import "KeyChain-Swift.h"

//const NSStringEncoding _ENCODING = NSUnicodeStringEncoding;
//const NSStringEncoding _ENCODING = NSUTF8StringEncoding;

@interface StringEncryptionTransformer ()

- (NSString*)key;
+ (NSString *)dataToString:(NSData*)data;

@end

@implementation StringEncryptionTransformer

+ (NSData *)encryptData:(NSString *)source password:(NSString *)key
{
    NSParameterAssert(source!=nil);
    NSParameterAssert(key!=nil);
    
    if( source == nil ) return nil;
    
    NSData *dataEncoded = [source dataUsingEncoding:_ENCODING];
    if( key == nil ) return dataEncoded;
    
    NSError *error;
    
    NSData *encryptedData =
    [RNEncryptor encryptData:dataEncoded
                withSettings:kRNCryptorAES256Settings
                    password:key
                       error:&error];
    NSAssert( error == nil, @"encryption error" );
    NSAssert( encryptedData != nil, @"encryption result is null!" );
    
    if( error != nil ) {
        [NSException exceptionWithName:@"encryption error" reason:[error description] userInfo:[error userInfo]];
    }
    if( encryptedData == nil ) {
        [NSException exceptionWithName:@"encryption error" reason:@"encryption result is null!" userInfo:nil];
    }
    
    return encryptedData;
}

+ (NSString*)dataToString:(NSData *)data
{
    return [[NSString alloc] initWithData:data
                                 encoding:_ENCODING];
}

//Returns the key used for encrypting / decrypting values during transformation.
- (NSString*)key
{
    BOOL _encryptionEnabled = [AccountCredential sharedCredential].encryptionEnabled;
    
    // Your version of this class might get this key from the app delegate or elsewhere.
    return ( _encryptionEnabled ) ?
    [AccountCredential sharedCredential].password :
    nil;
}


#pragma mark - NSValueTransformer implementation

#define _COMPATIBILITY_MODE


+ (BOOL)allowsReverseTransformation
{
    return YES;
}

#ifdef _COMPATIBILITY_MODE

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)data
{
    if( data ) {
        if ([data isKindOfClass:[NSString class]]) {
            return [data dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ([data isKindOfClass:[NSData class]]) {
            return data;
        }
    }
    return nil;
}

- (id)reverseTransformedValue:(NSData*)data
{
    return data;
}

#else

+ (Class)transformedValueClass
{
    return [NSString class];
}

- (id)transformedValue:(NSString*)data
{
    if (nil == data) return nil;

    NSData *dataEncoded = [data dataUsingEncoding:_ENCODING];

    // If there's no key (e.g. during a data migration), don't try to transform the data
    if (nil == [self key]) return dataEncoded;    
    
    NSError *error = nil;
    
    NSData *encryptedData =
        [RNEncryptor encryptData:dataEncoded
                            withSettings:kRNCryptorAES256Settings
                            password:[self key]
                            error:&error];
    if( error != nil ) {
        NSLog(@"error encripting data\n[%@]", [error description] );
        return data;
    }
    if( encryptedData == nil ) {
        NSLog(@"error encripting data\nresult is nil" );
        return data;
    }
    
    return encryptedData;
}

- (id)reverseTransformedValue:(NSData*)encryptedData
{
    if (nil == encryptedData) return nil;

    // If there's no key (e.g. during a data migration), don't try to transform the data
    if (nil == [self key]) return [[self class] dataToString:encryptedData];
 
    
    NSError *error = nil;
    
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:[self key]
                                               error:&error];
    
    if( error != nil ) {
        NSLog(@"error decripting data\n[%@]", [error description] );
        return encryptedData;
    }
    if( decryptedData == nil ) {
        NSLog(@"error decripting data\nresult is nil" );
        return encryptedData;
    }
    
    return [[self class ]dataToString:decryptedData];
}

#endif




@end
