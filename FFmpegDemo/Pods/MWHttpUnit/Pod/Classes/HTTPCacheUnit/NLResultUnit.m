//
//  NLResultUnit.m
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import "NLResultUnit.h"

@interface NLResultUnit ()
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, assign, readwrite) id responseObject;;
@end
@implementation NLResultUnit

#pragma mark setter
- (void)setError:(NSError *)error{
    if (_error != error) {
        _error = error;
    }
}
- (void)setResponseObject:(id)responseObject{
    if (_responseObject != responseObject) {
        _responseObject = responseObject;
    }
}
- (void)setDataFromCache:(BOOL)fromCache{
    _dataFromCache = fromCache;
}
- (void)setFailureRequest:(BOOL)failureRequest{
    _failureRequest = failureRequest;
}

@end
