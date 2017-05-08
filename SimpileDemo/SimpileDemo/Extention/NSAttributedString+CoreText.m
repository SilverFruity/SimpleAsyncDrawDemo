//
//  NSAttributedString+CoreText.m
//  SharedGym
//
//  Created by Jiang on 2017/5/5.
//
//

#import "NSAttributedString+CoreText.h"
#import <CoreText/CoreText.h>
@implementation NSAttributedString (CoreText)

- (int)stirngHeightWithStringWidth:(int) width
{
    if (self.length == 0) {
        return 0;
    }
    int total_height = 0;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:drawingRect];
    
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,self.length), path.CGPath, NULL);
    CFRelease(framesetter);
    
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
    return total_height;
}
@end
