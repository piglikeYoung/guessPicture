//
//  JHQuestion.h
//  猜图
//
//  Created by piglikeyoung on 15/2/25.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JHQuestion : NSObject

/** 答案 */
@property (nonatomic, copy) NSString *answer;
/** 提示文字 */
@property (nonatomic, copy) NSString *title;
/** 图片名称 */
@property (nonatomic, copy) NSString *icon;
/** 备选文字数组 */
@property (nonatomic, strong) NSArray *options;
/** 图像 */
@property (nonatomic, strong, readonly) UIImage *image;

/** 用字典实例化对象的成员方法 */
- (instancetype) initWithDict:(NSDictionary *)dict;

/** 用字典实例化对象的类方法，又称工厂方法 */
+ (instancetype) questionWithDict:(NSDictionary *)dict;

/** 从plist加载对象数组 */
+ (NSArray *)questions;

@end
