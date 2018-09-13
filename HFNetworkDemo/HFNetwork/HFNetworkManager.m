//
//  HFNetworkManager.m
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/13.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import "HFNetworkManager.h"
#import <AFNetworking.h>
#import "HFMD5Convert.h"
#import "HFNetLocalCache.h"

@interface HFNetworkManager()

@property (nonatomic, strong) HFNetLocalCache *cache;
@property (nonatomic, strong) NSMutableArray *taskGroup; //多任务处理
@property (nonatomic, strong) dispatch_queue_t HFQueue;  //异步操作，用于本地缓存读取


@end

@implementation HFNetworkManager
-(void)setMaxCacheSize:(NSUInteger)maxCacheSize{
    _maxCacheSize = maxCacheSize;
}
-(void)setMaxCacheDeadline:(NSInteger)maxCacheDeadline {
    _maxCacheDeadline = maxCacheDeadline;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _taskGroup = [NSMutableArray array];
        _cache = [HFNetLocalCache sharedInstance];
        _HFQueue = dispatch_queue_create("com.HF.HFqueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (nonnull instancetype)sharedInstance{
    static HFNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

/**
 * Clear all disk cached
 */
- (void)clearDisk{
    [_cache clearDisk];
}

#pragma mark ----- 简单网络请求的处理
// 使用默认配置的缓存策略 默认缓存时长 5 分钟
- (void)hf_GetCacheWithUrl:(NSString*)urlString
                parameters:(NSDictionary * _Nullable)parameters
         completionHandler:(HFRequestCompletionHandler)completionHandler{
    [self hf_GetWithURLString:urlString parameters:parameters ignoreCache:NO cacheDuration:kNetCacheDuration completionHandler:completionHandler];

}

- (void)hf_PostCacheWithUrl:(NSString*)urlString
                 parameters:(NSDictionary * _Nullable)parameters
          completionHandler:(HFRequestCompletionHandler)completionHandler{
    [self hf_PostWithURLString:urlString parameters:parameters ignoreCache:NO cacheDuration:kNetCacheDuration  completionHandler:completionHandler];

}

// 不使用缓存

- (void)hf_GetNoCacheWithUrl:(NSString*)urlString
                  parameters:(NSDictionary * _Nullable)parameters
           completionHandler:(HFRequestCompletionHandler)completionHandler{
    [self hf_GetWithURLString:urlString parameters:parameters ignoreCache:YES cacheDuration:0 completionHandler:completionHandler];
}
- (void)hf_PostNoCacheWithUrl:(NSString*)urlString
                   parameters:(NSDictionary * _Nullable)parameters
            completionHandler:(HFRequestCompletionHandler)completionHandler{
    [self hf_PostWithURLString:urlString parameters:parameters ignoreCache:YES cacheDuration:0 completionHandler:completionHandler];

}



#pragma mark ------- 自己设置缓存策略
- (void)hf_GetWithURLString:(NSString *)URLString
                parameters:(NSDictionary *)parameters
               ignoreCache:(BOOL)ignoreCache
             cacheDuration:(NSTimeInterval)cacheDuration
         completionHandler:(HFRequestCompletionHandler)completionHandler{
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.HFQueue, ^{
        [weakSelf taskWithMethod:@"GET" urlString:URLString parameters:parameters ignoreCache:ignoreCache cacheDuration:cacheDuration completionHandler:completionHandler];
    });
}
- (void)hf_PostWithURLString:(NSString *)URLString
                 parameters:(NSDictionary * _Nullable)parameters
                ignoreCache:(BOOL)ignoreCache
              cacheDuration:(NSTimeInterval)cacheDuration
          completionHandler:(HFRequestCompletionHandler)completionHandler{
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.HFQueue, ^{
        
        [weakSelf taskWithMethod:@"POST" urlString:URLString parameters:parameters ignoreCache:ignoreCache cacheDuration:cacheDuration completionHandler:completionHandler];
    });
    
}




#pragma mark ------------ 网络处理和配置

- (AFHTTPSessionManager*)afHttpManager{
    /*
     defaultSessionConfiguration
     默认配置使用的是持久化的硬盘缓存，存储证书到用户钥匙链。存储cookie到shareCookie。
     
     ephemeralSessionConfiguration
     返回一个不适用永久持存cookie、证书、缓存的配置，最佳优化数据传输。
     标注：当程序作废session时，所有的ephemeral session 数据会立即清除。此外，如果你的程序处于暂停状态，内存数据可能不会立即清除，但是会在程序终止或者收到内存警告或者内存压力时立即清除。
     
     backgroundSessionConfigurationWithIdentifier
     生成一个可以上传下载HTTP和HTTPS的后台任务(程序在后台运行)。
     在后台时，将网络传输交给系统的单独的一个进程。
     */
    AFHTTPSessionManager *afManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    return afManager;
}
- (void)taskWithMethod:(NSString*)method
             urlString:(NSString*)urlStr
            parameters:(NSDictionary *)parameters
           ignoreCache:(BOOL)ignoreCache
         cacheDuration:(NSTimeInterval)cacheDuration
     completionHandler:(HFRequestCompletionHandler)completionHandler{
    
    // 1 url + parameters 生成缓存文件的唯一识别码
    
    NSString *fileKeyName = [HFMD5Convert HFConvertMD5FromUrl:urlStr Method:method Parameter:parameters];
    
    __weak typeof(self) weakSelf = self;
    
    // 2 缓存+失效 判断是否有有效缓存
    if (!ignoreCache && [self.cache checkIfShouldUseCacheWithCacheDuration:cacheDuration cacheKey:fileKeyName]) {
        
        NSMutableDictionary *localCache = [NSMutableDictionary dictionary];
        NSDictionary *cacheDict = [self.cache searchCacheWithUrl:fileKeyName];
        [localCache setDictionary:cacheDict];
        if (cacheDict) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (weakSelf.exceptionBlock) {
                    weakSelf.exceptionBlock(nil, localCache);
                }
                completionHandler(nil, YES, localCache);
            });
            return;
        }
    }
    
    // 5 处理网络返回来的数据，hook 做一下缓存处理
    
    HFRequestCompletionHandler newCompletionBlock = ^(NSError* error,  BOOL isCache, NSDictionary* result){
        
        //5.1处理缓存  参数ignoreCache(网络task发起前，是否从本来缓存中获取数据)  cacheDuration(网络task结束后，是否对网络数据缓存)
        result = [NSMutableDictionary dictionaryWithDictionary:result];
        if (cacheDuration > 0) {// 缓存时效(即缓存时间)大于0
            if (result) {
                if (weakSelf.cacheConditionBlock) {
                    if (weakSelf.cacheConditionBlock(result)) {
                        [weakSelf.cache saveCacheData:result forKey:fileKeyName];
                    }
                }else{
                    [weakSelf.cache saveCacheData:result forKey:fileKeyName];
                }
            }
        }
        
        //5.2回掉
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.exceptionBlock) {
                weakSelf.exceptionBlock(error, (NSMutableDictionary*)result);
            }
            completionHandler(error, NO, result);
        });
        
    };

    
    
    NSURLSessionTask *task = nil;
    if ([method isEqualToString:@"POST"]) {
        task = [[self afHttpManager] GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            /*
             4 处理数据 （处理数据的时候，需要处理下载的网络数据是否要缓存）
             这里可以直接使用 completionHandler，如果这样，网络返回的数据没有做缓存处理机制，我们可以添加一步  可以hook一部分操作
             */
            newCompletionBlock(nil,NO, responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            newCompletionBlock(error,NO, nil);;
        }];
    }else{
        
        task = [self.afHttpManager POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            newCompletionBlock(nil,NO, responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            newCompletionBlock(error,NO, nil);
        }];
        
    }
    [task resume];
    
    
}

#pragma mark ---- 多任务-----
- (HFRequestModel *)hf_NetRequestWithURLStr:(NSString *)URLString
                                     method:(NSString*)method
                                 parameters:(NSDictionary *)parameters
                                ignoreCache:(BOOL)ignoreCache
                              cacheDuration:(NSTimeInterval)cacheDuration
                          completionHandler:(HFRequestCompletionHandler)completionHandler;{
    
    HFRequestModel *requestModel = [HFRequestModel new];
    requestModel.urlStr = URLString;
    requestModel.method = method;
    requestModel.parameters = parameters;
    requestModel.ignoreCache = ignoreCache;
    requestModel.cacheDuration = cacheDuration;
    requestModel.completionBlock = completionHandler;
    return requestModel;
}

- (void)hf_BatchOfRequestOperations:(NSArray<HFRequestModel *> *)tasks
                      progressBlock:(void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock
                   completionBlock:(HFNetSuccessbatchBlock)completionBlock{

    __weak typeof(self) weakSelf = self;
    dispatch_async(self.HFQueue, ^{
        
        __block dispatch_group_t group = dispatch_group_create();
        [weakSelf.taskGroup addObject:group];
        
        __block NSInteger finishedTasksCount = 0;
        __block NSInteger totalNumberOfTasks = tasks.count;
        
        [tasks enumerateObjectsUsingBlock:^(HFRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj) {
                
                // 网络任务启动前dispatch_group_enter
                dispatch_group_enter(group);
                
                HFRequestCompletionHandler newCompletionBlock = ^( NSError* error,  BOOL isCache, NSDictionary* result){
                    finishedTasksCount++;
                    progressBlock(finishedTasksCount, totalNumberOfTasks);
                    if (obj.completionBlock) {
                        obj.completionBlock(error, isCache, result);
                    }
                    // 网络任务结束后dispatch_group_enter
                    dispatch_group_leave(group);
                    
                };
                if ([obj.method isEqual:@"POST"]) {
                    
                    [[HFNetworkManager sharedInstance] hf_PostWithURLString:obj.urlStr parameters:obj.parameters ignoreCache:obj.ignoreCache cacheDuration:obj.cacheDuration completionHandler:newCompletionBlock];
                    
                }else{
                    
                    [[HFNetworkManager sharedInstance] hf_GetWithURLString:obj.urlStr parameters:obj.parameters ignoreCache:obj.ignoreCache cacheDuration:obj.cacheDuration completionHandler:newCompletionBlock];
                }
                
            }
            
        }];
        
        //监听
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [weakSelf.taskGroup removeObject:group];
            if (completionBlock) {
                completionBlock(tasks);
            }
        });
    });
}


@end
