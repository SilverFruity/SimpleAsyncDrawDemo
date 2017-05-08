//
//
//  Created by Jiang on 2017/5/7.
//
//

#import "AsyncLable.h"

#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AsyncLable()
@property(nonatomic,strong)NSOperationQueue *drawOperationQueue;
@end
@implementation AsyncLable


- (instancetype)initWithFrame:(CGRect)frame operationQueue:(NSOperationQueue *)queue
{
    self = [super initWithFrame:frame];
    if (self) {
        _drawOperationQueue = queue;
    }
    return self;
}

- (void)setText:(NSString *)text{
    _text = text;
    [self asynDrawWithAttributedString:[AsyncLable attributedText:_text]];
}

+ (NSAttributedString *)attributedText:(NSString *)text{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.lineSpacing = 2;
    style.alignment = NSTextAlignmentLeft;
    style.headIndent = 0;
    NSAttributedString *attriStr = [[NSAttributedString alloc]initWithString:text
                                                                  attributes:@{NSParagraphStyleAttributeName:style,
                                                                               NSForegroundColorAttributeName:[UIColor blackColor],
                                                                               NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    return attriStr;
}

#pragma mark - 绘制文字内容
- (void)asynDrawWithAttributedString:(NSAttributedString *)string{
    if (string == nil) {
        return;
    }
    [self.drawOperationQueue addOperationWithBlock:^{
        CGRect TextRect = CGRectMake(0, 0, self.width, [AsyncLable caculatorAttribuedStringHeight:string withWidth:self.width].height);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.size = TextRect.size;
            if (self.hasSetSize) {
                self.hasSetSize(self);
            }
        }];
        UIGraphicsBeginImageContextWithOptions(TextRect.size, NO, SCREEN_SCALE);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, TextRect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillRect(context, TextRect);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:TextRect];
        // ------------------------ begin draw
        // draw coretext
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(string));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), path.CGPath, NULL);
        CTFrameDraw(frame, context);
        UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.layer.contents = (__bridge id)textImage.CGImage;
        }];
        CFRelease(frame);
        CFRelease(framesetter);
    }];
}

+ (CGSize)caculatorSizeWithString:(NSString *)string viewWidth:(CGFloat)width{
    return  [AsyncLable caculatorAttribuedStringHeight:[AsyncLable attributedText:string] withWidth:width];
}

+ (CGSize)caculatorAttribuedStringHeight:(NSAttributedString *)string withWidth:(CGFloat)width{
    
    if (string.length == 0){
        return CGSizeZero;
    }
    int total_height = 0;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:drawingRect];
    
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,string.length), path.CGPath, NULL);

    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    NSInteger totalLineCount = [linesArray count];
    CGPoint origins[totalLineCount];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int lastLine_y = (int) origins[totalLineCount -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:totalLineCount-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    total_height = 1000 - lastLine_y + (int) descent + 1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    CFRelease(framesetter);
    
    return CGSizeMake(width, total_height);
}
@end
