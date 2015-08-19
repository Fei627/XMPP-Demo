//
//  RootViewController.m
//  XMPP_Text
//
//  Created by lanou3g on 15/8/17.
//  Copyright (c) 2015年 高建龙. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    
    /*
     字段  UserName
     
     通道
     
     发起链接  判断是否是链接状态
     
     断开链接  通过通道这个类 告诉服务器 我们要断开链接
     */
    
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    
    [self.navigationController pushViewController:loginVC animated:YES];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
