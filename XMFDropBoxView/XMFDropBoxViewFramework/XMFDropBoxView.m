//
//  XMFDropBoxView.m
//  XBJob
//
//  Created by kk on 15/11/13.
//  Copyright © 2015年 cnmobi. All rights reserved.
//

#import "XMFDropBoxView.h"

@interface XMFDropBoxView ()

@property (nonatomic, copy) void (^actionBlock) (NSUInteger index);

@property (nonatomic, strong) NSMutableArray<UIView *> *datas;

@property (nonatomic, weak) CAShapeLayer *backgroundLayer;

@end

@implementation XMFDropBoxView

+ (instancetype)dropBoxWithLocationView:(UIView *)locationView dataSource:(id<XMFDropBoxViewDataSource>)dataSource{
    [XMFDropBoxView removeAllDropBox];
    XMFDropBoxView *dropBox = [[XMFDropBoxView alloc] init];
    dropBox.dataSource = dataSource;
    dropBox.locationView = locationView;
    [dropBox startAnimation];
    return dropBox;
}

/**
 *  动画
 */
- (void)startAnimation {
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicAnimation.fromValue = @0.f;
    basicAnimation.toValue = @1.f;
    basicAnimation.duration = 0.5f;
    basicAnimation.autoreverses = NO;
    basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [self.layer addAnimation:basicAnimation forKey:nil];
}

- (void)setLocationView:(UIView *)locationView {
    _locationView = locationView;
    [self setLayoutForView];
}

- (void)setDataSource:(id<XMFDropBoxViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self setLayoutForView];
}

- (void)setLayoutForView {
    if (!self.locationView) return;
    
    NSAssert(self.dataSource, @"dataSource is null");
    
    [self addBackgroundLayer];
    [self addItems];
    
    //  相对于屏幕的坐标
    CGRect bounds = [self.locationView convertRect:self.locationView.bounds toView:nil];
    const CGFloat VIEW_H =  CGRectGetMaxY(self.datas[self.datas.count - 1].frame); //  view的高
    CGFloat VIEW_W = 0.f;
    if ([self.dataSource respondsToSelector:@selector(widthInDropBoxView:)]) {
        VIEW_W = [self.dataSource widthInDropBoxView:self];
    }
    const CGFloat VIEW_X = CGRectGetMidX(bounds) - VIEW_W / 2;
    const CGFloat VIEW_Y = CGRectGetMaxY(bounds);
    
    //  三角形的坐标
    CGFloat triangleHeight = 10;
    CGFloat triangleWidth = triangleHeight;
    CGFloat triangleX = (VIEW_W - triangleWidth) / 2;
    CGFloat triangleY = -triangleHeight;
    BOOL positive = true;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat x = VIEW_X;
    if (VIEW_X + VIEW_W > screenBounds.size.width) {    //  是否越过屏幕右边线
        x = screenBounds.size.width - VIEW_W;
        triangleX = VIEW_W - CGRectGetWidth(bounds) / 2;
    }
    else if (VIEW_X < 0) { //  是否越过屏幕左边线
        x = 0;
        triangleX = CGRectGetWidth(bounds) / 2;
    }
    
    CGFloat y = VIEW_Y + triangleHeight;
    if (VIEW_Y + VIEW_H > screenBounds.size.height) {   //  是否越过屏幕下边线
        y = CGRectGetMinY(bounds) - VIEW_H - triangleHeight;
        triangleY = VIEW_H;
        positive = false;
    }
    else if (VIEW_Y < 0) {  //  是否越过屏幕上边线
        y = VIEW_Y + CGRectGetHeight(bounds);
        triangleY = - triangleHeight;
        positive = true;
    }
    
    self.frame = CGRectMake(x, y, VIEW_W, VIEW_H);
    
    
    [self addTriangleLayerWithFrame: CGRectMake(triangleX, triangleY, triangleWidth, triangleHeight) positive:positive];
    [self addPathToLayer];
}



- (void)addItems {
    
    NSUInteger count = 0;
    if ([self.dataSource respondsToSelector: @selector(numberOfItemInDropBoxView:)]) {
        count = [self.dataSource numberOfItemInDropBoxView:self];
    }
    
    UIView *view;
    CGFloat height = 0.f;
    CGFloat y = 0.f;
    CGFloat width = 0.f;
    if ([self.dataSource respondsToSelector:@selector(widthInDropBoxView:)]) {
        width = [self.dataSource widthInDropBoxView:self];
    }
    _datas = [NSMutableArray<UIView *> arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        
        if ([self.dataSource respondsToSelector:@selector(dropBoxView:itemAtIndex:)]) {
             view = [self.dataSource dropBoxView:self itemAtIndex:i];
            
            if ([self.dataSource respondsToSelector: @selector(dropBoxView:heightForItemAtIndex:)]) {
                height = [self.dataSource dropBoxView:self heightForItemAtIndex:i];
            }
            
            if (i != 0) {
                y = CGRectGetMaxY(self.datas[i - 1].frame);
            }
            
            CGRect frame = CGRectMake(0, y, width, height);
            view.frame = frame;
            view.tag = i;
            view.userInteractionEnabled = YES;
            [self.datas insertObject:view atIndex:i];
            [self addSubview: view];
        }
    }
}

- (void)addTriangleLayerWithFrame: (CGRect) frame positive : (BOOL) positive {
    //  画三角形
    
    CGFloat topY;
    CGFloat bottomY;
    
    if (positive) {
        topY = frame.origin.y;
        bottomY = topY + CGRectGetHeight(frame);
    }
    else {
        bottomY = frame.origin.y;
        topY = bottomY + CGRectGetHeight(frame);
    }
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(frame), bottomY);
    CGPoint widthPoint = CGPointMake(CGRectGetMaxX(frame), bottomY);
    CGPoint endPoint = CGPointMake(CGRectGetMidX(frame), topY);
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:startPoint];
    [path2 addLineToPoint:widthPoint];
    [path2 addLineToPoint: endPoint];
    [path2 closePath];
    
    CAShapeLayer *triangleLayer = [CAShapeLayer layer];
    triangleLayer.path = path2.CGPath;
    triangleLayer.fillColor = [UIColor whiteColor].CGColor;
    
    [self.layer addSublayer: triangleLayer];
}

- (void)addBackgroundLayer{
    
    //  圆角
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 5;
    layer.shadowOpacity = 0.5;
    
    self.backgroundLayer = layer;
    [self.layer addSublayer: self.backgroundLayer];
}

- (void)addPathToLayer {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    cornerRadius:5];
    self.backgroundLayer.path = path.CGPath;
}

- (void)displayDropBox {
    //  如果存在下拉框就删去，否则显示
    [[UIApplication sharedApplication].keyWindow addSubview: self];
}

+ (void)removeAllDropBox {
    for (UIView *view in [[UIApplication sharedApplication].keyWindow subviews]) {
        if ([view isKindOfClass: [XMFDropBoxView class]]) {
            [(XMFDropBoxView *)view dismissDropBox];
        }
    }
}

- (void)dismissDropBox {
    [self removeFromSuperview];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = touch.view;
    NSUInteger idx = view.tag;
    if (self.actionBlock) {
        self.actionBlock(idx);
    }
    [self dismissDropBox];
}


- (void)selectItemWithBlock:(void (^)(NSUInteger))block {
    _actionBlock = block;
}

@end
