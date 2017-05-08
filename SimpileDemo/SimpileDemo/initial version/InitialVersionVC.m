//
//  GymMessageBoardVC.m
//  SharedGym
//
//  Created by Jiang on 2017/5/2.
//
//

#import "InitialVersionVC.h"
#import "InitialTableViewCell.h"

NSString *const InitialVersionVC_ReuseCellIdentity = @"InitialTableViewCell.h";
@interface InitialVersionVC ()<UITableViewDelegate,UITableViewDataSource,InitialTableViewCellDelegate>
@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,strong)NSCache *cellCache;
@end

@implementation InitialVersionVC
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    self.tableView.rowHeight = 500;
    self.tableView.allowsSelection = NO;
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView registerClass:[InitialTableViewCell class] forCellReuseIdentifier:InitialVersionVC_ReuseCellIdentity];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InitialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InitialVersionVC_ReuseCellIdentity];
    cell.delegate = self;
    [cell resetWithModel:nil];
    [cell setHasLoadedBlock:^(InitialTableViewCell *cell){
//        NSLog(@"成功加载 %p",cell);
    }];
    return cell;
}
#pragma mark InitialTableViewCellDelegate
- (void)InitialTableViewCell:(InitialTableViewCell *)cell touchImage:(UIImage *)image windowRect:(CGRect)windowRect  AtIndex:(NSUInteger)index{
    
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
    //    [tableView indexPathsForRowsInRect:<#(CGRect)#>]
    //    [tableView indexPathForRowAtPoint:<#(CGPoint)#>]
}

- (void)dealloc{
//    NSLog(@"");
}

@end
