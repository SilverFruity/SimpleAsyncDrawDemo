//
//
//  Created by Jiang on 2017/5/5.
//
//

#import "FinalTableViewCell.h"
#import "AsyncCollectionView.h"
#import "AsyncLable.h"

#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>



#define fontColor [UIColor blackColor]

const CGFloat sideMargin = 15;
const CGFloat fontSize = 14;

const CGFloat   imageMargin = 5;
const NSInteger maxColCount = 3;
const CGFloat   avatorHeight = 50;
const CGFloat   subViewMargin = 5;

CGFloat contentWidth(){
    return SCREEN_WIDTH - 2 * sideMargin;
}

@interface FinalTableViewCell () <AsyncCollectionViewDelegate>
@property(nonatomic,strong)NSOperationQueue *serialOperaionQueue;

@end

@implementation FinalTableViewCell

+ (CGFloat)caculatCellHeightWithModel:(NSDictionary *)model{
    
    CGFloat textViewHeight = [AsyncLable caculatorSizeWithString:model[@"text"] viewWidth:contentWidth()].height;
    NSArray *urls = model[@"url"];
    CGFloat imageHeight = [AsyncCollectionView caculatorViewSizeWithCount:urls.count viewWidth:contentWidth()].height;
    return sideMargin * 2 + 2 * subViewMargin + textViewHeight + imageHeight + avatorHeight;
}

- (void)resetWithModel:(NSDictionary *)model{
    NSArray *imageURLs = model[@"url"];
    NSString *text = model[@"text"];
    NSString *name = model[@"name"];
    NSURL *avatar = model[@"avatar"];
    

    //取消队列中的所有任务
    [self.serialOperaionQueue cancelAllOperations];
    
    __weak typeof(self) weakself = self;
    [self.textView setHasSetSize:^(AsyncLable *label){
        weakself.imageColletionView.y = label.maxY + 5;
    }];
    self.textView.text = text;
    
    [self.imageColletionView setHasSetSize:^(AsyncCollectionView *view){
        
    }];
    self.imageColletionView.cellTotalCount = imageURLs.count;
    
//    self.textView.size = [AsyncLable caculatorSizeWithString:self.textView.text viewWidth:contentWidth()];
//    self.imageColletionView.size = [AsyncCollectionView caculatorViewSizeWithCount:imageURLs.count viewWidth:contentWidth()];
    
    for (NSURL *url in imageURLs) {
        [[SDWebImageManager sharedManager]loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            [self.imageColletionView asyncDrawIndex:[imageURLs indexOfObject:url] currentTotalCount:imageURLs.count image:image];
        } ];
    }
    
    self.nameLB.text = name;
    
    [[SDWebImageManager sharedManager]loadImageWithURL:avatar options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        [_avatorBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [self.serialOperaionQueue addOperationWithBlock:^{
            if (self.imageColletionView.cellTotalCount != imageURLs.count) {
                return;
            }
            UIImage *avatarImage = [image cornerImageWithCornerRadius:image.size.width * 0.5 fillColor:[UIColor clearColor]];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_avatorBtn setBackgroundImage:avatarImage forState:UIControlStateNormal];
            }];
        }];
    }];

}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _serialOperaionQueue = [[NSOperationQueue alloc]init];
        _serialOperaionQueue.maxConcurrentOperationCount = 1;
        _serialOperaionQueue.qualityOfService = NSQualityOfServiceDefault;
        //KVO
        [_serialOperaionQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
        
        [self UI];
    }
    return self;
}

- (void)UI{
    CGFloat topMargin = 10;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, topMargin,0, 0)];;
    view.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:view];
    _splitView = view;
    
    UIButton *avatorBtn = [[UIButton alloc]initWithFrame:CGRectMake(sideMargin, sideMargin, avatorHeight, avatorHeight)];
    UILabel  *nameLB = [[UILabel alloc]initWithFrame:CGRectMake(avatorBtn.right + 10, 0, 200, 40)];
    nameLB.centerY = avatorBtn.centerY;
    
    CGFloat reportBtnWidth = 50;
    
    UIButton *reportBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - reportBtnWidth, 0, reportBtnWidth, 30)];
    
    AsyncLable *textView = [[AsyncLable alloc]initWithFrame:CGRectMake(sideMargin, avatorBtn.bottom + subViewMargin, contentWidth(), 0) operationQueue:self.serialOperaionQueue];
    
    AsyncCollectionView *imagesView = [[AsyncCollectionView alloc]initWithFrame:CGRectMake(sideMargin, textView.bottom + subViewMargin, contentWidth(), 0) operationQueue:self.serialOperaionQueue];
    imagesView.delegate = self;
    
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
    
    
    UIImage *cornerImage = [[UIImage imageWithColor:[UIColor greenColor] size:_avatorBtn.size] cornerImageWithCornerRadius:_avatorBtn.width * 0.5 fillColor:[UIColor clearColor]];
    [_avatorBtn setBackgroundImage:cornerImage forState:UIControlStateNormal];
    
    _nameLB.font = [UIFont systemFontOfSize:fontSize];
    _nameLB.textColor = fontColor;
    _nameLB.textAlignment = NSTextAlignmentLeft;
    
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

//操作监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSUInteger operaionCount =  [change[NSKeyValueChangeNewKey] integerValue];
    if (operaionCount == 0) {
        if (self.hasLoadedBlock) {
            self.hasLoadedBlock(self);
        }
    }
}

- (void)TouchedImage:(UIImage *)image AtIndex:(NSUInteger)index windowRect:(CGRect)windowRect{
    if ([self.delegate respondsToSelector:@selector(FinalTableViewCell:touchImage:windowRect:AtIndex:)]) {
        [self.delegate FinalTableViewCell:self touchImage:image windowRect:windowRect AtIndex:index];
    }
}

- (void)dealloc{
    [self.serialOperaionQueue removeObserver:self forKeyPath:@"operationCount"];
}


@end
