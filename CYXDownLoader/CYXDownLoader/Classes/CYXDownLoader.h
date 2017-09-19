//
//  CYXDownLoader.h
//  CYXDownLoader
//
//  Created by 陈燕翔 on 2017/9/16.
//  Copyright © 2017年 陈燕翔. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CYXDownLoadState) {
    CYXDownLoadStatePause,
    CYXDownLoadStateDownLaoding,
    CYXDownLoadStateSuccess,
    CYXDownLoadStateFailed
};

typedef void(^DownLoadInfoType)(long long totalSize);
typedef void(^ProgressBlockType)(float progress);
typedef void(^SuccessBlockType)(NSString *filePath);
typedef void(^FailedBlockType)(void);
typedef void(^StateChangeType)(CYXDownLoadState state);

@interface CYXDownLoader : NSObject


/**
 请求下载

 @param url 资源路径
 @param downLoadInfo 资源大小
 @param progressBlock 进度回调
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)downLoader:(NSURL *)url
      downLoadInfo:(DownLoadInfoType)downLoadInfo
          progress:(ProgressBlockType)progressBlock
           success:(SuccessBlockType)successBlock
            failed:(FailedBlockType)failedBlock;

- (void)downLoaderWithURL:(NSURL *)url; ///< 下载

- (void)resumeCurrentTask;
- (void)pauseCurrentTask;
- (void)cancelCurrentTask;
- (void)cancelAndClean;

@property (nonatomic, assign, readonly) CYXDownLoadState state;
@property (nonatomic, assign, readonly) float progress;

@property (nonatomic, copy) DownLoadInfoType downLoadInfo;
@property (nonatomic, copy) ProgressBlockType progressChange;
@property (nonatomic, copy) SuccessBlockType successBlock;
@property (nonatomic, copy) FailedBlockType failedBlock;
@property (nonatomic, copy) StateChangeType stateChange;


@end
