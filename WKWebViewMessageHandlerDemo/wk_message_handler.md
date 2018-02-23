# WKWebView的MessageHandler 进行OC 和 JS 的互相调用

#### WKWebView 初始化时，有一个参数叫configuration，它是WKWebViewConfiguration类型的参数，
而WKWebViewConfiguration有一个属性叫userContentController，它又是WKUserContentController类型的参数。WKUserContentController对象有一个方法- addScriptMessageHandler:name:，我把这个功能简称为MessageHandler。
就必须要实现WKScriptMessageHandler协议。

# MessageHandler 使用步骤  
## 1 创建configuration 以及 webview 
```  
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
    
	
```  

## 2 配置各个API对应的MessageHandler  
```  
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
```

## 3 实现协议方法   OC 和 JS 的交互的实现
```
#pragma mark - WKScriptMessageHandler
// OC 和 JS 之间的交互 在这里实现

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
//    message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.
	
	// 获取js 传递过来的message body 确定响应的操作
	NSLog(@"body:%@",message.body);
	
	if ([message.name isEqualToString:@"SayHi"]) {
		[self showInfoWithTitle:@"Hello World"];
	}else if ([message.name isEqualToString:@"Share"]){
		
		// 将分享的结果显示到HTML上面
		// 实质上的 调用JS中的shareResult的函数
		NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@')",message.body[@"name"],message.body[@"链接"]];
		// 向js通信 回调结果在block 中
		[self.wkWebview evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
       		 NSLog(@"%@----%@",result, error);
    	}];
		
	}else{
		
	}

}
```  

# 以上是OC代码的编写 以下是js中的代码编写
## Tips:   
### 1 JS 向 OC 通信 通过下面的代码实现   
#### 调用对应的API 做对应的操作 postMessage 可以传递多种参数 字符串 字典  null 
```
    	// 向原生传递一个字符串
        function sayHiClick(argument) {
			
			window.webkit.messageHandlers.SayHi.postMessage('SayHi');
        }

		// 向原生传递一个字典
        function shareBtnClick(argument) {
			
			window.webkit.messageHandlers.Share.postMessage({
				'name':'百度','链接':'www.baidu.com'
			});
        }


```  

对应响应 OC 中调用JS的函数的方法  
```
          // 回调结果
        function shareResult(name,link){

        	 var content = "分享内容为:"+name+"------"+link;
        	 document.getElementById("showReturnValArea").innerHTML = content;	
        }

```



