//
//  RLNetworkCache.m
//  CodeForANF2
//
//  Created by relax on 2017/11/14.
//  Copyright © 2017年 relax. All rights reserved.
//

#import "RLNetworkCache.h"
#import <YYCache.h>


/** 此类的主要用途是里用YYCache，来实现内存和磁盘缓存 */

static NSString *const kRLNetworkResponseCache = @"kRLNetworkResponseCache";
static YYCache *_dataCache;

@implementation RLNetworkCache

// 一些和属性无关的内联静态数据，可以在 initialize 中初始化。
+ (void)initialize {
    _dataCache = [YYCache cacheWithName:kRLNetworkResponseCache];

    // [self cacheKeyWithURL:@"https://www.baidu.com" parameters:@{@"page":@1,@"index":@"aa",@"kw":@"hh"}];

}

+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters {
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    // 异步缓存，不会阻塞主线程。
    // pthread_mutex_lock 且是线程安全的。
    [_dataCache setObject:httpData forKey:cacheKey];
}

+ (id)httpCacheForURL:(NSString *)URL parameters:(id)parameters {
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

+ (NSUInteger)getAllHttpCacheSize {
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache {
    [_dataCache.diskCache removeAllObjects];
}

+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if (!parameters && parameters.count == 0) {
        return URL;
    }
    // 1. 将参数(NSDictionary)转换成 NSData。二进制里保存的本质上就是 JSON 格式字符串。
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    // 2. 获取NSData 转换成 JSON 格式字符串。
    NSString *paramString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",URL,paramString];

    return cacheKey;
}

@end
