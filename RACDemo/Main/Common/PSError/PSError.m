//
//  PSError.m
//  PersonnelSystem
//
//  Created by 宫傲 on 2018/9/19.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "PSError.h"

@implementation PSError

+ (NSError *)initWithResuletMsg:(NSString *)msg {
    return [self initWithResultCode:@"11" msg:msg];
}

+ (NSError *)initWithResultCode:(NSString *)code msg:(NSString *)msg {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"msg"] = msg;
    dict[@"code"] = code;
    return [self initWithResuletDict:dict];
}

+ (NSError *)initWithResuletDict:(NSDictionary *)resuletDict {
    NSError *error = [NSError errorWithDomain:@"CommandErrorDomain" code:7000 userInfo:resuletDict];
    return error;
}

@end
