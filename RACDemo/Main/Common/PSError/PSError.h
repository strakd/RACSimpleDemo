//
//  PSError.h
//  PersonnelSystem
//
//  Created by 宫傲 on 2018/9/19.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSError : NSObject

+ (NSError *)initWithResuletMsg:(NSString *)msg;

+ (NSError *)initWithResultCode:(NSString *)code msg:(NSString *)msg;

+ (NSError *)initWithResuletDict:(NSDictionary *)resuletDict;

@end
