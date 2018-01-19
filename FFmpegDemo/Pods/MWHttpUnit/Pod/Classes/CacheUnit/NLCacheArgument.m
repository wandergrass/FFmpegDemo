//
//  NLCacheArgument.m
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import "NLCacheArgument.h"

@interface NLCacheArgument()
@property (nonatomic, strong, readwrite) NSString *key;
@end
@implementation NLCacheArgument

- (id)initWithKey:(NSString *)key;{
    if (self = [super init]) {
        self.key = key;
        self.cacheOptions = NLCacheArgumentIgnoreCache;
        _cacheTimeInSeconds = 0;
        _offlineTimeInSeconds = 7200;
    }
    return self;
}

#pragma mark NLCacheArgumentProtocol
- (void)cacheResponseWithCacheOptions:(NLCacheArgumentOptions)cacheOptions
                   cacheTimeInSeconds:(NSInteger)cacheTimeInSeconds
                 offlineTimeInSeconds:(NSInteger)offlineTimeInSeconds{
    self.cacheOptions = cacheOptions;
    self.cacheTimeInSeconds = cacheTimeInSeconds;
    self.offlineTimeInSeconds = offlineTimeInSeconds;
}

@end
