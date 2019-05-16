//
//  RLNetworkHelper.m
//  CodeForANF2
//
//  Created by relax on 2017/11/15.
//  Copyright © 2017年 relax. All rights reserved.
//

#import "RLNetworkHelper.h"
#import "RLNetworkCache.h"
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>

#ifdef DEBUG
#define NSLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define NSLog(...)
#endif

#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

@implementation RLNetworkHelper

static BOOL _isOpenLog;// 是否已打开日志打印
static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;

#pragma mark  - 开始监听网络状态
+ (void)networkStatusWithBlock:(RLNetworkStatus)networkStatusBlock {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                // block 判断语法。block如果存在，就执行 block；如果不存在，就什么也不干。
                networkStatusBlock ? networkStatusBlock(RLNetworkStatusTypeUnknow) : nil;
                if (_isOpenLog) {
                    NSLog(@"未知网络");
                }
                break;

            case AFNetworkReachabilityStatusNotReachable:
                networkStatusBlock ? networkStatusBlock(RLNetworkStatusTypeUNReachable) : nil;
                if (_isOpenLog) NSLog(@"无网络");
                break;

            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatusBlock ? networkStatusBlock(RLNetworkStatusTypeReachableViaWWAN) : nil;
                if (_isOpenLog) NSLog(@"手机网络");
                break;

            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatusBlock ? networkStatusBlock(RLNetworkStatusTypeReachableViaWiFi) : nil;
                if (_isOpenLog) NSLog(@"WiFi 网络");
                break;
        }
    }];
}

+ (BOOL)isNetWork {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)isWWANNetwork {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}

+ (BOOL)isWiFiNetwork {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}

+ (void)openLog {
    _isOpenLog = YES;
}

+ (void)closeLog {
    _isOpenLog = NO;
}

//- (void)closeOpen {
//    _isOpenLog = NO;
//}

#pragma mark - 取消所有请求任务
+ (void)cancelAllRequest {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            // 取消所有下载任务
            [task cancel];
        }];

        // 清除所有的下载任务
        [[self allSessionTask] removeAllObjects];

        dispatch_semaphore_signal(semaphore);
    });
}

#pragma mark - 根据请求的 URL 取消任务
+ (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) return;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString isEqualToString:URL]) {
                [task cancel];
                *stop = YES;
            }
        }];

        dispatch_semaphore_signal(semaphore);
    });
}

#pragma mark - HTTP GET 请求，不带缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(NSDictionary *)parameters
                  success:(RLHttpRequestSuccessBlock)successBlock
                  failure:(RLHttpRequestFailedBlock)failureBlock {

    return [self GET:URL parameters:parameters responseCache:nil success:successBlock failure:failureBlock];
}

#pragma mark - HTTP GET 请求，带缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(NSDictionary *)parameters
            responseCache:(RLHttpRequestCache)responseCacheBlock
                  success:(RLHttpRequestSuccessBlock)successBlock
                  failure:(RLHttpRequestFailedBlock)failureBlock {
    // 如果换成回调不为空，就执行缓存回调
    responseCacheBlock ? responseCacheBlock([RLNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;

    NSURLSessionTask *sessionTask = [_sessionManager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        // 这里不处理进度。

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) NSLog(@"responseObject = %@",responseObject);
        // 任务完成，将 task 从数组中清除。
        [[self allSessionTask] removeObject:task];

        successBlock ? successBlock(responseObject) : nil;
        // 对数据进行异步缓存
        responseCacheBlock ? [RLNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;


    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) NSLog(@"error = %@",error);
        [[self allSessionTask] removeObject:task];
        failureBlock ? failureBlock(error) : nil;
    }];

    // 添加当前请求任务的 session 到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;

    return sessionTask;
}


#pragma mark - POST 请求，不带缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(NSDictionary *)parameters
                   success:(RLHttpRequestSuccessBlock)successBlock
                   failure:(RLHttpRequestFailedBlock)failureBlock {
    return [self POST:URL parameters:parameters responseCache:nil success:successBlock failuer:failureBlock];
}


#pragma mark - POST 请求，带缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(NSDictionary *)parameters
             responseCache:(RLHttpRequestCache)responseCacheBlock
                   success:(RLHttpRequestSuccessBlock)successBlock
                   failuer:(RLHttpRequestFailedBlock)failureBlock {

    // 如果设置缓存 block，那么说明，需要从缓存中拿数据
    responseCacheBlock ? responseCacheBlock([RLNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;

    NSURLSessionTask *dataTask = [_sessionManager POST:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) NSLog(@"responseObject = %@",responseObject);
        successBlock ? successBlock(responseObject) : nil;
        // 把任务从数组中删除
        [[self allSessionTask] removeObject:task];
        // 设置缓存数据
        responseCacheBlock ? [RLNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) NSLog(@"error = %@",error);
        // 把任务从数据中删除
        [[self allSessionTask] removeObject:task];

        failureBlock ? failureBlock(error) : nil;
    }];

    dataTask ? [[self allSessionTask] addObject:dataTask] : nil;

    return dataTask;
}

#pragma mark - 上传文件
+ (NSURLSessionTask *)uploadFileWhitURL:(NSString *)URL
                             parameters:(NSDictionary *)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(RLHttpProgress)progrssBlock
                                success:(RLHttpRequestSuccessBlock)sucessBlock
                                failure:(RLHttpRequestFailedBlock)failureBlock {

    NSURLSessionTask *sessionTask = [_sessionManager
                                     POST:URL
                                     parameters:parameters
                                     constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                         NSError *error;
                                         NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                                         [formData appendPartWithFileURL:fileURL
                                     name:name error:&error];

                                         // 拼接文件上传失败的原因
                                         if (error && failureBlock) failureBlock(error);

                                     } progress:^(NSProgress * _Nonnull uploadProgress) {
                                         // 回调下载进度
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             progrssBlock ? progrssBlock(uploadProgress) : nil;
                                         });
                                     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                         // 将任务从数组中删除
                                         if (_isOpenLog) NSLog(@"responseObject = %@",responseObject);
                                         [[self allSessionTask] removeObject:task];
                                         sucessBlock ? sucessBlock(responseObject) : nil;
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                         if (_isOpenLog) NSLog(@"error = %@",error);
                                         [[self allSessionTask] removeObject:task];
                                         failureBlock ? failureBlock(error) : nil;
                                     }];

    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;

    return sessionTask;
}

#pragma mark - 上传多张图片
+ (NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                               parameters:(NSDictionary *)parameters
                                     name:(NSString *)name
                                   images:(NSArray<UIImage *> *)images
                                fileNames:(NSArray<NSString *> *)fileNames
                               imageScale:(CGFloat)imageScale
                                imageType:(NSString *)imageType
                                  progess:(RLHttpProgress)progessBlock
                                  success:(RLHttpRequestSuccessBlock)successBlock
                                  faliure:(RLHttpRequestFailedBlock)failureBlock {
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL
                                               parameters:parameters
                                constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                    
                                    for (NSInteger i = 0; i < images.count; i++) {
                                        // 图片经过等比压缩后得到的二进制文件
                                        NSData *imageData = UIImageJPEGRepresentation(images[i], imageScale ? imageScale : 1.0f);
                                        // 默认图片名，若 fileName 为 nil 的时候，就使用。
                                        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                                        dt.dateFormat = @"yyyyMMddHHmmss";
                                        NSString *str = [dt stringFromDate:[NSDate date]];
                                        NSString *imageFileName = [NSString stringWithFormat:@"%@%ld.%@",str,i,imageType ? imageType : @"jpg"];
                                        
                                        [formData appendPartWithFileData:imageData
                                                                    name:name
                                                                fileName:fileNames[i] ? fileNames[i] : imageFileName
                                                                mimeType:imageType ? imageType : @"jpg"];
                                    }
                                    
                                    
                                } progress:^(NSProgress * _Nonnull uploadProgress) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        progessBlock ? progessBlock(uploadProgress) : nil;
                                    });
                                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    if (_isOpenLog) NSLog(@"responseObject = %@",responseObject);
                                    [[self allSessionTask] removeObject:task];
                                    successBlock ? successBlock(responseObject) : nil;
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    if (_isOpenLog) NSLog(@"error = %@",error);
                                    [[self allSessionTask] removeObject:task];
                                    failureBlock ? failureBlock(error) : nil;
                                }];
    
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
    
    return sessionTask;
}

#pragma mark - 下载文件
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                              progess:(RLHttpProgress)progessBlock
                               sucess:(RLHttpRequestSuccessBlock)successBlock
                              failure:(RLHttpRequestFailedBlock)failureBlock {
    //
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];

    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        // 下载进度
        dispatch_async(dispatch_get_main_queue(), ^{
            progessBlock ? progessBlock(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 拼接缓存的目录
        NSString *downloadDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent: fileDir ? fileDir : @"Download"];
        // 打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 创建 download 目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        // 拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        // 返回文件完整的 URL 路径
        return [NSURL fileURLWithPath:filePath];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if (failureBlock && error) { failureBlock(error); return ;}
        successBlock ? successBlock(filePath.absoluteString) : nil;
    }];
    // 开始下载
    [downloadTask resume];

    //
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil;

    return downloadTask;
}

/**
 存放所有下载请求 task 的数组

 @return 存放所有下载请求 task 的数组
 */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [NSMutableArray array];
    }
    
    return _allSessionTask;
}


#pragma mark - 初始化 AFHTTPSessionManager 的相关属性
+ (void)load {
    // 开始检测网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    // _sessionManager.requestSerializer.con
    // 默认请求超时时间30秒
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    // 根据服务器返回的 response - content-type 类型来完成指定的数据序列化。
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain",@"text/javascript",@"text/xml",@"mage/*", nil];

    // 有网络请求时，打开转动的菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

#pragma mark - 重置 AFHTTPSessionManager 相关属性
+ (void)setAFHttpSessionManager:(void (^)(AFHTTPSessionManager *))setAFNSessionManagerBlock {
    setAFNSessionManagerBlock ? setAFNSessionManagerBlock(_sessionManager) : nil;
}

+ (void)setHttpRequesetSerializer:(RLRequestSerializer)requesetSerializer {
    _sessionManager.requestSerializer = requesetSerializer == RLRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setHttpResponseSerializer:(RLResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer == RLResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

+ (void)setRequestTimeOut:(NSTimeInterval)timeout {
    _sessionManager.requestSerializer.timeoutInterval = timeout;
}

+ (void)setValue:(NSString *)value forHttpHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDoaminName:(BOOL)validatesDomainName {
    // 获得证书数据
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    // 如果需要验证自建证书(无效证书),需要设置成 YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否要验证域名,默认 YES
    securityPolicy.validatesDomainName = validatesDomainName;
    // 设置证书数据
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];

    [_sessionManager setSecurityPolicy:securityPolicy];
}

@end

#pragma mark - NSArray,NSDictionary 的分类

/**
    可以让控制台打印 JSON 的中文。
 */



#ifdef DEBUG

@implementation NSArray (RL)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@,\n",obj];
    }];
    [strM appendFormat:@")"];

    return strM.copy;
}

@end


@implementation NSDictionary (RL)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@ = %@;\n",key,obj];
    }];
    [strM appendFormat:@"}\n"];

    return strM.copy;
}

@end

#endif


