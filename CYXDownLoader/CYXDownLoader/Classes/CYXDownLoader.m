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
    
    NSString *fileName = url.lastPathComponent;
    
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLoadingPath = [kTmpPath stringByAppendingPathComponent:fileName];
    
    // 判断url地址对应的资源是否下载完毕(下载完成的目录里面,存在这个文件)
    if ([CYXFileTool fileExists:self.downLoadedPath]) {
        // 已经下载完成;
        NSLog(@"已经下载完成");
        return;
    }
    
    // 检测临时文件是否存在
    if (![CYXFileTool fileExists:self.downLoadingPath]) {
        // 从0字节开始请求资源
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    // 获取本地大小
    _tmpSize = [CYXFileTool fileSize:self.downLoadingPath];
    [self downLoadWithURL:url offset:_tmpSize];
    
}
#pragma mark - NSURLSessionDataDelegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    // 取资源总大小
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    if (_tmpSize == _totalSize) {
        NSLog(@"移动文件到下载完成");
        [CYXFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    if (_tmpSize > _totalSize) {
        NSLog(@"删除临时缓存");
        [CYXFileTool removeFile:self.downLoadingPath];
        NSLog(@"重新开始下载");
        completionHandler(NSURLSessionResponseCancel);
        [self downLoaderWithURL:response.URL];
        return;
    }
    
    // 继续接受数据
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
    
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    [self.outputStream write:data.bytes maxLength:data.length];
    
    NSLog(@"在接受后续数据");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSLog(@"请求完成");
    
    if (error == nil) {
        
    }else {
        NSLog(@"有问题");
    }
    
    [self.outputStream close];
    
}

#pragma mark - public method

- (void)resumeCurrentTask {
    
    
}

- (void)pauseCurrentTask {
    
}

- (void)cancelCurrentTask {
    
}

- (void)cancelAndClean {
    
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
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    
    [dataTask resume];
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
