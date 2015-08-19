//
//  XMPPManager.m
//  XMPP_Text
//
//  Created by JLItem on 15/8/17.
//  Copyright (c) 2015年 高建龙. All rights reserved.
//

#import "XMPPManager.h"

typedef NS_ENUM(NSInteger, connectToServerType)
{
    connectToServerTypeLogin,
    connectToServerTypeRegister,
};

@interface XMPPManager() <XMPPStreamDelegate,XMPPRosterDelegate,UIAlertViewDelegate>

@property (nonatomic) connectToServerType connectToServerType;

@property (nonatomic, copy) NSString *loginPassWord;

@property (nonatomic, copy) NSString *registerPassWord;

@property (nonatomic, strong) XMPPJID *myJid;

@end

@implementation XMPPManager

+ (XMPPManager *)shareXMPPManager
{
    static dispatch_once_t onceToken;
    
    static XMPPManager *manager = nil;
    dispatch_once(&onceToken, ^{
        
        manager = [[XMPPManager alloc] init];
    });
    
    return manager; 
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.XMPPStream = [[XMPPStream alloc] init];
        // 链接主机地址
        self.XMPPStream.hostName = @"127.0.0.1";
        // 设置端口号，默认是5222
        self.XMPPStream.hostPort = 5222;
        
        [self.XMPPStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // XMPPRoster的助手类，主要作用是从coreData里面读取用户的数据
        XMPPRosterCoreDataStorage *roster = [XMPPRosterCoreDataStorage sharedInstance];
        
        self.XMPPRoster = [[XMPPRoster alloc] initWithRosterStorage:roster dispatchQueue:dispatch_get_main_queue()];
        
        // 将用户类 放到通道里面
        [self.XMPPRoster activate:self.XMPPStream];
        [self.XMPPRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        XMPPMessageArchivingCoreDataStorage *coreData = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:coreData dispatchQueue:dispatch_get_main_queue()];
        
        [self.messageArchiving activate:self.XMPPStream];
        
        self.context = coreData.mainThreadManagedObjectContext;
        
        
    }
    return self;
}

/**
 *  向服务器发起链接
 */
- (void)connectToServer
{
    // 判断通道是否连接上，如果链接了，则断开
    if ([self.XMPPStream isConnected]) {
        [self disConnectToServer];
    }
    
    NSError *error = nil;
    // 通道类，去连接服务器，如果30秒内没有链接成功，则抛出error
    [self.XMPPStream connectWithTimeout:30.0f error:&error];
    
    if (error != nil) {
        NSLog(@"链接失败");
    }
}
/**
 *  跟服务器断开链接
 */
- (void)disConnectToServer
{
    // XMPPPresence 是通道向服务器发送消息的类
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    // XMPPStream 通过 sendElement 方法 发送消息
    [self.XMPPStream sendElement:presence];
    
    // 在发送消息之后，需要主动的断开链接
    [self.XMPPStream disconnect];
    
}

- (void)connectToServerWithUserName:(NSString *)userName
{
    // 用户的信息类，存储的是，用户名、用户来源等用户信息
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:@"127.0.0.1" resource:@"iOS"];
    
    self.XMPPStream.myJID = jid;
    
    [self connectToServer];
    
}

/**
 *  登陆方法
 *
 *  @param userName 用户名
 *  @param passWord 密码
 */
- (void)loginWithUserName:(NSString *)userName PassWord:(NSString *)passWord
{
    self.connectToServerType = connectToServerTypeLogin;
    self.loginPassWord = passWord;
    [self connectToServerWithUserName:userName];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:userName forKey:@"userName"];
    [user setObject:passWord forKey:@"passWord"];
    
    [user setBool:YES forKey:@"isLogin"];
}

/**
 *  注册方法
 *
 *  @param userName 用户名
 *  @param passWord 密码
 */
- (void)registerWithUserName:(NSString *)userName PathWord:(NSString *)passWord
{
    self.connectToServerType = connectToServerTypeRegister;
    self.registerPassWord = passWord;
    [self connectToServerWithUserName:userName];
}

#pragma mark  XMPPStreamDelegate

// 链接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"链接成功");
    switch (self.connectToServerType) {
        case connectToServerTypeLogin:
        {
            // 登陆的时候，通过密码进行身份验证
            [sender authenticateWithPassword:self.loginPassWord error:nil];
            break;
        }
        case connectToServerTypeRegister:
        {
            // 注册的时候，把密码传给服务器
            [sender registerWithPassword:self.registerPassWord error:nil];
            break;
        }
            
        default:
            break;
    }
}

// 链接失败
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"链接超时");
}

#pragma mark ---  验证
// 验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"验证成功");
    // 辅助通道类 向服务器发送消息
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.XMPPStream sendElement:presence];
    //[self.XMPPStream disconnect];
    
}

// 验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"验证失败 %@",  error);
}

#pragma mark ---  注册
// 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功");
}

// 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败");
}


#pragma mark  XMPPRoster delegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"收到好友请求");
    
    self.myJid = presence.from;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收到好友请求" message:presence.from.user delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
    [alertView show];
    
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [alertView dismissWithClickedButtonIndex:0 animated:YES]; // alertView自动消失
//    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            [self.XMPPRoster revokePresencePermissionFromUser:self.myJid];
            break;
        case 1:
            
            [self.XMPPRoster acceptPresenceSubscriptionRequestFrom:self.myJid andAddToRoster:YES];
            break;

        default:
            break;
    }
    
}








@end
