//
//  UIImage+imageExtention.m
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import "UIImage+imageExtention.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (imageExtention)

+ (UIImage *)imageWithColor:(UIColor *)color{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetAlpha(context, CGColorGetAlpha(color.CGColor));
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)cornerImageWithCornerRadius:(CGFloat)radius fillColor:(UIColor *)fillColor{
    //绘图
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    //填充颜色
    CGContextFillRect(context, rect);
    //利用贝塞尔曲线裁剪矩形
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [path addClip];
    //绘制图像
    [self drawInRect:rect];
    //获取图像
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (void)asynImageWithImage:(UIImage *)image
                      size:(CGSize)size
              cornerRadius:(CGFloat)radius
          extenalFillColor:(UIColor *)extenalFillColor
          intenalFillColor:(UIColor *)intenalFillColor
                boradColor:(UIColor *)strokeColor
                boradWidth:(CGFloat)lineWidth
               resultBlock:(void(^)(UIImage *result))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //绘图
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, extenalFillColor.CGColor);
        
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        //填充使用外部颜色填充整个矩形
        CGContextFillRect(context, rect);
        
        //利用贝塞尔曲线裁剪矩形
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
        if (strokeColor && lineWidth > 0) {
            path.lineWidth = lineWidth;
            [strokeColor setStroke];
            CGContextSetFillColorWithColor(context, intenalFillColor.CGColor);
            [path stroke];
            [path fill];
        }
        //裁剪
        [path addClip];
        
        //绘制图像
        if (image) {
            [image drawInRect:rect];
        }
        //获取图像
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            block(image);
        });
        
    });
}


+ (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size {
    UIImage *codeImage = nil;
    NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor blackColor];
    UIColor *offColor = [UIColor whiteColor];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);

    return codeImage;
}

+ (UIImage *)coverArea:(CGRect)coverArea clearArea:(CGRect)clearArea coverColor:(UIColor *)coverColor{
    
    UIGraphicsBeginImageContextWithOptions(coverArea.size, NO, 0);
    CGContextRef context =  UIGraphicsGetCurrentContext();
    
    CGFloat coverAreaLeft = CGRectGetMinX(coverArea);
    CGFloat coverAreaRight = CGRectGetMaxX(coverArea);
    CGFloat coverAreaTop = CGRectGetMinY(coverArea);
    CGFloat coverAreaBottom = CGRectGetMaxY(coverArea);
    
    CGFloat clearAreaLeft = CGRectGetMinX(clearArea);
    CGFloat clearAreaRight = CGRectGetMaxX(clearArea);
    CGFloat clearAreaTop = CGRectGetMinY(clearArea);
    CGFloat clearAreaBottom = CGRectGetMaxY(clearArea);
    
    //右上半部分
    UIBezierPath *rightTopPath = [UIBezierPath bezierPath];
    rightTopPath.lineWidth = 5;
    //外部左上
    [rightTopPath moveToPoint:CGPointMake(coverAreaLeft, coverAreaTop)];
    //外部右上
    [rightTopPath addLineToPoint:CGPointMake(coverAreaRight, coverAreaTop)];
    //外部右下
    [rightTopPath addLineToPoint:CGPointMake(coverAreaRight, coverAreaBottom)];
    
    //中空右下
    [rightTopPath addLineToPoint:CGPointMake(clearAreaRight, clearAreaBottom)];
    //中空右上
    [rightTopPath addLineToPoint:CGPointMake(clearAreaRight, clearAreaTop)];
    //中空左上
    [rightTopPath addLineToPoint:CGPointMake(clearAreaLeft, clearAreaTop)];
    
    [rightTopPath closePath];
    CGContextAddPath(context, rightTopPath.CGPath);
    
    //左下半部分
    UIBezierPath *leftBottomPath = [UIBezierPath bezierPath];
    leftBottomPath.lineWidth = 5;
    //外部左上
    [leftBottomPath moveToPoint:CGPointMake(coverAreaLeft, coverAreaTop)];
    //外部左下
    [leftBottomPath addLineToPoint:CGPointMake(coverAreaLeft, coverAreaBottom)];
    //外部右下
    [leftBottomPath addLineToPoint:CGPointMake(coverAreaRight, coverAreaBottom)];

    //中空右下
    [leftBottomPath addLineToPoint:CGPointMake(clearAreaRight, clearAreaBottom)];
    //中空左下
    [leftBottomPath addLineToPoint:CGPointMake(clearAreaLeft, clearAreaBottom)];
    //中空左上
    [leftBottomPath addLineToPoint:CGPointMake(clearAreaLeft, clearAreaTop)];
    
    [leftBottomPath closePath];
    
    CGContextAddPath(context, leftBottomPath.CGPath);
    
    CGContextSetFillColorWithColor(context,coverColor.CGColor);

    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return image;
}

+ (void)GIF:(NSString *)path block:(void(^)(NSArray <UIImage *>*imageArray,
                                            NSArray <NSNumber *>*timeArray,
                                            CGFloat totoalTime))block{
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageSourceRef sourceRef =  CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    //    NSData *data =[NSData dataWithContentsOfFile:path];
    //    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    //帧数:图片数量
    size_t framesCount =  CGImageSourceGetCount(sourceRef);
    CGFloat totoalTime = 0;
    NSMutableArray *imagesArray = [NSMutableArray arrayWithCapacity:framesCount];
    NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:framesCount];
    for (int index = 0; index < framesCount ; index ++) {
        //生成图片
        CGImageRef  imageRef = CGImageSourceCreateImageAtIndex(sourceRef, index, (__bridge CFDictionaryRef)@{(__bridge id)kCGImageSourceShouldCache:@YES});
        [imagesArray addObject:(__bridge UIImage*)imageRef];
        CGImageRelease(imageRef);
        //图片信息
        CFDictionaryRef currentImageProperties = CGImageSourceCopyPropertiesAtIndex(sourceRef, index, NULL);
        CFDictionaryRef gifProperties = (CFDictionaryRef)CFDictionaryGetValue(currentImageProperties, kCGImagePropertyGIFDictionary);
        
        CGFloat imageDelayTime = [(__bridge NSNumber *)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime) floatValue];
        [timeArray addObject:@(imageDelayTime)];
        
        totoalTime = totoalTime + imageDelayTime;
        
        CFRelease(currentImageProperties);
    }
    CFRelease(sourceRef);
    
    block(imagesArray,timeArray,totoalTime);
}

@end
