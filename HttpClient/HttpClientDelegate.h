//
//  WrapperDelegate.h
//  WrapperTest
//
//  Created by Adrian on 10/18/08.
//  Copyright 2008 Adrian Kosmaczewski. All rights reserved.
//

#import <Foundation/Foundation.h> 

@class HttpClient;

@protocol HttpClientDelegate

@required
- (void)httpClient:(HttpClient *)httpClient didRetrieveData:(NSData *)data;

@optional
- (void)httpClientHasBadCredentials:(HttpClient *)wrapper;
- (void)httpClient:(HttpClient *)httpClient didCreateResourceAtURL:(NSString *)url;
- (void)httpClient:(HttpClient *)httpClient didFailWithError:(NSError *)error;
- (void)httpClient:(HttpClient *)httpClient didReceiveStatusCode:(int)statusCode;

@end
