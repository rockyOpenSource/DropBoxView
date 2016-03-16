//
//  ViewController.m
//  XMFDropBoxView
//
//  Created by xumingfa on 16/3/7.
//  Copyright © 2016年 xumingfa. All rights reserved.
//

#import "ViewController.h"

#import "XMFDropBoxView.h"

@interface ViewController () <XMFDropBoxViewDataSource>

@property (nonatomic, weak) UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
    [panGesture addTarget:self action:@selector(panAction:)];

    UIButton *btn = [UIButton new];
    btn.backgroundColor = [UIColor blueColor];
    btn.frame = CGRectMake(300, 300, 100, 100);
    [btn setTitle:@"跳转" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn addGestureRecognizer: panGesture];
    self.btn = btn;
    [self.view addSubview: self.btn];
    
    
}

- (void)panAction : (UIPanGestureRecognizer *) panGesture {
    CGPoint point = [panGesture translationInView: self.view];
    
    CGPoint newPoint = CGPointMake(self.btn.center.x + point.x, self.btn.center.y + point.y);
    [self.btn setCenter: newPoint];
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)actionBtn : (UIButton *) btn {
    
    XMFDropBoxView *inputBox = [XMFDropBoxView dropBoxWithLocationView:btn dataSource:self];
    [inputBox selectItemWithBlock:^(NSUInteger index) {
        NSLog(@"%ld", index);
    }];
    [inputBox displayDropBox];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [XMFDropBoxView removeAllDropBox];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfItemInDropBoxView:(XMFDropBoxView *)dropBoxView {
    return 3;
}

- (CGFloat)dropBoxView:(XMFDropBoxView *)dropBoxView heightForItemAtIndex:(NSUInteger)index {
    return 44.f;
}

- (UIView *)dropBoxView:(XMFDropBoxView *)dropBoxView itemAtIndex:(NSUInteger)index {
    UILabel *titleLB = [UILabel new];
    titleLB.textAlignment = NSTextAlignmentCenter;
    titleLB.font = [UIFont systemFontOfSize:20];
    titleLB.text = @"测试";
    return titleLB;
}

- (CGFloat)widthInDropBoxView:(XMFDropBoxView *)dropBoxView {
    return 200.f;
}

@end
