//
//  UIButton+buttonWithBlock.h
//  SharedGym
//
//  Created by Jiang on 2017/4/19.
//
//

#import <UIKit/UIKit.h>

typedef void (^JkmButtonBlock)(UIButton *button);

@interface UIButton (buttonWithBlock)
///注意循环引用
+ (instancetype)buttonWithBlock:(JkmButtonBlock)block;

///注意循环引用
+ (instancetype)buttonWithBlock:(JkmButtonBlock)block forControlEvents:(UIControlEvents)event;

///注意循环引用
- (void)observeEvent:(UIControlEvents)event block:(JkmButtonBlock)block;
@end
