//
//  NSDictionary+CellData.h
//  UIXML
//
//  Created by softphone on 25/11/2017.
//  Copyright © 2017 SOUL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CellData)

-(void)getStringForKey:(NSString *_Nonnull)key
             next:(void (^ _Nonnull )(NSString * _Nonnull value))next;
-(void)getStringForKey:(NSString *_Nonnull)key
             next:(void (^ _Nonnull )(NSString * _Nonnull value))next
         complete:(void (^ _Nonnull )(void))complete;
-(void)getNumberForKey:(NSString *_Nonnull)key
                   next:(void (^ _Nonnull )(NSNumber * _Nonnull value))next;
-(void)getNumberForKey:(NSString *_Nonnull)key
                  next:(void (^ _Nonnull )(NSNumber * _Nonnull value))next
              complete:(void (^ _Nonnull )(void))complete;
-(void)getArrayForKey:(NSString *_Nonnull)key
                  next:(void (^ _Nonnull )(NSArray * _Nonnull value))next;

@end
