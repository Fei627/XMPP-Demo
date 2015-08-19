//
//  ListViewController.m
//  XMPP_Text
//
//  Created by JLItem on 15/8/18.
//  Copyright (c) 2015年 高建龙. All rights reserved.
//

#import "ListViewController.h"
#import "XMPPManager.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "ChatViewController.h"

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, XMPPRosterDelegate>

@property (nonatomic, strong) NSMutableArray *friendArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友列表";
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [[XMPPManager shareXMPPManager] loginWithUserName:[user objectForKey:@"userName"] PassWord:[user objectForKey:@"passWord"]];
    
    [[XMPPManager shareXMPPManager].XMPPRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.friendArray = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
 
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    logoutButton.frame = CGRectMake(0, 0, 40, 30);
    [logoutButton setTitle:@"注销" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
}

#pragma mark   注销登录
- (void)logoutButtonClick
{
    NSLog(@"注销");
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user setBool:NO forKey:@"isLogin"];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *navigaC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    app.window.rootViewController = navigaC;
}



- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    NSLog(@"开始检索好友花名册");
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    NSLog(@"检索到好友花名册  %@",item);
    
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    
    if ([self.friendArray containsObject:jid]) {
        return;
    }
    
    [self.friendArray addObject:jid];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.friendArray.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"结束检索好友花名册");
}

#pragma mark   tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPJID *jid = self.friendArray[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    cell.textLabel.text = jid.user;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPJID *jid = self.friendArray[indexPath.row];
    
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    
    chatVC.jid = jid;
    
    [self.navigationController pushViewController:chatVC animated:YES];
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
