//
//  HFRequestModel.h
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/13.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 网络请求返回后的block

 @param error 异常信息
 @param isCache 是不是通过缓存获取的数据
 @param result 数据
 */
typedef void (^HFRequestCompletionHandler)( NSError* _Nullable error,  BOOL isCache, NSDictionary* _Nullable result);

/**
 多任务网络请求成功回调

 @param operationAry 请求任务数组
 */
typedef void (^HFNetSuccessbatchBlock)(NSArray *operationAry);

/**
 异常回调

 @param errror 错误信息
 @param result result
 */
typedef void (^HFRequestCompletionAddExcepetionHanle)(NSError* _Nullable errror,  NSMutableDictionary* result);

/**
 缓存控制  可以添加一下条件控制缓存是否存入  比如 异常的数据不写入缓存

 @param result 请求结果
 @return YES 缓存， NO不缓存
 */
typedef BOOL (^HFRequestCompletionAddCacheCondition)(NSDictionary *result);

@interface HFRequestModel : NSObject

@property(nonatomic, strong) NSString *urlStr;
@property(nonatomic, strong) NSString *method;
@property(nonatomic, strong) NSDictionary *parameters;
@property(nonatomic, assign) BOOL ignoreCache;
@property(nonatomic, assign) NSTimeInterval cacheDuration;
@property (nonatomic, copy) HFRequestCompletionHandler completionBlock;



@end
