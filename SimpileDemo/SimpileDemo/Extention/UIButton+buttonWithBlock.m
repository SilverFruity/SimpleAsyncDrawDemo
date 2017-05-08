//
//  UIButton+buttonWithBlock.m
//  SharedGym
//
//  Created by Jiang on 2017/4/19.
//
//

#import "UIButton+buttonWithBlock.h"
#import <objc/runtime.h>

static NSString *const TouchEventKey = @"TouchEventKey";
static NSString *const BlocksDictKey = @"BlocksDictKey";

@implementation UIButton (buttonWithBlock)

+ (instancetype )buttonWithBlock:(JkmButtonBlock)block{
    return [[self class] buttonWithBlock:block forControlEvents:UIControlEventTouchUpInside];
}

+ (instancetype)buttonWithBlock:(JkmButtonBlock)block forControlEvents:(UIControlEvents)event{
    UIButton *button = [[[self class]alloc]init];
    [button observeEvent:event block:block];
    return button;
}

- (void)observeEvent:(UIControlEvents)event block:(JkmButtonBlock)block{
    [self setEventBlock:block withEvent:event]; //将事件作为key,block作为value,存储到可变字典中
    [self setTouchEvent:event];  //将触发的事件绑定到button上,使得可以在方法触发里通过 事件 取出 相应的block
    [self addTarget:self action:@selector(JkmBlockButttonTouched:) forControlEvents:event];
}

- (void)JkmBlockButttonTouched:(UIButton *)sender{
    JkmButtonBlock block = [self getEventBlockWithEvent:[sender touchEvent]];
    if (block) {
        block(sender);
    }
}

#pragma mark - GET & SET
- (UIControlEvents)touchEvent{
    NSNumber *number =  objc_getAssociatedObject(self, &TouchEventKey);
    if (number) {
        return number.intValue;
    }
    return 0;
}

- (void)setTouchEvent:(UIControlEvents)touchEvent{
    objc_setAssociatedObject(self, &TouchEventKey, @(touchEvent), OBJC_ASSOCIATION_ASSIGN);
}

// dict : [@(event) : block]
- (JkmButtonBlock)getEventBlockWithEvent:(UIControlEvents)event{
    NSMutableDictionary *blocksDict =  objc_getAssociatedObject(self, &BlocksDictKey);
    if (blocksDict == nil) {
        objc_setAssociatedObject(self, &BlocksDictKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return nil;
    }
    return blocksDict[@(event)];
}

- (void)setEventBlock:(JkmButtonBlock)eventBlock withEvent:(UIControlEvents)event{
    NSMutableDictionary *blocksDict =  objc_getAssociatedObject(self, &BlocksDictKey);
    if (blocksDict == nil) {
        blocksDict = [NSMutableDictionary dictionary];
        [blocksDict setObject:eventBlock forKey:@(event)];
        objc_setAssociatedObject(self, &BlocksDictKey, blocksDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    [blocksDict setObject:eventBlock forKey:@(event)];
}
@end
