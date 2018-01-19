//
//  NLMultipartFormArgument.m
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import "NLMultipartFormArgument.h"

@implementation NLMultipartFormArgument
+ (instancetype)instancetypeWithMultipartFormContentType:(NLMultipartFormContentType)contentType
                                                     key:(NSString *)key
                                                  values:(NSArray *)values{
    NLMultipartFormArgument *formModel = [[NLMultipartFormArgument alloc] init];
    formModel.contentType = contentType;
    formModel.keyword = key;
    
    NSMutableArray *compressedArray = @[].mutableCopy;
    switch (contentType) {
        case NLMultipartFormContentTypeImage:
        {
            [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIImage class]]){
                    // 添加上传的图片
                    CGFloat compression = 0.5f;
                    CGFloat maxCompression = 0.1f;
                    int maxFileSize = 1024*1024;
                    
                    NSData *imgData = UIImageJPEGRepresentation(obj, compression);
                    while (imgData.length > maxFileSize && compression > maxCompression){
                        compression -= 0.1;
                        imgData = UIImageJPEGRepresentation(obj, compression);
                    }
                    
                    [compressedArray addObject:imgData];
                }
            }];
        }
            break;
        case NLMultipartFormContentTypeZip:
        {
            [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSURL class]]){
                    [compressedArray addObject:obj];
                }
            }];
        }
            break;
        case NLMultipartFormContentTypeAudio:
        {
            [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSURL class]]){
                    [compressedArray addObject:obj];
                }
            }];
        }
            break;
        default:
            break;
    }
    formModel.dataValues = compressedArray;
    return formModel;
}

@end
