//
//  RLNetworkHelper.h
//  CodeForANF2
//
//  Created by relax on 2017/11/15.
//  Copyright © 2017年 relax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RLNetworkCache.h"// 导入封装了 YYCache 的缓存内。


#ifndef kIsNetwork
#define kIsNetwork [RLNetworkHelper isNetwork] // 一次性判断是否有网的宏
#endif

#ifndef kIsWWANNetwork
#define kIsWWANNetwork [RLNetworkHelper isWWANNetwork] // 一次性判断是否为手机网络(3G/4G)的宏
#endif

#ifndef kIsWiFiNetwork
#define kIsWiFiNetwork [RLNetworkHelper isWiFiNetwork] // 一次性判断是否是 WiFi 网络的宏
#endif



/// 网络状态枚举
typedef NS_ENUM(NSUInteger, RLNetworkStatusType) {
    /// 未知网络
    RLNetworkStatusTypeUnknow,
    /// 无网络
    RLNetworkStatusTypeUNReachable,
    /// 手机网络 3G/4G
    RLNetworkStatusTypeReachableViaWWAN,
    /// WiFi 网络
    RLNetworkStatusTypeReachableViaWiFi,
};

/// 后台需要的请求数据格式(JSON/HTTP)
typedef NS_ENUM(NSUInteger,RLRequestSerializer) {
    /// 设置请求的数据位 JSON 数据格式(奇葩数据要求)
    RLRequestSerializerJSON,
    /// 设置请求的数据为普通的 HTTP 请求数据格式(web 浏览器默认)
    RLRequestSerializerHTTP,
};

/// 响应的数据格式，根据这个格式是把服务器返回的 NSData 直接返回，还是转换成字典后在返回
typedef NS_ENUM(NSUInteger, RLResponseSerializer) {
    /// 设置相应格式为 JSON 格式。(NSData -> NSDictionary)
    RLResponseSerializerJSON,
    /// 不处理服务器返回的数据格式，按原始的返回
    RLResponseSerializerHTTP,
};


/// 请求成功的回调
typedef void(^RLHttpRequestSuccessBlock)(id responseObject);

/// 请求失败的回调
typedef void(^RLHttpRequestFailedBlock)(NSError *error);

/// 缓存的 block
typedef void(^RLHttpRequestCache)(id responseCache);

// 上传或者下载进度的回调
// progess.complectedUnitCount:已经下载的字节数  progress.totalUnitCount:当前文件下载的总字节数据
typedef void(^RLHttpProgress)(NSProgress *progrss);

/// 网络状态的回调
typedef void(^RLNetworkStatus)(RLNetworkStatusType);

// 网络请求需要用到AFN这个类
@class AFHTTPSessionManager;


@interface RLNetworkHelper : NSObject

/// 有网 YES ，无网 NO
+ (BOOL)isNetWork;

/// 3G/4G 网 YES ，否则 NO。
+ (BOOL)isWWANNetwork;

/// WiFi 网络 YES,否则 NO。
+ (BOOL)isWiFiNetwork;

/// 取消所有网络请求
+ (void)cancelAllRequest;

/// 实时获取当前网络状态，通过 block 回调实时获取。
+ (void)networkStatusWithBlock:(RLNetworkStatus)networkStatusBlock;

/// 根据 URL 取消指定的网络任务
+ (void)cancelRequestWithURL:(NSString *)URL;

/// 开启日志打印(DEBUG 模式下生效)
+ (void)openLog;

/// 关闭打印
+ (void)closeLog;




/**
 GET请求，无缓存

 @param URL 请求地址
 @param parameters 请求参数
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 @return 返回的对象可以取消请求，使用 cancel 方法。
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(NSDictionary *)parameters
                           success:(RLHttpRequestSuccessBlock)successBlock
                           failure:(RLHttpRequestFailedBlock)failureBlock;





/**
 GET请求，自动缓存

 @param URL 请求的链接
 @param parameters 请求的参数
 @param responseCacheBlock 缓存的 block
 @param successBlock  请求成功回调
 @param failureBlock 请求失败回调
 @return 返回对象可取消请求，调用 cancel 方法。
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(NSDictionary *)parameters
                     responseCache:(RLHttpRequestCache)responseCacheBlock
                           success:(RLHttpRequestSuccessBlock)successBlock
                           failure:(RLHttpRequestFailedBlock)failureBlock;





/**
 POST请求，无缓存

 @param URL 请求的 URL 链接
 @param parameters 请求的参数
 @param successBlock 请求的成功回调
 @param failureBlock 请求的失败回调
 @return 返回对象可取消请求，调用 cancel 方法。
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                            success:(RLHttpRequestSuccessBlock)successBlock
                            failure:(RLHttpRequestFailedBlock)failureBlock;




/**
 POST请求，自动缓存

 @param URL 请求的 URL 链接
 @param parameters 请求的参数
 @param responseCacheBlock 缓存的 block
 @param successBlock 请求的成功回调
 @param failureBlock 请求的失败回调
 @return 返回对象可取消请求，调用 cancel 方法。
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                      responseCache:(RLHttpRequestCache)responseCacheBlock
                            success:(RLHttpRequestSuccessBlock)successBlock
                            failuer:(RLHttpRequestFailedBlock)failureBlock;



/**
 上传文件

 @param URL 请求地址
 @param parameters 请求参数
 @param name 后端对应的文件名 key
 @param filePath  本地文件的沙盒路径
 @param progrssBlock 上传进度回调
 @param sucessBlock 上传成功回调
 @param failureBlock 上传失败回到
 @return 返回对象可取消请求，调用 cancel 方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWhitURL:(NSString *)URL
                                      parameters:(NSDictionary *)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(RLHttpProgress)progrssBlock
                                         success:(RLHttpRequestSuccessBlock)sucessBlock
                                         failure:(RLHttpRequestFailedBlock)failureBlock;






/**
 上传单/多张图片

 @param URL 请求地址
 @param parameters 请求参数
 @param name 服务器获取图片的 name key
 @param images 图片数据
 @param fileNames 图片文件名数组，可以为 nil，数组内的文件默认名为当前的日期时间(yyyyMMddHHmmss)
 @param imageScale 图片文件的压缩比(0.1-1.0)
 @param imageType 图片文件的类型
 @param progessBlock 上传进度信息
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 @return 返回对象可取消请求，调用 cancel 方法
 */
+ (__kindof NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                                        parameters:(NSDictionary *)parameters
                                              name:(NSString *)name
                                            images:(NSArray<UIImage *> *)images
                                         fileNames:(NSArray<NSString *> *)fileNames
                                        imageScale:(CGFloat)imageScale
                                         imageType:(NSString *)imageType
                                           progess:(RLHttpProgress)progessBlock
                                           success:(RLHttpRequestSuccessBlock)successBlock
                                           faliure:(RLHttpRequestFailedBlock)failureBlock;



/**
 下载文件

 @param URL 请求地址
 @param fileDir 文件存储目录(默认存储目录为 cache/download)
 @param progessBlock 下载进度信息
 @param successBlock 下载成功回调(回调参数为 filePath:文件存储的沙盒路径)
 @param failureBlock 失败回调
 @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                       progess:(RLHttpProgress)progessBlock
                                        sucess:(RLHttpRequestSuccessBlock)successBlock
                                       failure:(RLHttpRequestFailedBlock)failureBlock;





#pragma mark - 对 AFNetworking 的 AFHttpSessionManager 的自定义配置
#pragma mark 注意：因为全局只有一个 AFHttpSessionManager 的实例，所以下列方式设置是全局设置。


/**
 设置全局唯一的 AFHttpSessionManager.

 @param setAFNSessionManagerBlock 在此 block 中设置。
 */
+ (void)setAFHttpSessionManager:(void(^)(AFHTTPSessionManager *))setAFNSessionManagerBlock;


/**
 设置请求到后台的数据格式，默认使用 HTTP 默认的(二进制)

 @param requesetSerializer RLRequestSerializerJSON(JSON 格式，奇葩后台用)/RLRequestSerializerHTTP(默认的)
 */
+ (void)setHttpRequesetSerializer:(RLRequestSerializer)requesetSerializer;



/**
 设置服务器响应后台的数据是直接返回二进制数据还是字典

 @param responseSerializer RLResponseSerializerJSON(字典/默认) RLResponseSerializerHTTP(二进制)
 */
+ (void)setHttpResponseSerializer:(RLResponseSerializer)responseSerializer;


/**
 设置请求超时时间

 @param timeout 默认30秒
 */
+ (void)setRequestTimeOut:(NSTimeInterval)timeout;

/**
 设置 HTTP 请求头协议

 @param value 协议的值
 @param field 协议的头
 */
+ (void)setValue:(NSString *)value forHttpHeaderField:(NSString *)field;


/// 是否打开转菊花:默认打开
+ (void)openNetworkActivityIndicator:(BOOL)open;


/**
 配置自建证书的 Https 请求，参考链接：http://blog.csdn.net/syg90178aw/article/details/52839103

 @param cerPath 自建证书的链接
 @param validatesDomainName 是否需要验证域名，默认 YES.如果证书的域名与请求的域名不一致，则需要设置成 NO.即服务器使用其他新人机构颁发的证书，也可以建立链接。这个非常危险，
        建议打开 .validatesDomainName=NO.主要用于，客户端请求的是子域名，而证书上是另外一个域名。
    因为 SSL 证书上的域名是独立的。加入证书的域名是 www.google.com 而客户端访问的域名是 mail.google.com 则此证书就无法验证通过。
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDoaminName:(BOOL)validatesDomainName;










@end
