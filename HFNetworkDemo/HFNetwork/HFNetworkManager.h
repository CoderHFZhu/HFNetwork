//
//  HFNetworkManager.h
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/13.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HFRequestModel.h"

//默认缓存时长
#define kNetCacheDuration (5 * 60)

@interface HFNetworkManager : NSObject



//缓存最长保留时间  defult  60 * 60 * 24 * 30  30天
@property (assign, nonatomic) NSInteger maxCacheDeadline;
//最大容量
@property (assign, nonatomic) NSUInteger maxCacheSize;

/**
 外部添加异常处理 （根据服务器返回的数据，统一处理，如处理登录实效），默认不做处理
 */
@property (nonatomic, copy)HFRequestCompletionAddExcepetionHanle exceptionBlock;
//// 返回NO， cache不保存
@property (nonatomic, copy)HFRequestCompletionAddCacheCondition cacheConditionBlock;

+ (nonnull instancetype)sharedInstance;

/**
 * Clear all disk cached
 */
- (void)clearDisk;

// 使用默认配置的缓存策略
- (void)hf_GetCacheWithUrl:(NSString*)urlString
               parameters:(NSDictionary * _Nullable)parameters
        completionHandler:(HFRequestCompletionHandler)completionHandler;

- (void)hf_PostCacheWithUrl:(NSString*)urlString
                parameters:(NSDictionary * _Nullable)parameters
         completionHandler:(HFRequestCompletionHandler)completionHandler;

// 不使用缓存
- (void)hf_PostNoCacheWithUrl:(NSString*)urlString
                  parameters:(NSDictionary * _Nullable)parameters
           completionHandler:(HFRequestCompletionHandler)completionHandler;

- (void)hf_GetNoCacheWithUrl:(NSString*)urlString
                 parameters:(NSDictionary * _Nullable)parameters
          completionHandler:(HFRequestCompletionHandler)completionHandler;


#pragma  mark ---- 缓存策略
/**
 GET请求
 
 @param URLString url地址
 @param parameters 请求参数
 @param ignoreCache 是否忽略缓存，YES 忽略，NO 不忽略
 @param cacheDuration 缓存实效
 @param completionHandler 请求结果处理
 */
- (void)hf_GetWithURLString:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                ignoreCache:(BOOL)ignoreCache
              cacheDuration:(NSTimeInterval)cacheDuration
          completionHandler:(HFRequestCompletionHandler)completionHandler;

/**
 POST请求
 @param URLString url地址
 @param parameters 请求参数
 @param ignoreCache 是否忽略缓存，YES 忽略，NO 不忽略
 @param cacheDuration 缓存实效
 @param completionHandler 请求结果处理
 */
- (void)hf_PostWithURLString:(NSString *)URLString
                 parameters:(NSDictionary * _Nullable)parameters
                ignoreCache:(BOOL)ignoreCache
              cacheDuration:(NSTimeInterval)cacheDuration
          completionHandler:(HFRequestCompletionHandler)completionHandler;


#pragma mark -----多任务请求---
/**
 保存网络请求信息 和 batchOfRequestOperations方法一起用
 */
- (HFRequestModel *)hf_NetRequestWithURLStr:(NSString *)URLString
                                     method:(NSString*)method
                                 parameters:(NSDictionary *)parameters
                                ignoreCache:(BOOL)ignoreCache
                              cacheDuration:(NSTimeInterval)cacheDuration
                          completionHandler:(HFRequestCompletionHandler)completionHandler;

/**
 执行多个网络请求
 
 @param tasks 请求信息
 @param progressBlock 网络任务完成的进度
 @param completionBlock tasks中所有网络任务结束
 */
- (void)hf_BatchOfRequestOperations:(NSArray<HFRequestModel *> *)tasks
                     progressBlock:(void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock
                   completionBlock:(HFNetSuccessbatchBlock)completionBlock;




@end
