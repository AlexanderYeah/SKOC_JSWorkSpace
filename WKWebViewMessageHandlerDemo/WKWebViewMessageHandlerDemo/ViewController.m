//
//  ViewController.m
//  WKWebViewMessageHandlerDemo
//
//  Created by AY on 2018/2/23.
//  Copyright © 2018年 AY. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()<WKScriptMessageHandler,WKUIDelegate>

@property (nonatomic,strong)WKWebView *wkWebview;


@end

@implementation ViewController


// 创建WKWebViewConfiguration对象，配置各个API对应的MessageHandler
// 在viewWillDisappear 中要进行移除
- (void)viewWillAppear:(BOOL)animated
{
	
	// addScriptMessageHandler 很容易导致循环引用
    // 控制器 强引用了WKWebView,WKWebView copy(强引用了）configuration， configuration copy （强引用了）userContentController
    // userContentController 强引用了 self （控制器）
	
	
	// 遵守 WKScriptMessageHandler 协议
	[self.wkWebview.configuration.userContentController addScriptMessageHandler:self name:@"SayHi"];
	[self.wkWebview.configuration.userContentController addScriptMessageHandler:self name:@"Share"];
	
}

// 对应的移除
- (void)viewWillDisappear:(BOOL)animated
{
	// 避免循环引用 进行移除
	[self.wkWebview.configuration.userContentController removeScriptMessageHandlerForName:@"SayHi"];
	[self.wkWebview.configuration.userContentController removeScriptMessageHandlerForName:@"Share"];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	// 创建对应的配置信息
	WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
	WKPreferences *preference = [[WKPreferences alloc]init];
	
	preference.javaScriptCanOpenWindowsAutomatically = YES;
	preference.minimumFontSize = 40.0f;
	config.preferences = preference;
	
	// 创建webview
	self.wkWebview = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
	
	//
	NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.wkWebview loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    self.wkWebview.UIDelegate = self;
    [self.view addSubview:self.wkWebview];
	
	
}


#pragma mark - WKUIDelegate


#pragma mark - WKScriptMessageHandler
// OC 和 JS 之间的交互 在这里实现

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
//    message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.

	NSLog(@"body:%@",message.body);
	
	if ([message.name isEqualToString:@"SayHi"]) {
		[self showInfoWithTitle:@"Hello World"];
	}else if ([message.name isEqualToString:@"Share"]){
		
		// 将分享的结果显示到HTML上面  调用JS中的shareResult的函数
		NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@')",message.body[@"name"],message.body[@"链接"]];
		// 向js通信 回调结果在block 中
		[self.wkWebview evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
       		 NSLog(@"%@----%@",result, error);
    	}];
		
	}else{
		
	}

}





// 弹出信息方法
- (void)showInfoWithTitle:(NSString *)str
{
	NSString *showStr = str;
	
	UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
		[self dismissViewControllerAnimated:YES completion:nil];
		
	}];
	
	UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"U Need to Know" message:showStr preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:ac1];
	[alert addAction:ac2];
	[self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
