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
    
    if (self.index >= self.questions.count) {
        
        self.index = 9;
        
        // 播放一个动画效果，或者其他的操作……
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"通关了" message:@"恭喜你" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:@"继续",@"lalal", nil];
        
        [alertView show];
        return;
    };
    
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
    
    [self.optionView setUserInteractionEnabled:YES];
}

/** 答案按钮的点击事件 */
- (void)answerClick:(UIButton *)btn{
    
    // 1.是否有文字，如果没有，直接返回
    if (btn.currentTitle.length == 0) {
        return;
    }
    
    // 2. 如果有文字
    // 1> 将对应的备选按钮恢复显示
    for (UIButton *button in self.optionView.subviews) {
        if ([button.currentTitle isEqualToString:btn.currentTitle] && button.isHidden) {
            button.hidden = NO;
            
            // 2>清空答案按钮中的文字
            [btn setTitle:nil forState:UIControlStateNormal];
            
            break;
        }
    }
    
    // 3.点击答案按钮后，意味这答案不完整了，将所有按钮的颜色设置为黑色
    for (UIButton *btn in self.answerView.subviews) {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    // 4.恢复备选按钮的可点击
    [self.optionView setUserInteractionEnabled:YES];
}

/** 备选按钮点击事件 */
- (void)optionClick:(UIButton *)btn{
    // 1> 把备选按钮中的文字，填充到答案区
    // 找答案区中第一个按钮文字为空的按钮
    for (UIButton *button in self.answerView.subviews) {
        if (button.currentTitle.length == 0) {
            [button setTitle:btn.currentTitle forState:UIControlStateNormal];
            
            break;
        }
    }
    
    // 2>把按钮隐藏
    btn.hidden = YES;
    
    // 3> 判断胜负
    // 3.1 所有的答案按钮都填满，遍历所有答案区的按钮
    BOOL isFull = YES;
    NSMutableString *strM = [NSMutableString string];
    
    for (UIButton *btn in self.answerView.subviews) {
        if (!btn.currentTitle.length) {
            // 没有填满
            isFull = NO;
            
            break;
        } else {
            [strM appendString:btn.currentTitle];
        }
    }
    
    if (isFull) {
        // 用户选择的答案和当前题目的答案对比
        JHQuestion *question = self.questions[self.index];
        
        if ([question.answer isEqualToString:strM]) {
            // 修改答案区按钮的颜色 -> 蓝色
            for (UIButton *btn in self.answerView.subviews) {
                [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
            
            // 加分操作
            [self changeScore : 500];
            
            // 等待0.5s之后，跳到下一题
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.5f];
        }else{
            NSLog(@"错错错！");
            // 修改答案区按钮的颜色 -> 红色
            for (UIButton *btn in self.answerView.subviews) {
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
        
        // 填满后备选按钮不允许点击
//        for (UIButton *button in self.optionView.subviews) {
//            [button setEnabled:NO];
//        }
        
        [self.optionView setUserInteractionEnabled:NO];
    }
}

/** 修改分数 */
- (void)changeScore:(int)score{
    int currentScore = [self.scoreBtn.currentTitle intValue];
    currentScore += score;
    [self.scoreBtn setTitle:[NSString stringWithFormat:@"%d",currentScore] forState:UIControlStateNormal];
}

/** 提示按钮 */
- (IBAction)tips {
    // 1.将答案去的所有按钮清空
    for (UIButton *btn in self.answerView.subviews) {
        [self answerClick:btn];
    }
    
    // 2. 找到正确答案的第一个字，显示到答案区中的第一个按钮上
    JHQuestion *question = self.questions[self.index];
    
    NSString *firstWord = [question.answer substringToIndex:1];
    // 3. 遍历所有的备选按钮，找到第一个匹配的文字，模拟点击
    for (UIButton *btn in self.optionView.subviews) {
        if ([btn.currentTitle isEqualToString:firstWord]) {
            [self optionClick:btn];
            
            // 减分操作
            [self changeScore:-1000];
            
            break;
        }
    }
}



@end
