//
//  ChatViewController.m
//  XMPP_Text
//
//  Created by JLItem on 15/8/18.
//  Copyright (c) 2015年 高建龙. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPManager.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate,XMPPStreamDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClick)];
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    self.messageArray = [[NSMutableArray alloc] init];
    [self reloaMessage];
    
    [[XMPPManager shareXMPPManager].XMPPStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    
}

#pragma mark   导航栏添加按钮
- (void)addButtonClick
{
    NSLog(@" 添加 ");
    XMPPMessage *message = [[XMPPMessage alloc] initWithType:@"chat" to:self.jid];
    
    [[XMPPManager shareXMPPManager].XMPPStream sendElement:message];
    
    [message addBody:@"龙哥威武"];
}


// 发送消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    [self reloaMessage];
}

// 收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"收到消息了 ====== %@",message);
    [self reloaMessage];
}

- (void)reloaMessage
{
    NSManagedObjectContext *context = [XMPPManager shareXMPPManager].context;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    NSString *str = self.jid.bare;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@ AND streamBareJidStr = %@", str,[XMPPManager shareXMPPManager].XMPPStream.myJID.bare];
    
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    //NSLog(@"%@",fetchedObjects);
    
    if (self.messageArray.count != 0) {
        
        [self.messageArray removeAllObjects];
    }
    
    [self.messageArray setArray:fetchedObjects];
    [self.tableView reloadData];
    
    if (self.messageArray.count) {
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

#pragma mark  ----  tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
    if ([message isOutgoing]) {
        cell.textLabel.text = message.body;
        cell.textLabel.tintColor = [UIColor redColor];
    }
    else {
        
        cell.textLabel.text = message.body;
    }
        
    return cell;
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
