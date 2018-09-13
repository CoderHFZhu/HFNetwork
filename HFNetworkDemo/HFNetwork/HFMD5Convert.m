//
//  HFMD5Convert.m
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/13.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import "HFMD5Convert.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString * HFConvertMD5FromString(NSString *str){
    
    if(str.length == 0){
        return nil;
    }
    
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (unsigned int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}


static NSString *HFNetCacheVersion(){
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}




@implementation HFMD5Convert
/**
 对传入的参数一起进行MD5加密，并生成该请求的缓存文件名
 
 @param url url地址
 @param method 请求方式
 @param paramDict 请求参数
 @return md5结果
 */
+(NSString *)HFConvertMD5FromUrl:(NSString *)url Method:(NSString *)method Parameter:(NSDictionary *)paramDict {
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%@ Url:%@ Argument:%@ AppVersion:%@ ",
                             method,
                             url,
                             paramDict,
                             HFNetCacheVersion()];
    
    return HFConvertMD5FromString(requestInfo);
}


@end

