//
//  CYXDownLoader.m
//  CYXDownLoader
//
//  Created by 陈燕翔 on 2017/9/16.
//  Copyright © 2017年 陈燕翔. All rights reserved.
//

#import "CYXDownLoader.h"
#import "CYXFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath NSTemporaryDirectory()

@interface CYXDownLoader () <NSURLSessionDataDelegate>
{
    long long _tmpSize;
    long long _totalSize;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *downLoadedPath;
@property (nonatomic, copy) NSString *downLoadingPath;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, weak) NSURLSessionDataTask *dataTask; ///< 当前下载任务

@end

@implementation CYXDownLoader

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)downLoader:(NSURL *)url
      downLoadInfo:(DownLoadInfoType)downLoadInfo
          progress:(ProgressBlockType)progressBlock
           success:(SuccessBlockType)successBlock
            failed:(FailedBlockType)failedBlock {
    
    self.downLoadInfo = downLoadInfo;
    self.progressChange = progressBlock;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    
    [self downLoaderWithURL:url];
}

- (void)downLoaderWithURL:(NSURL *)url {
    
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        if (self.state == CYXDownLoadStatePause) {
            [self resumeCurrentTask];
            return;
        }
    }
    [self cancelCurrentTask];
    
    NSString *fileName = url.lastPathComponent;
    
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLoadingPath = [kTmpPath stringByAppendingPathComponent:fileName];
    
    if ([CYXFileTool fileExists:self.downLoadedPath]) {
        // 资源已下载
        self.state = CYXDownLoadStateSuccess;
        return;
    }
    
    if (![CYXFileTool fileExists:self.downLoadingPath]) {
        // 资源未下载
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    _tmpSize = [CYXFileTool fileSize:self.downLoadingPath];
    [self downLoadWithURL:url offset:_tmpSize];
}


#pragma mark - public method

- (void)resumeCurrentTask {
    if (self.dataTask && self.state == CYXDownLoadStatePause) {
        [self.dataTask resume];
        self.state = CYXDownLoadStateDownLaoding;
    }
}

- (void)pauseCurrentTask {
    if (self.state == CYXDownLoadStateDownLaoding) {
        self.state = CYXDownLoadStatePause;
        [self.dataTask suspend];
    }
}

- (void)cancelCurrentTask {
    self.state = CYXDownLoadStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancelAndClean {
    [self cancelCurrentTask];
    [CYXFileTool removeFile:self.downLoadingPath];
}


#pragma mark - NSURLSessionDataDelegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    // 取资源总大小
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    if (self.downLoadInfo) {
        self.downLoadInfo(_totalSize);
    }
    
    if (_tmpSize == _totalSize) {
        [CYXFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        completionHandler(NSURLSessionResponseCancel);
        self.state = CYXDownLoadStateSuccess;
        return;
    }
    
    if (_tmpSize > _totalSize) {
        [CYXFileTool removeFile:self.downLoadingPath];
        completionHandler(NSURLSessionResponseCancel);
        [self downLoaderWithURL:response.URL];
        return;
    }
    self.state = CYXDownLoadStateDownLaoding;
    // 继续接受数据
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
    
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    _tmpSize += data.length;
    self.progress = 1.0 * _tmpSize / _totalSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error == nil) {
        [CYXFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        self.state = CYXDownLoadStateSuccess;
    }else {
        if (error.code == -999) {
            self.state = CYXDownLoadStatePause;
        } else {
            self.state = CYXDownLoadStateFailed;
        }
    }
    [self.outputStream close];
}

#pragma mark - private method

/**
 根据开始字节, 请求资源
 
 @param url url
 @param offset 开始字节
 */
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    // session 分配的task, 默认情况, 挂起状态
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}

#pragma mark - setter

- (void)setState:(CYXDownLoadState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.stateChange) {
        self.stateChange(_state);
    }
    if (_state == CYXDownLoadStateSuccess && self.successBlock) {
        self.successBlock(self.downLoadedPath);
    }
    if (_state == CYXDownLoadStateFailed && self.failedBlock) {
        self.failedBlock();
    }
}

- (void)setProgress:(float)progress {
    _progress = progress;
    if (self.progressChange) {
        self.progressChange(_progress);
    }
}
@end
