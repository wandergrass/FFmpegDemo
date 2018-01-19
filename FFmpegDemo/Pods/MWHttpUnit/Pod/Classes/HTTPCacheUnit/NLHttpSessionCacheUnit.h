//
//  NLHttpSessionCacheUnit.h
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

//该类是集成网络请求和缓存的功能组件，是为了解决服务器不支持Cache-Control和POST请求而设计的高度集成了返回数据的业务结果集.
#import "NLHttpSessionUnit.h"
#import "NLResultUnit.h"
#import "NLCacheArgument.h"

typedef void (^OperationCompleteBlock)(NSURLSessionTask *sessionTask, NLResultUnit *resultUnit);
@interface NLHttpSessionCacheUnit : NLHttpSessionUnit

/** Requst */
- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                    completeBlock:(OperationCompleteBlock)completeBlock;

- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                   uploadProgress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                 downloadProgress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                    completeBlock:(OperationCompleteBlock)completeBlock;

/** JSON Requst */
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                      jsonParameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock;
/** Multipart File Requst */
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          parameters:(NSDictionary *)parameters
                multipartFormConfigs:(NSArray<NLMultipartFormArgument *> *)formModels
                            progress:(void (^)(NSProgress *uploadProgress)) uploadProgress
                       completeBlock:(OperationCompleteBlock)completeBlock;
/** Form Requst */
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock;

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock;

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock;

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                  cacheBodyWithBlock:(void (^)(id<NLCacheArgumentProtocol> cacheArgumentProtocol))cacheBlock
                       completeBlock:(OperationCompleteBlock)completeBlock;

#pragma mark - overide
/**
 *  由于各服务器业务数据的不同导致返回的数据结果集结构不同，由于数据存储的必须是正确的业务数据故该方法是有各业务继承NLResultUnit实现
 *  返回值必须继承NLResultUnit实现各业务数据，必须实现ableCache来定义是否能够进行数据缓存.
 *  注意:数据上传业务中ableCache无效
 *
 *  @param dataTask 发出请求的实体
 *
 *  @param responseObject 服务器请求成功返回的原始数据对象,当请求错误时是错误实例:NSError
 *
 *  @return 继承NLResultUnit的之类实例
 */
- (NLResultUnit *)resultUnitOperationNSURLSessionTask:(NSURLSessionTask *)dataTask callbackWithResponseObject:(id)responseObject;
/**
 *  该缓存组件中缓存标示是有请求中请求类型(Method),Host地址(BaseURL),API接口地址,
 *  参数KV和APP版本(CFBundleShortVersionString)组成的字符串进行MD5加密生成，所
 *  以对于一些灵活的参数例如：经纬度等，由于每次改变造成缓存无法使用，所以该方法是提供
 *  一个需要过滤的参数key组成的数组
 *
 *  @return 需要过滤的参数key组成的数组
 */
- (NSArray *)parametersToBeFiltered;
@end
