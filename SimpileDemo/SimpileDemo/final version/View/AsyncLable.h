//
//
//  Created by Jiang on 2017/5/7.
//
//

#import <UIKit/UIKit.h>

@interface AsyncLable : UIView
@property(nonatomic,copy)NSString *text;

@property(nonatomic,copy)void(^hasSetSize)(AsyncLable *label);

- (instancetype)initWithFrame:(CGRect)frame operationQueue:(NSOperationQueue *)queue;
+ (CGSize)caculatorSizeWithString:(NSString *)string viewWidth:(CGFloat)width;

@end
