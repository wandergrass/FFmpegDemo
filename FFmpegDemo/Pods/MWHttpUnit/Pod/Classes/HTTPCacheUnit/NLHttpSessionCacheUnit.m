//
//  NLHttpSessionCacheUnit.m
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import "NLHttpSessionCacheUnit.h"
#import "NSString+NLAddition.h"
#import "NLCacheArgument.h"
#import "NLCacheUnit.h"

@interface NLHttpSessionCacheUnit ()
@end

@implementation NLHttpSessionCacheUnit

#pragma mark - public methods
- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                    completeBlock:(OperationCompleteBlock)completeBlock{
    return [self request:request uploadProgress:nil downloadProgress:nil completeBlock:completeBlock];
}

- (NSURLSessionDataTask *)request:(NSURLRequest *)request
                   uploadProgress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                 downloadProgress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                    completeBlock:(OperationCompleteBlock)completeBlock{
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self request:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
        [self operationSuccessWithNSURLSessionTask:sessionTask
                                    responseObject:responseObject
                            operationCompleteBlock:completeBlock
                                     cacheArgument:nil];
    } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
        [self operationFailureWithNSURLSessionTask:sessionTask
                                             error:error
                            operationCompleteBlock:completeBlock
                                     cacheArgument:nil];
    }];
    return dataTask;
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                      jsonParameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    
    NSString *cacheKey = [self cacheKeyWithBaseUrl:[[self baseURL] absoluteString] requestUrl:URLString httpMethod:HttpMethodPost argument:parameters];
    __block NLCacheArgument *cacheArgument = [[NLCacheArgument alloc] initWithKey:cacheKey];
    
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self requestURL:URLString jsonParameters:parameters successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
        [self operationSuccessWithNSURLSessionTask:sessionTask
                                    responseObject:responseObject
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
        [self operationFailureWithNSURLSessionTask:sessionTask
                                             error:error
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    }];
    
    return dataTask;
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          parameters:(NSDictionary *)parameters
                multipartFormConfigs:(NSArray<NLMultipartFormArgument *> *)formModels
                            progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       completeBlock:(OperationCompleteBlock)completeBlock{
    NSString *cacheKey = [self cacheKeyWithBaseUrl:[[self baseURL] absoluteString] requestUrl:URLString httpMethod:HttpMethodPost argument:parameters];
    __block NLCacheArgument *cacheArgument = [[NLCacheArgument alloc] initWithKey:cacheKey];
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self requestURL:URLString parameters:parameters multipartFormConfigs:formModels progress:uploadProgress successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
        [self operationSuccessWithNSURLSessionTask:sessionTask
                                    responseObject:responseObject
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
        [self operationFailureWithNSURLSessionTask:sessionTask
                                             error:error
                            operationCompleteBlock:completeBlock
                                     cacheArgument:cacheArgument];
    }];
    return dataTask;
}

#pragma mark - 数据请求
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    
    return [self requestURL:URLString inQueue:nil HttpMethod:method parameters:parameters completeBlock:completeBlock];
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    return [self requestURL:URLString inQueue:queue inGroup:nil HttpMethod:method parameters:parameters completeBlock:completeBlock];
}

- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                       completeBlock:(OperationCompleteBlock)completeBlock{
    return [self requestURL:URLString inQueue:queue inGroup:group HttpMethod:method parameters:parameters cacheBodyWithBlock:NULL completeBlock:completeBlock];
}
- (NSURLSessionDataTask *)requestURL:(NSString *)URLString
                             inQueue:(dispatch_queue_t)queue
                             inGroup:(dispatch_group_t)group
                          HttpMethod:(HttpMethod)method
                          parameters:(NSDictionary *)parameters
                  cacheBodyWithBlock:(void (^)(id<NLCacheArgumentProtocol> cacheArgumentProtocol))cacheBlock
                       completeBlock:(OperationCompleteBlock)completeBlock{
    
    NSURLSessionDataTask *dataTask = nil;
    NSString *cacheKey = [self cacheKeyWithBaseUrl:[[self baseURL] absoluteString] requestUrl:URLString httpMethod:method argument:parameters];
    __block NLCacheArgument *cacheArgument = [[NLCacheArgument alloc] initWithKey:cacheKey];
    if (cacheBlock) {
        cacheBlock(cacheArgument);
    }
    //是否设置限制频繁数据请求
    if (cacheArgument.cacheOptions & NLCacheArgumentRestrictedFrequentRequests) {
        BOOL isCacheExpired = [[NLCacheUnit sharedSingleton] isCacheVersionExpiredForKey:cacheKey toCacheTimeInSeconds:(int)cacheArgument.cacheTimeInSeconds];
        if (!isCacheExpired) {
            id cacheObject = [self cacheObjectWithKey:cacheArgument.key];
            if (cacheObject) {
                if (completeBlock) {
                    NLResultUnit *result = [self resultUnitOperationNSURLSessionTask:dataTask callbackWithResponseObject:cacheObject];
                    NSAssert(result != nil, @"result must not be nil!");
                    [result setDataFromCache:YES];
                    completeBlock(dataTask, result);
                    return dataTask;
                }
            }
        }
    }
    
    dataTask = [self requestURL:URLString inQueue:queue inGroup:group HttpMethod:method parameters:parameters
           successCompleteBlock:^(NSURLSessionTask *sessionTask, id responseObject) {
               
               [self operationSuccessWithNSURLSessionTask:sessionTask
                                           responseObject:responseObject
                                   operationCompleteBlock:completeBlock
                                            cacheArgument:cacheArgument];
           } failureCompleteBlock:^(NSURLSessionTask *sessionTask, NSError *error) {
               
               [self operationFailureWithNSURLSessionTask:sessionTask
                                                    error:error
                                   operationCompleteBlock:completeBlock
                                            cacheArgument:cacheArgument];
           }];
    return dataTask;
}


#pragma mark - private methods
#pragma mark - overide
- (NLResultUnit *)resultUnitOperationNSURLSessionTask:(NSURLSessionTask *)dataTask callbackWithResponseObject:(id)responseObject{
    return nil;
}

- (NSArray *)parametersToBeFiltered{
    return nil;
}

#pragma mark - cache methods
- (id)cacheObjectWithKey:(NSString *)key{
    NSData *data = [[NLCacheUnit sharedSingleton] readDataForKey:key];
    id cacheObject = nil;
    if (data) {
        cacheObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return cacheObject;
}

- (NSString *)cacheKeyWithBaseUrl:(NSString *)baseUrl
                       requestUrl:(NSString *)requestUrl
                       httpMethod:(HttpMethod)method
                         argument:(NSDictionary *)argument{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:argument];
    NSArray *keys = [self parametersToBeFiltered];
    if (keys && keys.count) {
        [dic removeObjectsForKeys:keys];
    }
    
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@ AppVersion:%@",
                             (long)method, baseUrl, requestUrl,
                             [dic description], [NSString bundleShortVersionString]];
    NSString *cacheKey = [requestInfo MD5Hash];
    return cacheKey;
}

- (void)cacheJsonResponseJson:(id)jsonResponse byKey:(NSString *)key{
    if (jsonResponse != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:jsonResponse];
        [[NLCacheUnit sharedSingleton] writeData:data forKey:key];
    }
}
- (void)saveResponseToCacheFile:(id)responseObject withCacheArgument:(NLCacheArgument *)cacheArgument{
    if (!cacheArgument) {
        return;
    }
    if ((cacheArgument.cacheOptions & NLCacheArgumentResponseAtErrorRequest) || ((cacheArgument.cacheOptions & NLCacheArgumentRestrictedFrequentRequests) && [cacheArgument cacheTimeInSeconds] > 0)) {
        [self cacheJsonResponseJson:responseObject byKey:cacheArgument.key];
    }
}

#pragma mark - complete callback methods
- (void)operationSuccessWithNSURLSessionTask:(NSURLSessionTask *)dataTask
                              responseObject:(id)responseObject
                      operationCompleteBlock:(OperationCompleteBlock)completeBlock
                               cacheArgument:(NLCacheArgument *)cacheArgument{
    NLResultUnit *result = [self resultUnitOperationNSURLSessionTask:dataTask callbackWithResponseObject:responseObject];
    NSAssert(result != nil, @"result must not be nil!");
    if (completeBlock) {
        completeBlock(dataTask, result);
    }
    if (result.ableCache && cacheArgument) {
        [self saveResponseToCacheFile:responseObject withCacheArgument:cacheArgument];
    }
}

- (void)operationFailureWithNSURLSessionTask:(NSURLSessionTask *)dataTask
                                       error:(NSError *)error
                      operationCompleteBlock:(OperationCompleteBlock)completeBlock
                               cacheArgument:(NLCacheArgument *)cacheArgument{
    NLResultUnit *result = nil;
    if (cacheArgument && (cacheArgument.cacheOptions & NLCacheArgumentResponseAtErrorRequest)){
        id cacheObject = [self cacheObjectWithKey:cacheArgument.key];
        BOOL isCacheExpired = [[NLCacheUnit sharedSingleton] isCacheVersionExpiredForKey:cacheArgument.key
                                                                    toCacheTimeInSeconds:(int)cacheArgument.offlineTimeInSeconds];
        if (cacheObject && !isCacheExpired) {
            result = [self resultUnitOperationNSURLSessionTask:dataTask callbackWithResponseObject:cacheObject];
            [result setDataFromCache:YES];
        } else {
            result = [self resultUnitOperationNSURLSessionTask:dataTask callbackWithResponseObject:error];
        }
    } else {
        result = [self resultUnitOperationNSURLSessionTask:dataTask callbackWithResponseObject:error];
    }
    NSAssert(result != nil, @"result must not be nil!");
    [result setFailureRequest:YES];
    [result setError:error];
    
    if (completeBlock) {
        completeBlock(dataTask, result);
    }
}

@end
