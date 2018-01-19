//
//  NLCacheUnit.m
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import "NLCacheUnit.h"

#if DEBUG
#define NLLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NLLog(xx, ...)  ((void)0)
#endif

@interface NLCacheUnit ()
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) dispatch_queue_t file_queue_t;
@end

@implementation NLCacheUnit

- (id)init{
    if (self = [super init]) {
        _cache = [[NSCache alloc] init];
        [self checkDirectory:[self projectCacheFilePath]];
    }
    return self;
}

+ (instancetype)sharedSingleton;{
    static NLCacheUnit *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NLCacheUnit alloc] init];
    });
    
    return _sharedClient;
}

#pragma mark private
- (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NLLog(@"error to set do not backup attribute, error = %@", error);
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NLLog(@"create cache directory failed, error = %@", error);
    } else {
        [self addDoNotBackupAttribute:path];
    }
}

- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}
- (NSString *)applicationCachesDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES) lastObject];
}
#pragma mark - 保存数据情况缓存
- (NSString *)projectCacheFilePath{
    NSString *cacheDirectory = [self applicationCachesDirectory];
    return [cacheDirectory stringByAppendingPathComponent:@"ResponseCache"];
}
- (NSString *)filePathForKey:(NSString *)key{
    return [[self projectCacheFilePath] stringByAppendingPathComponent:key];
}

- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        NLLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

#pragma public methods
- (BOOL)isCacheVersionExpiredForKey:(NSString *)key toCacheTimeInSeconds:(int)cacheTimeInSeconds{
    // check cache existance
    NSString *path = [self filePathForKey:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        return YES;
    }
    // check cache time
    int seconds = [self cacheFileDuration:path];
    if (seconds < 0 || seconds > cacheTimeInSeconds) {
        return YES;
    }
    return NO;
}

#pragma mark - read
- (NSData*)readDataForKey:(NSString*)key{
    if(!key){
        return nil;
    }
    NSData *cacheData = [_cache objectForKey:key];
    if(cacheData){
        return cacheData;
    }else{
        NSString *filepath =[self filePathForKey:key];
        NSData *fileData =  [[NSFileManager defaultManager] contentsAtPath:filepath];
        if(fileData){
            [_cache setObject:fileData forKey:key];
        }
        return fileData;
    }
}

- (id)readModelForKey:(NSString*)key{
    if(!key){
        return nil;
    }
    NSString *filepath  = [self filePathForKey:key];
    return [self readModelFromPath:filepath];
}

- (id)readModelFromPath:(NSString *)path{
    NSFileManager *fileman = [NSFileManager defaultManager];
    if ([fileman fileExistsAtPath:path]){
        return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    return nil;
}
#pragma mark - write
- (BOOL)writeData:(NSData*)data forKey:(NSString*)key{
    NSString *filepath  = [self filePathForKey:key];
    if (data ) {
        [_cache setObject:data forKey:key];
    }else{
        [_cache removeObjectForKey:key];
    }
    __block BOOL result = NO;
    dispatch_async(self.file_queue_t, ^{
        if (data) {
            result = [[NSFileManager defaultManager] createFileAtPath:filepath contents:data attributes:nil];
        }else{
            NSError *error = nil;
            result = [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
            if (error) {
                NLLog(@"error:%@",error);
            }
        }
    });
    return result;
}

- (BOOL)writeModel:(id)model forKey:(NSString *)key{
    NSString *filepath  = [self filePathForKey:key];
    return [self writeModel:model toPath:filepath];
}

- (BOOL)writeModel:(id)model toPath:(NSString *)path{
    return [NSKeyedArchiver archiveRootObject:model toFile:path];
}

#pragma mark - remove
- (void)removeCacheDataForKey:(NSString *)key{
     NSString *filepath  = [self filePathForKey:key];
    // check cache existance
    NSString *path = [self filePathForKey:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        [_cache removeObjectForKey:key];
        __block BOOL result = NO;
        dispatch_async(self.file_queue_t, ^{
            NSError *error = nil;
            result = [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
            if (error) {
                NLLog(@"error:%@",error);
            }
        });
    }
}
#pragma mark getter
- (dispatch_queue_t)file_queue_t{
    if (_file_queue_t == nil) {
        _file_queue_t = dispatch_queue_create("com.PusceneSerialQueue.fileCache", DISPATCH_QUEUE_SERIAL);
    }
    return _file_queue_t;
}

@end
