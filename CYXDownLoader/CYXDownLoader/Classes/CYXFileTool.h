//
//  CYXFileTool.h
//  CYXDownLoader
//
//  Created by 陈燕翔 on 2017/9/17.
//  Copyright © 2017年 陈燕翔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYXFileTool : NSObject

+ (BOOL)fileExists:(NSString *)filePath; ///< 交验文件是否存在
+ (long long)fileSize:(NSString *)filePath; ///< 获取文件大小
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath; ///< 移动文件到另外一个路径
+ (void)removeFile:(NSString *)filePath; ///< 移除文件

@end
