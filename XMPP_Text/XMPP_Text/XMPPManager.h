//
//  XMPPManager.h
//  XMPP_Text
//
//  Created by JLItem on 15/8/17.
//  Copyright (c) 2015年 高建龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"


@interface XMPPManager : NSObject

// XMPPManager的单例方法
+ (XMPPManager *)shareXMPPManager;

/**
 *  XMPP专门跟服务器链接的通道
 */
@property (nonatomic, strong) XMPPStream *XMPPStream;
/**
 *  管理用户行为的
 */
@property (nonatomic, strong) XMPPRoster *XMPPRoster;
/**
 *  信息缓存类
 */
@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;

@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 *  登陆方法
 */
- (void)loginWithUserName:(NSString *)userName PassWord:(NSString *)passWord;

/**
 *  注册方法
 */
- (void)registerWithUserName:(NSString *)userName PathWord:(NSString *)passWord;

@end
