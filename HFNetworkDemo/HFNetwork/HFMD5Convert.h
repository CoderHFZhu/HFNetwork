//
//  HFMD5Convert.h
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/13.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HFMD5Convert : NSObject

+ (NSString *)HFConvertMD5FromUrl:(NSString *)url Method:(NSString *)method Parameter:(NSDictionary *)paramDict;

@end
