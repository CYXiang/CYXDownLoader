//
//  CYXDownLoaderManager.h
//  CYXDownLoader
//
//  Created by 陈燕翔 on 2017/9/19.
//  Copyright © 2017年 陈燕翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYXDownLoader.h"

@interface CYXDownLoaderManager : NSObject

+ (instancetype)shareInstance;

- (void)downLoader:(NSURL *)url
      downLoadInfo:(DownLoadInfoType)downLoadInfo
          progress:(ProgressBlockType)progressBlock
           success:(SuccessBlockType)successBlock
            failed:(FailedBlockType)failedBlock;

//- (void)downLoaderWithURLs:(NSArray *)urlArray
//              downLoadInfo:(DownLoadInfoType)downLoadInfo
//                  progress:(ProgressBlockType)progressBlock
//                   success:(SuccessBlockType)successBlock
//                    failed:(FailedBlockType)failedBlock;


- (void)pauseWithURL:(NSURL *)url;
- (void)resumeWithURL:(NSURL *)url;
- (void)cancelWithURL:(NSURL *)url;

- (void)pauseAll;
- (void)resumeAll;

@end
