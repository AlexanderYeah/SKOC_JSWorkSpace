//
//  ViewController.m
//  WebViewDemo
//
//  Created by AY on 2018/2/22.
//  Copyright © 2018年 AY. All rights reserved.
//  

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>

/** 展示的webview */
@property (nonatomic,strong)UIWebView *showWebview;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	_showWebview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 400)];
	_showWebview.delegate = self;
	[self.view addSubview:_showWebview];
	
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	[self.showWebview loadRequest:req];
	
	
}

#pragma mark - Webview Delegate
/** 
	HTML 向 原生 通信方式
	拦截请求 解析出自定义的协议头
*/
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// 说白了 就是解析出HTMl中自定义的协议 告诉其目的要做什么操作
	
	NSLog(@"%@",request.URL.absoluteString);
	NSString *requestStr = request.URL.absoluteString;
	NSRange range = [requestStr rangeOfString:@"alex//:"];
	
	if (range.location != NSNotFound) {
		// 目标动作
		NSString *method = [requestStr substringFromIndex:range.location + range.length];
		//
		[self doActionWithOrder:method];
		return NO;
	}
	
	return YES;
}


/**
	原生向HTML 通信的方式
	是通过 webview 显性的调用 stringByEvaluatingJavaScriptFromString 来进行实现的
*/


#pragma mark - 根据对应的URL做相应的操作
- (void)doActionWithOrder:(NSString *)order
{
	
	if ([order isEqualToString:@"sayHi"]) {
		[self showInfoWithTitle:@"Hello world"];
	}else if ([order isEqualToString:@"changeVal"]){
		[self changeHTMLBtnValue];
	}else{
		[self addImageToHTML];
	}
	
}

// 修改HTML btn 中的内容
- (void)changeHTMLBtnValue
{
	// 拿到要改变的标签
	NSString *str1 = @"var word = document.getElementById('changeValBtn');";
	NSString *str2 = @"word.value = '666666';";
	
	// 顺序进行执行
	[self.showWebview stringByEvaluatingJavaScriptFromString:str1];
	[self.showWebview stringByEvaluatingJavaScriptFromString:str2];
}

// 插入一张图片
- (void)addImageToHTML
{
    // 3 插入一张图片
    NSString *str5 = @"var img = document.createElement('img');"
                        "img.src='19.jpg';"
                        "img.width = '400';"
                        "img.height = '400';"
                         "document.body.appendChild(img);";
	[self.showWebview stringByEvaluatingJavaScriptFromString:str5];
}


// 方法弹出标题
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
