//
//
//  Created by Jiang on 2017/5/5.
//
//

#import <UIKit/UIKit.h>
@class FinalTableViewCell;
@class AsyncCollectionView;
@class AsyncLable;

@protocol FinalTableViewCellDelegate<NSObject>
- (void)FinalTableViewCell:(FinalTableViewCell *)cell touchImage:(UIImage *)image windowRect:(CGRect)windowRect  AtIndex:(NSUInteger)index;
@end

@interface FinalTableViewCell : UITableViewCell

@property(nonatomic,weak)id <FinalTableViewCellDelegate> delegate;

@property(nonatomic,weak)UIView   *splitView;
@property(nonatomic,weak)UIButton *avatorBtn;
@property(nonatomic,weak)UILabel  *nameLB;
@property(nonatomic,weak)UIButton *reportBtn;

@property(nonatomic,weak)AsyncLable   *textView;
@property(nonatomic,weak)AsyncCollectionView   *imageColletionView;

@property(nonatomic,weak)UILabel  *timeLBl;
@property(nonatomic,weak)UILabel  *praiseCountLB;
@property(nonatomic,weak)UIButton *praiseBtn;
@property(nonatomic,weak)UIButton *commentBtn;

@property(nonatomic,copy)void (^hasLoadedBlock)(FinalTableViewCell *cell);
+ (CGFloat)caculatCellHeightWithModel:(NSDictionary *)model;
- (void)resetWithModel:(NSDictionary *)model;

@end
