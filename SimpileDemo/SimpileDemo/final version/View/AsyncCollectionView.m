//
//
//  Created by Jiang on 2017/5/7.
//
//

#import "AsyncCollectionView.h"

NSUInteger sectionMaxCount = 3;
CGFloat cellMargin = 5;
@interface AsyncCollectionView()
{
    NSUInteger _cellTotalCount;
}
@property(nonatomic,strong)NSMutableArray <NSValue *>*imageRectArray;
@property(nonatomic,strong)NSMutableArray <UIImage *>*imageArray;
@property(nonatomic,strong)NSOperationQueue *drawOperationQueue;
@property(nonatomic,strong)UIImage *content;
@end
@implementation AsyncCollectionView

- (instancetype)initWithFrame:(CGRect)frame operationQueue:(NSOperationQueue *)queue
{
    self = [super initWithFrame:frame];
    if (self) {
        _drawOperationQueue = queue;
    }
    return self;
}

- (void)setCellTotalCount:(NSUInteger)cellTotalCount{
    [self.drawOperationQueue addOperationWithBlock:^{
        _cellTotalCount = cellTotalCount;
        //根据图片数量进行初始化
        self.imageRectArray = [NSMutableArray array];
        for (int index = 0; index < _cellTotalCount; index ++ ) {
            [self.imageRectArray addObject:(NSValue *)[NSNull null]];
        }
        
        self.imageArray = [NSMutableArray array];
        for (int index = 0; index < _cellTotalCount; index ++ ) {
            [self.imageArray addObject:(UIImage *)[NSNull null]];
        }
    }];
    
    [self initialDraw];
}

//- (NSUInteger)cellTotalCount{
//    __block NSUInteger count = 0;
//    [self.drawOperationQueue addOperationWithBlock:^{
//       dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//           count = _cellTotalCount;
//       });
//    }];
//    return count;
//}

- (void)initialDraw{
    [self.drawOperationQueue addOperationWithBlock:^{
        if (_cellTotalCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.height = 0;
                if (self.hasSetSize) {
                    self.hasSetSize(self);
                }
            });
            return;
        }
            
        CGSize viewSize = caculatorViewSizeWithCount(_cellTotalCount, self.width);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.size = viewSize;
            if (self.hasSetSize) {
                self.hasSetSize(self);
            }
        });
        
        UIGraphicsBeginImageContextWithOptions(viewSize, NO,SCREEN_SCALE);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
        
        CGContextFillRect(context, CGRectMake(0, 0, viewSize.width, viewSize.height));
        
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        for (int index = 0; index < _cellTotalCount ; index ++) {
            CGRect imageRect = rectForIndexImage(index,_cellTotalCount,self.width);
            [self.imageRectArray replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:imageRect]];
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageRect];
            CGContextAddPath(context, path.CGPath);
            CGContextFillPath(context);
        }
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.content = viewImage;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.layer.contents = (__bridge id)viewImage.CGImage;
            self.size = viewImage.size;
            if (self.hasSetSize) {
                self.hasSetSize(self);
            }
        }];
    }];
}

- (void)asyncDrawIndex:(NSInteger)index currentTotalCount:(NSUInteger)count image:(UIImage *)image{

    [self.drawOperationQueue addOperationWithBlock:^{
        if (_cellTotalCount == 0 || image == nil || count != _cellTotalCount) {
            return;
        }
        //裁剪图片

        CGFloat min = MIN(image.size.width, image.size.height);
        CGFloat max = MAX(image.size.width, image.size.height);
        CGRect clipRect = CGRectZero;
        if (min == image.size.width) {
            clipRect = CGRectMake(0 , (max - min) / 2.f, min, min);
        }else{
            clipRect = CGRectMake((max - min) / 2.f, 0, min, min);
        }
        CGImageRef clipedImageRef =  CGImageCreateWithImageInRect(image.CGImage, clipRect);
        UIImage *clipedImage = [UIImage imageWithCGImage:clipedImageRef];
        CFRelease(clipedImageRef);
        //绘制
        UIImage *beforeContent = self.content;
        CGSize viewSize = caculatorViewSizeWithCount(_cellTotalCount, self.width);
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, SCREEN_SCALE);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [beforeContent drawInRect:CGRectMake(0, 0, viewSize.width, viewSize.height)];
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGRect imageRect = rectForIndexImage(index,_cellTotalCount,self.width);
        
        [self.imageRectArray replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:imageRect]];
        [self.imageArray replaceObjectAtIndex:index withObject:image];
        
        if (clipedImage) {
            [clipedImage drawInRect:imageRect];
        }else{
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageRect];
            CGContextAddPath(context, path.CGPath);
            CGContextFillPath(context);
        }
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.content = newImage;
        //这里是async
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.layer.contents = (__bridge id)newImage.CGImage;
        }];
    }];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    int index = 0;
    for (NSValue *rectValue in self.imageRectArray) {
        CGRect rect = [rectValue CGRectValue];
        CGPoint point = [touches.anyObject locationInView:self];
        if (CGRectContainsPoint(rect, point)) {
            if ([self.delegate respondsToSelector:@selector(TouchedImage:AtIndex:windowRect:)]) {
                CGRect windowRect = [self convertRect:rect toView:nil];
                [self.delegate TouchedImage:self.imageArray[index] AtIndex:index windowRect:windowRect];
            }
            return;
        }
        index++;
    }
}

+ (CGSize)caculatorViewSizeWithCount:(NSInteger)totalCount viewWidth:(CGFloat)width{
    return caculatorViewSizeWithCount(totalCount, width);
}

@end

NSInteger currentRow(NSInteger count){
    return count / sectionMaxCount;
}

CGFloat caclulatorImageWidth(NSInteger totalCount ,CGFloat viewWidth){
    return (viewWidth - (sectionMaxCount - 1) * cellMargin) / sectionMaxCount;
}

CGSize caculatorViewSizeWithCount(NSInteger totalCount, CGFloat viewWidth){
    if (totalCount == 0) {
        return CGSizeMake(viewWidth, 0);
    }
    CGFloat rowCount = currentRow(totalCount - 1);
    CGFloat viewHeight = caclulatorImageWidth(totalCount,viewWidth) * (rowCount + 1) + rowCount * cellMargin;
    return CGSizeMake(viewWidth, viewHeight);
}

CGRect rectForIndexImage(NSInteger index,NSInteger totalCount,CGFloat viewWidth){
    CGFloat width = caclulatorImageWidth(totalCount,viewWidth);
    CGFloat x = (index % sectionMaxCount) * (width + cellMargin) ;
    CGFloat y = currentRow(index) * (width + cellMargin);
    return CGRectMake(x, y, width, width);
}
