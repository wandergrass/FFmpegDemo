//
//  NLCacheUnit.h
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import <Foundation/Foundation.h>

@interface NLCacheUnit : NSObject

+ (instancetype)sharedSingleton;

//返回是否当前缓存需要更新
- (BOOL)isCacheVersionExpiredForKey:(NSString *)key toCacheTimeInSeconds:(int)seconds;

//读取
- (NSData*)readDataForKey:(NSString*)key;
- (id)readModelForKey:(NSString*)key;
- (id)readModelFromPath:(NSString *)path;
//写
- (BOOL)writeData:(NSData*)data forKey:(NSString*)key;
- (BOOL)writeModel:(id)model forKey:(NSString *)key;
- (BOOL)writeModel:(id)model toPath:(NSString *)path;
@end
