//
//  HFNetLocalCache.h
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/13.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HFNetLocalCache : NSObject
//缓存最长保留时间
@property (assign, nonatomic) NSInteger maxCacheDeadline;
//最大容量 1024 * 1024 * 100;
@property (assign, nonatomic) NSUInteger maxCacheSize;


+ (nonnull instancetype)sharedInstance;
/**
 * Clear all disk cached
 */
- (void)clearDisk;
-(BOOL)checkIfShouldUseCacheWithCacheDuration:(NSTimeInterval)cacheDuration cacheKey:(NSString*)urlkey;

- (id)searchCacheWithUrl:(NSString *)urlkey;

- (void)saveCacheData:(id<NSCopying>)data forKey:(NSString*)key;

/*
 数据屏蔽  忽略某些指定的页面的数据不被删除  暂时屏蔽 思考一下解耦
 */

//-(void)addProtectCacheKey:(NSString*)key;

@end
