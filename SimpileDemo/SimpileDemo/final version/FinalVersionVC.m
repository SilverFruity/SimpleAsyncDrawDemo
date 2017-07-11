//
//
//  Created by Jiang on 2017/5/2.
//
//

#import "FinalVersionVC.h"
#import "FinalTableViewCell.h"



NSString *const reuseCellIdentity = @"FinalTableViewCell";

@interface FinalVersionVC ()<UITableViewDelegate,UITableViewDataSource,FinalTableViewCellDelegate>

@property (nonatomic,weak)UITableView *tableView;
@property (nonatomic,strong)NSArray *dataSource;
@property (nonatomic,strong)NSArray *heightCache;
@end
@implementation FinalVersionVC

- (UITableView *)tableView{
    if (_tableView == nil) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    self.tableView.allowsSelection = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[FinalTableViewCell class] forCellReuseIdentifier:reuseCellIdentity];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *new = [NSMutableArray array];
        NSMutableArray *heightArr = [NSMutableArray array];
        NSString *path =  [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
        [[NSArray arrayWithContentsOfFile:path] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *imageURLs = [NSMutableArray array];
            NSDictionary *retweeted_status = model[@"retweeted_status"];
            if (retweeted_status) {
                NSArray *pic_urls = retweeted_status[@"pic_urls"];
                [pic_urls enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *url =  obj[@"thumbnail_pic"];
                    [imageURLs addObject:[NSURL URLWithString:url]];
                }];
            }
            NSDictionary *usrDict = model[@"user"];
            NSURL *avatar = [NSURL URLWithString:usrDict[@"profile_image_url"]];
            NSString *name = usrDict[@"name"];
            NSString *text = model[@"text"];
            
            [new addObject:@{@"text":text,@"url":imageURLs,@"avatar":avatar,@"name":name}];
            CGFloat cellheight = [FinalTableViewCell caculatCellHeightWithModel:@{@"text":text,@"url":imageURLs}];
            [heightArr addObject:@(cellheight)];
        }];
        _heightCache = heightArr;
        _dataSource = new;
       dispatch_async(dispatch_get_main_queue(), ^{
               [self.tableView reloadData];
           self.tableView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
       });
    });


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FinalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentity];
    cell.delegate = self;
    [cell resetWithModel:_dataSource[indexPath.row]];
    [cell setHasLoadedBlock:^(FinalTableViewCell *cell){
//        NSLog(@"成功加载 %p",cell);
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [_heightCache[indexPath.row] integerValue] + 1;
}

#pragma mark FinalTableViewCellDelegate
- (void)FinalTableViewCell:(FinalTableViewCell *)cell touchImage:(UIImage *)image windowRect:(CGRect)windowRect  AtIndex:(NSUInteger)index{
    NSLog(@"row - %lu",[self.tableView indexPathForCell:cell].row);
    UIButton *backView = [[UIButton alloc]initWithFrame:self.view.bounds];
    UIImageView *view = [[UIImageView alloc]initWithImage:image];
    view.frame = windowRect;
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:view];
    [self.view addSubview:backView];
    [UIView animateWithDuration:0.3 animations:^{
        view.size = image.size;
        view.center = self.view.contentCenter;
        backView.backgroundColor = [UIColor blackColor];
    }];
    
    [backView observeEvent:UIControlEventTouchDown block:^(UIButton *button) {
         [UIView animateWithDuration:0.3 animations:^{
             view.frame = windowRect;
             button.backgroundColor = [UIColor clearColor];
         } completion:^(BOOL finished) {
             [button removeFromSuperview];
         }];
    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)dealloc{
    [[SDWebImageManager sharedManager].imageCache clearMemory];
}


@end
