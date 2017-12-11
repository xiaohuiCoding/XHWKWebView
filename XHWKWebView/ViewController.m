//
//  ViewController.m
//  XHWKWebView
//
//  Created by xiaohui on 2017/12/11.
//  Copyright © 2017年 XIAOHUI. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,WKNavigationDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //    self.dataSource = @[@"0"];
    self.dataSource = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 375, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    
    [self setUpFooterView];
    [self loadData];
}

- (void)setUpFooterView
{
    //添加js配置，约束html中的文本和图片
    NSString *jsString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:userScript];
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    webViewConfiguration.userContentController = userContentController;
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfiguration];
    _webView.navigationDelegate = self;
    _tableView.tableFooterView = _webView;
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 375, 0.5)];
    line.backgroundColor = [UIColor blackColor];
    [_webView addSubview:line];
}

- (void)loadData
{
    //加载本地文件
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"DetailHTML" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
    
    //    [_webView loadHTMLString:self.detailModel.customEditHTML baseURL:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    self.webView.scrollView.scrollEnabled = NO;
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable any, NSError * _Nullable error) {
        NSString *heightStr = [NSString stringWithFormat:@"%@",any];
        [_webView setFrame:CGRectMake(0, 0, 375, [heightStr floatValue])];
        [_tableView beginUpdates];
        [_tableView setTableFooterView:_webView];
        [_tableView endUpdates];
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

@end
