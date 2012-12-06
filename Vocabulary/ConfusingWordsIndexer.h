//
//  ConfusingWordsIndexer.h
//  Vocabulary
//
//  Created by 缪 和光 on 12-11-22.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfusingWordsIndexer : NSObject

/**
 对新插入的words进行索引。调用此方法前，先插入到数据库中（执行context save）
 @param newWordsIDArray 传managedObjectID数组
 */
+ (void)indexNewWordsAsyncById:(NSArray *)newWordsIDArray completion:(HKVErrorBlock)completion;

+ (void)indexNewWordsAsyncById:(NSArray *)newWordsIDArray progressBlock:(HKVProgressCallback)progressBlock completion:(HKVErrorBlock)completion;

+ (void)indexNewWordsSyncById:(NSArray *)newWordsIDArray managedObjectContext:(NSManagedObjectContext *)ctx error:(NSError **)error;

+ (void)reIndexForAllWithProgressCallback:(HKVProgressCallback)callback completion:(HKVVoidBlock)completion;

@end