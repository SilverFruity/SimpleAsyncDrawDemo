//
//  UIView+AjustFrame.h
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import <UIKit/UIKit.h>


@interface UIView (AjustFrame)

- (CGSize)size;
- (void)setSize:(CGSize)size;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

//相对于父视图的center
- (CGFloat)centerX;
- (void)setCenterX:(CGFloat)centerX;

- (CGFloat)centerY;
- (void)setCenterY:(CGFloat)centerY;

//相对于子视图的center
@property(nonatomic,readonly,assign)CGPoint contentCenter;

@property(nonatomic,readonly,assign)CGFloat minX;
@property(nonatomic,readonly,assign)CGFloat midX;
@property(nonatomic,readonly,assign)CGFloat maxX;

@property(nonatomic,readonly,assign)CGFloat minY;
@property(nonatomic,readonly,assign)CGFloat midY;
@property(nonatomic,readonly,assign)CGFloat maxY;

@property(nonatomic,readonly,assign)CGFloat left;
@property(nonatomic,readonly,assign)CGFloat right;
@property(nonatomic,readonly,assign)CGFloat bottom;
@property(nonatomic,readonly,assign)CGFloat top;

@end
