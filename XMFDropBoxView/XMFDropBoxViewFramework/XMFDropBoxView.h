//
//  XMFDropBoxView.h
//  XBJob
//
//  Created by kk on 15/11/13.
//  Copyright © 2015年 cnmobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMFDropBoxView;

@protocol XMFDropBoxViewDataSource <NSObject>

@required
//  分配每行的item
- (UIView *)dropBoxView : (XMFDropBoxView *)dropBoxView itemAtIndex : (NSUInteger)index;

//  每行item的高度
- (CGFloat)dropBoxView:(XMFDropBoxView *)dropBoxView heightForItemAtIndex:(NSUInteger)index;

//  一共item数量
- (NSUInteger)numberOfItemInDropBoxView : (XMFDropBoxView *)dropBoxView;

//  view的宽度
- (CGFloat)widthInDropBoxView:(XMFDropBoxView *)dropBoxView;

@end

@interface XMFDropBoxView : UIView

//  定位的view
@property (nonatomic, weak) UIView *locationView;

- (void)selectItemWithBlock : (void (^) (NSUInteger index)) block;

//  data数据 view通过view的坐标确定控件的位置
+ (instancetype)dropBoxWithLocationView : (UIView *) locationView dataSource: (id<XMFDropBoxViewDataSource>) dataSource;

@property (nonatomic, assign) id<XMFDropBoxViewDataSource> dataSource;

//  删去下拉框
- (void)dismissDropBox;

//  显示下拉框
- (void)displayDropBox;

//  删去存在的下拉框
+ (void)removeAllDropBox;


@end
