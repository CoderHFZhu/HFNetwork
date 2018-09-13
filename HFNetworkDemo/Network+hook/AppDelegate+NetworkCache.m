//
//  AppDelegate+NetworkCache.m
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/13.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import "AppDelegate+NetworkCache.h"
#import "HFNetworkManager.h"
@implementation AppDelegate (NetworkCache)
- (void)configNetCacheCondition{
    // return YES 缓存， NO不缓存 可以在这里配置一下缓存的条件
    [HFNetworkManager sharedInstance].cacheConditionBlock = ^BOOL(NSDictionary * _Nonnull result) {
        
        if([result isKindOfClass:[NSDictionary class]]){
            
            if([[result objectForKey:@"success"] intValue] == 0){
                
                return NO;
            }
        }
        
        return YES;
    };
}
@end
