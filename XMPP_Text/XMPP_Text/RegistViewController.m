//
//  RegistViewController.m
//  XMPP_Text
//
//  Created by lanou3g on 15/8/17.
//  Copyright (c) 2015年 高建龙. All rights reserved.
//

#import "RegistViewController.h"
#import "XMPPManager.h"

@interface RegistViewController () <XMPPStreamDelegate>

@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UITextField *nameTF;

@property (nonatomic, strong) UILabel *passLable;
@property (nonatomic, strong) UITextField *passTF;

@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [[XMPPManager shareXMPPManager].XMPPStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self layoutMainView];
    
    
}

#pragma mark  布局视图
- (void)layoutMainView
{
    self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 60, 30)];
    self.nameLable.text = @"用户名";
    [self.view addSubview:self.nameLable];
    
    self.nameTF = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
    self.nameTF.placeholder = @"用户名";
    self.nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.nameTF];
    
    self.passLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 60, 30)];
    self.passLable.text = @"密码";
    [self.view addSubview:self.passLable];
    
    self.passTF = [[UITextField alloc] initWithFrame:CGRectMake(100, 150, 200, 30)];
    self.passTF.placeholder = @"密码";
    self.passTF.borderStyle = UITextBorderStyleRoundedRect;
    self.passTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.passTF];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton.frame = CGRectMake(20, 200, 60, 30);
    [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.registerButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.registerButton];
}

#pragma mark  按钮的点击
- (void)registerButtonClick
{
    //NSLog(@"注册");
    
    [[XMPPManager shareXMPPManager] registerWithUserName:self.nameTF.text PathWord:self.passTF.text];
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
