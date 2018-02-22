# Webview 中 原生 和  HTML 的交互示例  
# 简而言之 就两点
# 一 在JS中 给 原生如何通信  
通过在webview的代理方法中 过滤自定义的协议 ，在原生中拦截请求 获取操作意图 进行相应的操作    
```
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
```  

# 二 在原生中如何操作DOM 
	是通过 webview 显性的调用 stringByEvaluatingJavaScriptFromString 来进行实现的  
  
```  
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
```
