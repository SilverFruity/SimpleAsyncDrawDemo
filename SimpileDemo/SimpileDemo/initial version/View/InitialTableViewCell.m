//
//  GymMessageBoardCell.m
//  SharedGym
//
//  Created by Jiang on 2017/5/5.
//
//

#import "InitialTableViewCell.h"

#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>

const CGFloat kSideMargin = 15;

const CGFloat   kImageMargin = 5;
const NSInteger kMaxColCount = 3;

#define fontColor [UIColor blackColor]

@interface InitialTableViewCell ()
{
    NSMutableArray *_imageRectArray;
    NSMutableArray *_imageArray;
    UIImage *_collectionContent;
    NSUInteger _asyncLoadCount;
}


@property(nonatomic,strong)UIImage *collectionContent;
@property(nonatomic,strong)NSMutableArray <NSValue *>*imageRectArray;
@property(nonatomic,strong)NSMutableArray <UIImage *>*imageArray;

@property(nonatomic,assign)NSUInteger asyncLoadCount;

@property(nonatomic,strong)NSOperationQueue *UIOperaionQueue;
@property(nonatomic,weak)dispatch_queue_t UIQueue;

@end

@implementation InitialTableViewCell
+ (CGFloat)contentWidth{
    return SCREEN_WIDTH - 2 * kSideMargin;
}
- (void)setAsyncLoadCount:(NSUInteger)asyncLoadCount{
    _asyncLoadCount = asyncLoadCount;
    if (self.hasLoadedBlock && asyncLoadCount == 0) {
        self.hasLoadedBlock(self);
    }
}

- (void)resetWithModel:(id)model{
    NSArray *imageURLs = @[[NSURL URLWithString:@"http://www.2cto.com/uploadfile/2012/1207/20121207081844809.jpg"]
                           ,
                           [NSURL URLWithString:@"http://img5.duitang.com/uploads/item/201507/26/20150726201846_TCLxj.thumb.224_0.jpeg" ]
                           ,
                           [NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/2/59014a4eaca10.jpg"]
                           ,
                           [NSURL URLWithString:@"http://img3.duitang.com/uploads/item/201602/12/20160212214325_iFSaZ.thumb.224_0.jpeg"]
                           ,
                           [NSURL URLWithString:@"http://p.3761.com/pic/43701399945993.png"]
                           ,
                           [NSURL URLWithString:@"http://imgtu.5011.net/uploads/content/20170309/2037731489026344.png"]
                           ,
                           [NSURL URLWithString:@"http://img3.duitang.com/uploads/item/201511/15/20151115074120_afBn8.thumb.224_0.jpeg"]
                           ,
                           [NSURL URLWithString:@"http://cdn.duitang.com/uploads/item/201409/30/20140930231731_FAfQQ.thumb.224_0.jpeg"]
                           ,
                           [NSURL URLWithString:@"http://img.jsqq.net/uploads/allimg/150225/1-1502251614020-L.jpg"]
                           
                           ];
    
    __weak typeof(self) weakself = self;
    //    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    //    NSLog(@"%@",[path stringByAppendingPathComponent:@"default"]);
    
    //取消复用cell中的所有的操作
    [self.UIOperaionQueue cancelAllOperations];
    
    _asyncLoadCount = imageURLs.count + 1; //图片的绘制次数和文本绘制次数
    
    [self asynDrawText:@"希望对初学者有用或给一些解决疑难杂症者提供思路；"
                 block:^(UIImage *image) {
                     weakself.textView.size = image.size;
                     weakself.textView.layer.contents = (__bridge id)image.CGImage;
                     weakself.imageColletionView.y = self.textView.maxY + 5;
                 }];
    
    //根据图片数量进行初始化
    self.imageRectArray = [NSMutableArray array];
    for (int index = 0; index < imageURLs.count; index ++ ) {
        [self.imageRectArray addObject:(NSValue *)[NSNull null]];
    }
    
    self.imageArray = [NSMutableArray array];
    for (int index = 0; index < imageURLs.count; index ++ ) {
        [self.imageArray addObject:(UIImage *)[NSNull null]];
    }
    
    //初始化调用
    [self initDrawWith:imageURLs.count block:^(UIImage *image) {
        weakself.imageColletionView.size = image.size;
        weakself.imageColletionView.layer.contents = (__bridge id)image.CGImage;
    }];
    //遍历URL绘制
    for (NSURL *url in imageURLs) {
        [[SDWebImageManager sharedManager]loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            [self asynDrawImages:imageURLs.count curretnIndex:[imageURLs indexOfObject:url] image:image block:^(UIImage *image) {
                weakself.imageColletionView.size = image.size;
                weakself.imageColletionView.layer.contents = (__bridge id)image.CGImage;
            }];
        } ];
    }
    
    
    
    
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI];
        
        _UIOperaionQueue = [[NSOperationQueue alloc]init];
        _UIOperaionQueue.maxConcurrentOperationCount = 1;
        _UIOperaionQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        _UIQueue = _UIOperaionQueue.underlyingQueue;
    }
    return self;
}

- (void)UI{
    CGFloat cellWidth = SCREEN_WIDTH;
    CGFloat topMargin = 10;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, topMargin,0, 0)];;
    view.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:view];
    _splitView = view;
    
    CGFloat contentWidth = cellWidth - 2 * kSideMargin;
    
    UIButton *avatorBtn = [[UIButton alloc]initWithFrame:CGRectMake(kSideMargin, kSideMargin, 50, 50)];
    UILabel  *nameLB = [[UILabel alloc]initWithFrame:CGRectMake(avatorBtn.right + 10, 0, 200, 40)];
    nameLB.centerY = avatorBtn.centerY;
    
    CGFloat reportBtnWidth = 50;
    UIButton *reportBtn = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - reportBtnWidth, 0, reportBtnWidth, 30)];
    
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(kSideMargin, avatorBtn.bottom + 5, contentWidth, 0)];
    UIView *imagesView = [[UIView alloc]initWithFrame:CGRectMake(kSideMargin, textView.bottom + 5, contentWidth, 0)];
    
    [view addSubview:avatorBtn];
    [view addSubview:nameLB];
    [view addSubview:reportBtn];
    [view addSubview:textView];
    [view addSubview:imagesView];
    _avatorBtn = avatorBtn;
    _nameLB = nameLB;
    _reportBtn = reportBtn;
    _textView = textView;
    _imageColletionView = imagesView;
    
    //    _imagesView.userInteractionEnabled = YES;
    //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImagesView:)];
    //    [_imagesView addGestureRecognizer:tapGesture];
    
    UIImage *cornerImage = [[UIImage imageWithColor:[UIColor greenColor] size:_avatorBtn.size] cornerImageWithCornerRadius:_avatorBtn.width * 0.5 fillColor:[UIColor clearColor]];
    [_avatorBtn setBackgroundImage:cornerImage forState:UIControlStateNormal];
    
    _nameLB.font = [UIFont systemFontOfSize:14];
    _nameLB.textColor = fontColor;
    
    _nameLB.textAlignment = NSTextAlignmentLeft;
    _nameLB.text = @"朱丽叶";
    
    [_reportBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_reportBtn setTitle:@"· · ·" forState:UIControlStateNormal];
    _reportBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    UIImage *reportCornerImage = [[UIImage imageWithColor:[UIColor whiteColor] size:_reportBtn.size] cornerImageWithCornerRadius:5 fillColor:[UIColor clearColor]];
    [_reportBtn setBackgroundImage:reportCornerImage forState:UIControlStateNormal];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.splitView.size = CGSizeMake(self.width, self.height - _splitView.y);
}

- (NSAttributedString *)AttributedText:(NSString *)text{
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
- (void)asynDrawText:(NSString *)text block:(void(^)(UIImage *image))block{
    CGFloat contentWidth = self.textView.width;
    
    [self.UIOperaionQueue addOperationWithBlock:^{
        NSAttributedString *attriStr = [self AttributedText:text];
        CGRect TextRect = CGRectMake(0, 0, contentWidth, [attriStr stirngHeightWithStringWidth:contentWidth]);
        
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
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attriStr));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attriStr.length), path.CGPath, NULL);
        CTFrameDraw(frame, context);
        UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.asyncLoadCount --;
            block(textImage);
        }];
        CFRelease(frame);
        CFRelease(framesetter);
    }];
    
    
    
}



#pragma mark - 绘制colletionView
#pragma mark 计算
- (NSInteger)currentRow:(NSInteger)count{
    return count / kMaxColCount;
}

- (CGFloat)caclulatorImageWidth:(NSInteger)totalCount{
    return (self.imageColletionView.width - (kMaxColCount - 1) * kImageMargin) / kMaxColCount;
}

- (CGSize)caculatorViewSize:(NSInteger)totalCount{
    CGFloat rowCount = [self currentRow:totalCount - 1];
    CGFloat viewHeight = [self caclulatorImageWidth:totalCount] * (rowCount + 1) + rowCount * kImageMargin;
    return CGSizeMake(self.imageColletionView.width, viewHeight);
}

- (CGRect)rectForIndexImage:(NSInteger)index totalCount:(NSInteger)totalCount{
    CGFloat width = [self caclulatorImageWidth:totalCount];
    CGFloat x = (index % kMaxColCount) * (width + kImageMargin) ;
    CGFloat y = [self currentRow:index] * (width + kImageMargin);
    return CGRectMake(x, y, width, width);
}
#pragma mark 初始绘制
- (void)initDrawWith:(NSInteger)count block:(void(^)(UIImage *image))block{
    [self.UIOperaionQueue addOperationWithBlock:^{
        CGSize viewSize = [self caculatorViewSize:count];
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, SCREEN_SCALE);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
        
        CGContextFillRect(context, CGRectMake(0, 0, viewSize.width, viewSize.height));
        
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        for (int index = 0; index < count ; index ++) {
            CGRect imageRect = [self rectForIndexImage:index totalCount:count];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.imageRectArray replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:imageRect]];
            });
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageRect];
            CGContextAddPath(context, path.CGPath);
            CGContextFillPath(context);
        }
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(viewImage);
        }];
    }];
}

#pragma mark 图片绘制
- (void)asynDrawImages:(NSInteger )count curretnIndex:(NSInteger )index image:(UIImage *)image block:(void(^)(UIImage *image))block{
    if (count != self.imageArray.count || image == nil) {
        return;
    }
    [self.UIOperaionQueue addOperationWithBlock:^{
        UIImage *beforeImage = self.collectionContent;
        CGSize viewSize = [self caculatorViewSize:count];
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, SCREEN_SCALE);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [beforeImage drawInRect:CGRectMake(0, 0, viewSize.width, viewSize.height)];
        
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        
        CGRect imageRect = [self rectForIndexImage:index totalCount:count];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.imageRectArray replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:imageRect]];
            [self.imageArray replaceObjectAtIndex:index withObject:image];
        });

        if (image) {
            [image drawInRect:imageRect];
        }else{
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageRect];
            CGContextAddPath(context, path.CGPath);
            CGContextFillPath(context);
        }
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.collectionContent = viewImage;
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.asyncLoadCount --;
            block(viewImage);
        }];
    }];
}

#pragma mark - 点击事件
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (CGRectContainsPoint(self.imageColletionView.frame, [touches.anyObject locationInView:self])) {
        int index = 0;
        for (NSValue *rectValue in self.imageRectArray) {
            CGRect rect = [rectValue CGRectValue];
            CGPoint point = [touches.anyObject locationInView:self.imageColletionView];
            if (CGRectContainsPoint(rect, point)) {
                if ([self.delegate respondsToSelector:@selector(InitialTableViewCell:touchImage:windowRect:AtIndex:)]) {
                    CGRect windowRect = [self.imageColletionView convertRect:rect toView:nil];
                    [self.delegate InitialTableViewCell:self touchImage:self.imageArray[index] windowRect:windowRect AtIndex:index];
                }
                return;
            }
            index++;
        }
    }
}

- (void)dealloc{
//    NSLog(@"%p",self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
