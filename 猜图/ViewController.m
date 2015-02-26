//
//  ViewController.m
//  猜图
//
//  Created by piglikeyoung on 15/2/25.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import "ViewController.h"
#import "JHQuestion.h"

#define kButtonW 35.0
#define kButtonH 35.0
#define kButtonMargin 10.0
#define kTotalCol   7

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *noLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *scoreBtn;


/** 图片 */
@property (weak, nonatomic) IBOutlet UIButton *iconView;
/** 遮罩按钮 */
@property (strong, nonatomic) UIButton *cover;


@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionView;


/** 题目列表 */
@property (strong, nonatomic) NSArray *questions;

/** 题目索引 */
@property (nonatomic, assign) int index;

@end

@implementation ViewController

- (NSArray *)questions{
    if (!_questions) {
        _questions = [JHQuestion questions];
    }
    
    return _questions;
}

- (UIButton *) cover{
    if (!_cover) {
        _cover = [[UIButton alloc] initWithFrame:self.view.bounds];
        _cover.backgroundColor = [UIColor blackColor];
        _cover.alpha = 0.0f;
        
        [self.view addSubview:_cover];
        
        [_cover addTarget:self action:@selector(bigImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cover;
}

-(void)viewDidLoad{
    
    // 如果是"加载"对象的父类方法，父类方法的调用，要放在第一句
    [super viewDidLoad];
    
    self.index = -1;
    [self nextQuestion];
}


/** 修改状态栏 */
- (UIStatusBarStyle) preferredStatusBarStyle{
    
    // 修改状态栏颜色（白色）
    return UIStatusBarStyleLightContent;
}

/** 大图 */
- (IBAction)bigImage{
    
    /** 当按钮的alpha < 0.001 的时候，按钮不响应点击事件 */
    // 1. 增加蒙版(跟根视图一样大小)
    if (self.cover.alpha == 0.0) {
        // 2. 将图片移动到视图的顶层
        [self.view bringSubviewToFront:self.iconView];
        
        // 3. 动画放大图片
        // 1> 计算目标位置
        CGFloat viewW = self.view.bounds.size.width;
        CGFloat imageW = viewW;
        CGFloat imageH = imageW;
        CGFloat imageY = (self.view.bounds.size.height - imageH) * 0.5;
        
        [UIView animateWithDuration:1.0f animations:^{
            self.cover.alpha = 0.5;
            self.iconView.frame = CGRectMake(0, imageY, imageW, imageH);
        }];
        
    } else {
        // 图片已经是放大显示的了
        [UIView animateWithDuration:1.0f animations:^{
            // 1. 动画变小
            self.iconView.frame = CGRectMake(85, 80, 150, 150);
            // 2. 遮罩透明，看不见了
            self.cover.alpha = 0.0f;
        }];
    }
    
    
}

/** 下一题 */
- (IBAction)nextQuestion {
    
    // 1.题目索引递增
    self.index++;
    
    // 2. 取出索引对应的题目模型
    JHQuestion *question = self.questions[self.index];
    
    // 3. 设置基本信息
    [self setupBasicInfo:question];
    
    // 4. 创建答案按钮
    [self createAnswerButtons:question];
    
    // 5. 创建备选答案按钮
    [self createOptionButtons:question];
}

/** 设置基本信息 */
- (void)setupBasicInfo:(JHQuestion *)question{
    self.noLabel.text = [NSString stringWithFormat:@"%d/%d",self.index+1,self.questions.count];
    self.titleLabel.text = question.title;
    [self.iconView setImage:question.image forState:UIControlStateNormal];
    
    self.nextBtn.enabled = (self.index != self.questions.count-1);
}

/** 创建答案按钮 */
- (void) createAnswerButtons:(JHQuestion *)question{
    
    // 0> 将答案区的按钮全部删除
    for (UIButton *btn in self.answerView.subviews) {
        [btn removeFromSuperview];
    }
    
    // 1> 按钮个数和答案的字数有关
    NSInteger length = question.answer.length;
    CGFloat answerViewW = self.answerView.bounds.size.width;
    CGFloat answerX = (answerViewW - length * kButtonW - (length - 1) * kButtonMargin) * 0.5;
    for (int i = 0; i<length; i++) {
        CGFloat x = answerX + i * (kButtonW + kButtonMargin);
        UIButton *answerBtn = [[UIButton alloc]  initWithFrame:CGRectMake(x, 0, kButtonW, kButtonH)];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        [answerBtn setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
        
        [self.answerView addSubview:answerBtn];
        
        // 添加监听方法
        [answerBtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
    };
}

/** 创建备选答案按钮 */
- (void)createOptionButtons:(JHQuestion *)question{
    
    // 判断备选区视图中按钮的个数，如果不等于question.options.count，删除原有按钮，重新新建
    if (self.optionView.subviews.count != question.options.count) {
        for (UIButton *btn in self.optionView.subviews) {
            [btn removeFromSuperview];
        }
        
        CGFloat optionViewW = self.optionView.bounds.size.width;
        CGFloat optionX = (optionViewW - kTotalCol * kButtonW - (kTotalCol - 1) * kButtonMargin) * 0.5;
        
        for (int i = 0; i<question.options.count; i++) {
            int row = i / kTotalCol;
            int col = i % kTotalCol;
            
            CGFloat x = optionX + col * (kButtonW + kButtonMargin);
            CGFloat y = row * (kButtonH + kButtonMargin);
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, kButtonW, kButtonH)];
            
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [self.optionView addSubview:btn];
            
            // 添加监听方法，点击事件
            [btn addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    // 设置按钮标题，遍历optionView，依次设置每一个按钮的标题
    int i = 0;
    for (UIButton *btn in self.optionView.subviews) {
        // 设置按钮标题
        [btn setTitle:question.options[i++] forState:UIControlStateNormal];
        // 恢复所有隐藏的按钮
        btn.hidden = NO;
    }
}

/** 答案按钮的点击事件 */
- (void)answerClick:(UIButton *)btn{

}

/** 备选按钮点击事件 */
- (void)optionClick:(UIButton *)btn{
    
}

@end
