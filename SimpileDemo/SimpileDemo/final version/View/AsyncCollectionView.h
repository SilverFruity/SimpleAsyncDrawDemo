//
//
//  Created by Jiang on 2017/5/7.
//
//

#import <UIKit/UIKit.h>
FOUNDATION_EXPORT  NSUInteger sectionMaxCount(NSUInteger totalCount);
FOUNDATION_EXPORT  NSInteger currentRow(NSInteger count,NSUInteger totalCount);
FOUNDATION_EXPORT  CGFloat caclulatorImageWidth(NSInteger totalCount ,CGFloat viewWidth);
FOUNDATION_EXPORT  CGSize caculatorViewSizeWithCount(NSInteger totalCount, CGFloat viewWidth);
FOUNDATION_EXPORT  CGRect rectForIndexImage(NSInteger index,NSInteger totalCount,CGFloat viewWidth);

@protocol AsyncCollectionViewDelegate <NSObject>
- (void)TouchedImage:(UIImage *)image AtIndex:(NSUInteger)index windowRect:(CGRect)windowRect;
@end

@interface AsyncCollectionView : UIView

@property(nonatomic,assign)NSUInteger cellTotalCount;

@property(nonatomic,weak)id <AsyncCollectionViewDelegate> delegate;

@property(nonatomic,copy)void(^hasSetSize)(AsyncCollectionView *view);

- (instancetype)initWithFrame:(CGRect)frame operationQueue:(NSOperationQueue *)queue;
- (void)asyncDrawIndex:(NSInteger)index currentTotalCount:(NSUInteger)count image:(UIImage *)image;

+ (CGSize)caculatorViewSizeWithCount:(NSInteger)totalCount viewWidth:(CGFloat)width;

@end
