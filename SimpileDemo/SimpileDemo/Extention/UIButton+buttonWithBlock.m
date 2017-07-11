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
    [self addTarget:self action:@selector(JkmBlockButttonTouched:) forControlEvents:event];
}

#pragma mark 点击
- (void)JkmBlockButttonTouched:(UIButton *)sender{
    //使用所有的Option进行匹配
    [self doEvent:UIControlEventTouchDown];
    [self doEvent:UIControlEventTouchDownRepeat];
    [self doEvent:UIControlEventTouchDragInside];
    [self doEvent:UIControlEventTouchDragOutside];
    [self doEvent:UIControlEventTouchDragEnter];
    [self doEvent:UIControlEventTouchDragExit];
    [self doEvent:UIControlEventTouchUpInside];
    [self doEvent:UIControlEventTouchUpOutside];
    [self doEvent:UIControlEventTouchCancel];
}

- (void)doEvent:(UIControlEvents )event{
    if (self.allControlEvents & event) {
        JkmButtonBlock block = [self getEventBlockWithEvent:event];
        if (block) block(self);
    }
}

#pragma mark - GET & SET

// dict : [@(event) : block]

- (JkmButtonBlock)getEventBlockWithEvent:(UIControlEvents)event{
    NSMutableDictionary *blocksDict =  objc_getAssociatedObject(self, &BlocksDictKey);
    if (blocksDict == nil) {
        [self willChangeValueForKey:BlocksDictKey];
        objc_setAssociatedObject(self, &BlocksDictKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:BlocksDictKey];
        return nil;
    }
    return blocksDict[@(event)];
}

- (void)setEventBlock:(JkmButtonBlock)eventBlock withEvent:(UIControlEvents)event{
    if (!eventBlock) {
        return;
    }
    NSMutableDictionary *blocksDict =  objc_getAssociatedObject(self, &BlocksDictKey);
    if (blocksDict == nil) {
        blocksDict = [NSMutableDictionary dictionary];
        [blocksDict setObject:eventBlock forKey:@(event)];
        [self willChangeValueForKey:BlocksDictKey];
        objc_setAssociatedObject(self, &BlocksDictKey, blocksDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:BlocksDictKey];
        return;
    }
    [blocksDict setObject:eventBlock forKey:@(event)];
}
@end
