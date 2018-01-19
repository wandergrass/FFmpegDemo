//
//  NLHttpSessionUnit.h
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import <AFNetworking/AFNetworking.h>
#import "NLMultipartFormArgument.h"

NS_ASSUME_NONNULL_BEGIN
//Block
typedef void (^OperationSuccessCompleteBlock)(NSURLSessionTask *sessionTask, id responseObject);
typedef void (^OperationFailureCompleteBlock)(NSURLSessionTask *sessionTask, NSError *error);

typedef enum HttpMethod{
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodDelete,
    HttpMethodHEAD,
}HttpMethod;

@interface NLHttpSessionUnit : AFHTTPSessionManager

#pragma mark - cancel
/**
 *  取消session中所有的请求
 */
- (void)cancelTasks;
#pragma mark - NSURLRequest
- (NSURLSessionDataTask *)request:(NSURLRequest *)request
             successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
             failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                   uploadProgress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                 downloadProgress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
             successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
             failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

#pragma mark - JSON Request
/**
 *  JSON文本上传方法
 *
 *  @param URLString            上传API地址
 *  @param parameters           纯表单参数
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                      jsonParameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;
#pragma mark -  multipartForm Request
/**
 *  多媒体数据文件上传
 *
 *  @param URLString                上传地址
 *  @param parameters               表单参数构成的数组
 *  @param multipartFormModels      格式模型
 *  @param uploadProgress           上传进度回调
 *  @param completeBlock            数据回调
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          parameters:(NSDictionary *)parameters
                multipartFormConfigs:(NSArray<NLMultipartFormArgument *> *)formModels
                            progress:(void (^)(NSProgress *uploadProgress)) uploadProgress
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

/**
 多媒体数据文件上传

 @param URLString 上传地址
 @param method 上传类型，不能是GET和HEAD
 @param parameters 表单参数构成的数组
 @param formModels 格式模型
 @param uploadProgress 上传进度回调
 @param successCompleteBlock 成功数据回调
 @param failureCompleteBlock 失败数据回调
 @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                multipartFormConfigs:(NSArray<NLMultipartFormArgument *> *)formModels
                            progress:(void (^)(NSProgress *))uploadProgress
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;
#pragma mark -  form Request
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                successCompleteBlock:(OperationSuccessCompleteBlock)successCompleteBlock
                failureCompleteBlock:(OperationFailureCompleteBlock)failureCompleteBlock;

@end
NS_ASSUME_NONNULL_END
