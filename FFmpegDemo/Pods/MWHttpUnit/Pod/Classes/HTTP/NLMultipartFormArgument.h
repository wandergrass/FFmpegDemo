//
//  NLMultipartFormArgument.h
//  Pods
//
//  Created by liu nian on 3/22/16.
//
//

#import <Foundation/Foundation.h>

typedef enum NLMultipartFormContentType{
    NLMultipartFormContentTypeNone,
    NLMultipartFormContentTypeImage,  //图片
    NLMultipartFormContentTypeZip,    //ZIP类型压缩文件
    NLMultipartFormContentTypeAudio,  //音频文件
}NLMultipartFormContentType;

@interface NLMultipartFormArgument : NSObject
@property (nonatomic, assign) NLMultipartFormContentType contentType;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSArray *dataValues;

+ (instancetype)instancetypeWithMultipartFormContentType:(NLMultipartFormContentType)contentType
                                                     key:(NSString *)key
                                                  values:(NSArray *)values;
@end
