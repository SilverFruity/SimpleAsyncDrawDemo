//
//  UIView+AjustFrame.m
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import "UIView+AjustFrame.h"

@implementation UIView (AjustFrame)
- (CGSize)size{
    return self.frame.size;
}

- (void)setSize:(CGSize)size{
    self.width = size.width;
    self.height = size.height;
}

- (CGFloat)height{
    return CGRectGetHeight(self.frame);
}

- (void)setHeight:(CGFloat)height{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

- (CGFloat)centerX{
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX{
    self.center = CGPointMake(centerX, self.centerY);
    
}

- (CGFloat)centerY{
   return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY{
    self.center = CGPointMake(self.centerX, centerY);
}



- (CGPoint)contentCenter{
    return CGPointMake(self.width * 0.5, self.height * 0.5);
}

- (CGFloat)minX{
    return CGRectGetMinX(self.frame);
}
- (CGFloat)midX{
    return CGRectGetMidX(self.frame);
}
- (CGFloat)maxX{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)minY{
    return CGRectGetMinY(self.frame);
}
- (CGFloat)midY{
    return CGRectGetMidY(self.frame);
}
- (CGFloat)maxY{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)left{
    return self.x;
}

- (CGFloat)right{
    return self.maxX;
}

- (CGFloat)top{
    return self.y;
}

- (CGFloat)bottom{
    return self.maxY;
}

@end
