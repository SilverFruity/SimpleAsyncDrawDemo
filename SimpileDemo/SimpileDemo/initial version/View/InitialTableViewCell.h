//
//
//  Created by Jiang on 2017/5/5.
//
//

#import <UIKit/UIKit.h>
@class InitialTableViewCell;

@protocol InitialTableViewCellDelegate<NSObject>
- (void)InitialTableViewCell:(InitialTableViewCell *)cell touchImage:(UIImage *)image windowRect:(CGRect)windowRect  AtIndex:(NSUInteger)index;
@end

@interface InitialTableViewCell : UITableViewCell

@property(nonatomic,weak)id <InitialTableViewCellDelegate> delegate;

@property(nonatomic,weak)UIView   *splitView;
@property(nonatomic,weak)UIButton *avatorBtn;
@property(nonatomic,weak)UILabel  *nameLB;
@property(nonatomic,weak)UIButton *reportBtn;

@property(nonatomic,weak)UIView   *textView;
@property(nonatomic,weak)UIView   *imageColletionView;

@property(nonatomic,weak)UILabel  *timeLBl;
@property(nonatomic,weak)UILabel  *praiseCountLB;
@property(nonatomic,weak)UIButton *praiseBtn;
@property(nonatomic,weak)UIButton *commentBtn;

@property(nonatomic,copy)void (^hasLoadedBlock)(InitialTableViewCell *cell);
//+ (CGFloat)caculatCellHeightWithModel:(NSDictionary *)model;
- (void)resetWithModel:(NSDictionary *)model;

@end
