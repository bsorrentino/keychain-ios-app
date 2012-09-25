//
//  AccountCredential.h
//  KeyChain
//
//  Created by softphone on 30/08/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountCredential : NSObject

+ (AccountCredential *)sharedCredential;

@property (nonatomic,unsafe_unretained) NSString *password;
@property (nonatomic,unsafe_unretained) NSString *version;
@property (nonatomic,assign) BOOL encryptionEnabled;

@property (nonatomic,unsafe_unretained,readonly,getter=getBundleVersion) NSString *bundleVersion;

-(BOOL)checkAndUpdateCurrentVersion;


@end
