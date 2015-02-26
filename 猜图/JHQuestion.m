//
//  JHQuestion.m
//  猜图
//
//  Created by piglikeyoung on 15/2/25.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//



#import "JHQuestion.h"

@interface JHQuestion(){
    UIImage *_image;
}
@end


@implementation JHQuestion

- (UIImage *) image{
    if (!_image) {
        _image = [UIImage imageNamed:self.icon];
    }
    
    return _image;
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        // 使用setValuesForKeys要求字典中存在的属性在类中必须存在，类可以有别的属性存在
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)questionWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)questions{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil]];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        [arrayM addObject: [JHQuestion questionWithDict:dict]];
    }
    
    return arrayM;
}

// 如果要在开发时，跟踪对象的明细信息，可以重写description方法，类似于java的toString()
- (NSString *) description{
    // 包含对象类型名称，以及对象的指针地址
    return [NSString stringWithFormat:@"<%@: %p> {answer: %@, title: %@, icon: %@, options: %@}", [self class], self, self.answer, self.title, self.icon, self.options];
}

@end