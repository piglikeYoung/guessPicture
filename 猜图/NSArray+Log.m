//
//  NSArray+Log.m
//  猜图
//
//  Created by piglikeyoung on 15/2/25.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import "NSArray+Log.h"

@implementation NSArray (Log)


-(NSString *)descriptionWithLocale:(id)locale{
    
    // 遍历数组中的所有内容，将内容拼接成一个新的字符串返回
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendString:@"(\n"];
    
    // 遍历数组,self就是当前的数组
    for (id obj in self) {
        // 在拼接字符串时，会调用obj的description方法
        [strM appendFormat:@"\t%@,\n",obj];
    }
    
    [strM appendString:@")"];
    
    return strM;
}


@end
