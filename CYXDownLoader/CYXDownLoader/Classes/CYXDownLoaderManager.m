//
//  CYXDownLoaderManager.m
//  CYXDownLoader
//
//  Created by 陈燕翔 on 2017/9/19.
//  Copyright © 2017年 陈燕翔. All rights reserved.
//

#import "CYXDownLoaderManager.h"
#import "NSString+MD5.h"

@interface CYXDownLoaderManager()<NSCopying, NSMutableCopying>

@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;

@end

@implementation CYXDownLoaderManager

- (NSMutableDictionary *)downLoadInfo
{
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

static CYXDownLoaderManager *_shareInstance;
+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (void)downLoader:(NSURL *)url
      downLoadInfo:(DownLoadInfoType)downLoadInfo
          progress:(ProgressBlockType)progressBlock
           success:(SuccessBlockType)successBlock
            failed:(FailedBlockType)failedBlock {
    NSString *urlMD5 = [url.absoluteString md5];
    
    CYXDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (!downLoader) {
        downLoader = [CYXDownLoader new];
        self.downLoadInfo[urlMD5] = downLoader;
    }
    __weak typeof(self) weakSelf = self;
    [downLoader downLoaderWithURL:url downLoadInfo:downLoadInfo progress:progressBlock success:^(NSString *filePath) {
        // 移除下载器
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        successBlock(filePath);
    } failed:failedBlock];
}

- (void)pauseWithURL:(NSURL *)url {
    CYXDownLoader *downLoader = self.downLoadInfo[[url.absoluteString md5]];
    [downLoader pauseCurrentTask];
}

- (void)resumeWithURL:(NSURL *)url {
    CYXDownLoader *downLoader = self.downLoadInfo[[url.absoluteString md5]];
    [downLoader resumeCurrentTask];
}

- (void)cancelWithURL:(NSURL *)url {
    CYXDownLoader *downLoader = self.downLoadInfo[[url.absoluteString md5]];
    [downLoader cancelCurrentTask];
}

- (void)pauseAll {
    for (CYXDownLoader *downLoad in self.downLoadInfo.allValues) {
        [downLoad pauseCurrentTask];
    }
}

- (void)resumeAll {
    for (CYXDownLoader *downLoad in self.downLoadInfo.allValues) {
        [downLoad resumeCurrentTask];
    }
}

@end
