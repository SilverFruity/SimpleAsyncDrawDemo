//
//  ViewController.m
//  SimpileDemo
//
//  Created by Jiang on 2017/5/8.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "ViewController.h"
#import "InitialVersionVC.h"
#import "FinalVersionVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)initial:(id)sender {
    InitialVersionVC *vc = [[InitialVersionVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)final:(id)sender {
    FinalVersionVC *vc = [[FinalVersionVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
