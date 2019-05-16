//
//  RLNetworkCache.h
//  CodeForANF2
//
//  Created by relax on 2017/11/14.
//  Copyright © 2017年 relax. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 网络数据缓存类
@interface RLNetworkCache : NSObject


/**
 异步缓存网络数据，根据请求的 URL 和 parameters
 做 KEY 存储数据，这样就可以缓存多级页面的数据

 @param httpData 服务器返回的数据
 @param URL 请求的 URL 地址
 @param parameters 请求的参数
 */
+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters;



/**
 根据请求的 URL 和 parameters 来获取缓存数据

 @param URL 请求的 URL
 @param parameters  请求的参数
 @return 缓存的服务器数据
 */
+ (id)httpCacheForURL:(NSString *)URL parameters:(id)parameters;


/// 获取缓存的中大小(bytes)
+ (NSUInteger)getAllHttpCacheSize;

/// 删除所有的缓存
+ (void)removeAllHttpCache;
@end
