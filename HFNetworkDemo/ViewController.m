//
//  ViewController.m
//  HFNetworkDemo
//
//  Created by CoderHF on 2018/9/12.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import "ViewController.h"
#import "HFNetworkManager.h"
#import "HFRequestModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *infodict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"versions_id", @"1", @"system_type", nil];

    [[HFNetworkManager sharedInstance] hf_PostCacheWithUrl:@"http://svr.tuliu.com/center/front/app/util/updateVersions" parameters:infodict completionHandler:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        NSLog(@"%@",result);

    }];
    
    
    
   
    [self batchNetTask];
    
}


- (void)batchNetTask{
    NSDictionary *infodictOne = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"versions_id", @"1", @"system_type", nil];
    HFRequestModel *infoNetOne = [[HFNetworkManager sharedInstance] hf_NetRequestWithURLStr:@"http://svr.tuliu.com/center/front/app/util/updateVersions" method:@"POST" parameters:infodictOne ignoreCache:NO cacheDuration:20 completionHandler:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        
        if (isCache) {
            NSLog(@"isCache");
        }
        
    }];
    
    NSDictionary *infodictTwo = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"versions_id", @"1", @"system_type", nil];
    HFRequestModel *infoNetTwo = [[HFNetworkManager sharedInstance] hf_NetRequestWithURLStr:@"http://svr.tuliu.com/center/front/app/util/updateVersions" method:@"POST" parameters:infodictTwo ignoreCache:NO cacheDuration:20 completionHandler:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        
        if (isCache) {
            NSLog(@"isCache");
        }
        
    }];
    
    
    NSArray *taskAry = [NSArray arrayWithObjects:infoNetOne, infoNetTwo, nil];
    [[HFNetworkManager sharedInstance] hf_BatchOfRequestOperations:taskAry progressBlock:^(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks) {
        NSLog(@"%lu,%lu",(unsigned long)numberOfFinishedTasks,(unsigned long)totalNumberOfTasks);
        
    } completionBlock:^(NSArray * _Nonnull operationAry) {
        NSLog(@"%@",operationAry);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
