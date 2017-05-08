//
//  UIImage+imageExtention.h
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (imageExtention)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)cornerImageWithCornerRadius:(CGFloat)radius fillColor:(UIColor *)fillColor;

///通过字符串获取二维码
+ (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size;

///绘制中空的矩形
+ (UIImage *)coverArea:(CGRect)coverArea clearArea:(CGRect)clearArea coverColor:(UIColor *)coverColor;

+ (void)GIF:(NSString *)path block:(void(^)(NSArray <UIImage *>*imageArray,
                                            NSArray <NSNumber *>*timeArray,
                                            CGFloat totoalTime))block;
@end
