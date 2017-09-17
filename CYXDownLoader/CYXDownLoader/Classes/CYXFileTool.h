//
//  CYXFileTool.h
//  CYXDownLoader
//
//  Created by 陈燕翔 on 2017/9/17.
//  Copyright © 2017年 陈燕翔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYXFileTool : NSObject

+ (BOOL)fileExists:(NSString *)filePath;
+ (long long)fileSize:(NSString *)filePath;
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void)removeFile:(NSString *)filePath;

@end
