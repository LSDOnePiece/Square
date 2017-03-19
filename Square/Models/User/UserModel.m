//
//  UserModel.m
//  Square
//
//  Created by Nine on 2017/3/19.
//  Copyright © 2017年 Nine. All rights reserved.
//

#import "UserModel.h"
#import "TFHpple.h"
#import "AFNetworking.h"

AFHTTPRequestOperationManager *AFHROM;

@implementation UserModel

-(void)acquireViewStare:(NSString *)userName passWord:(NSString *)passWord code:(NSString *)secCode{
    _userName=userName;
    _passWorld=passWord;
    _secCode=secCode;
    [self.AFHROM GET:@"http://218.75.197.124:83/default2.aspx" parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                 NSData *data=responseObject;
                 NSString *transStr=[[NSString alloc]initWithData:data encoding:enc];
                 NSString *utf8HtmlStr = [transStr stringByReplacingOccurrencesOfString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
                 NSData *htmlDataUTF8 = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
                 TFHpple *xpathParser = [[TFHpple alloc]initWithHTMLData:htmlDataUTF8];
                 NSArray *elements  = [xpathParser searchWithXPathQuery:@"//input[@name='__VIEWSTATE']"];
                 
                 NSUInteger count=[elements count];
                 for (int i=0; i<count; i++) {
                     TFHppleElement *element = [elements objectAtIndex:i];
                     self.viewState=[element objectForKey:@"value"];
                     NSLog(@"1提取到得viewstate为%@",self.viewState);
                     [self logins];
                 }
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", [error debugDescription]);
             }];
}
-(void)logins{
    //[self.view showHUDWithText:@"登录中" hudType:kXHHUDLoading animationType:kXHHUDFade delay:0];
    NSDictionary *parameters = @{@"__VIEWSTATE":self.viewState,@"txtUserName": _userName,@"TextBox2":_passWorld,@"txtSecretCode":_secCode,@"RadioButtonList1":@"学生",@"Button1":@""};
    [self.AFHROM POST:@"http://218.75.197.124:83/default2.aspx" parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSURL *denglu=[NSURL URLWithString:@"http://218.75.197.124:83/default2.aspx"];
                  if ([operation.response.URL isEqual:denglu]) {
                      //  [self miMaCuoWu];
                      NSLog(@"登陆错误");
                  }else{
                      NSLog(@"登陆成功");
                      NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                      
                      NSData *data=responseObject;
                      NSString *tansData=[[NSString alloc]initWithData:data encoding:enc];
                      
                      //                      NSLog(@"转化过的string为%@",tansData);
                      
                      NSLog(@"biaodantijiaochenggong:%ld，%@",(long)operation.response.statusCode,operation.responseString);//提交表单
                      NSString *utf8HtmlStr = [tansData stringByReplacingOccurrencesOfString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
                      NSData *htmlDataUTF8 = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
                      [self anayseLoginData:htmlDataUTF8];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", @"???");
              }];
}
-(void)anayseLoginData:(NSData*)data{
    TFHpple *xpathParser = [[TFHpple alloc]initWithHTMLData:data];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//span[@id='xhxm']"];
    // Access the first cell
    NSUInteger count=[elements count];
    for (int i=0; i<count; i++) {
        TFHppleElement *element = [elements objectAtIndex:i];
        // Get the text within the cell tag
        NSString *content = [element text];
        NSString *ta=[element tagName];
        NSLog(@"学号姓名为%@%@%@",content,ta,[content substringToIndex:[content length]-2]);
    }
   // [self acquireData];
}

-(void)acquireData{
    AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
    //  MainInterfaceAppDelegate *mainDele=[[UIApplication sharedApplication]delegate];
    if(_userName!=nil&&_passWorld!=nil){
        NSDictionary *parameters2 = @{@"xh":_userName,@"xm":_passWorld,@"gnmkdm":@"N121603"};
        manager2.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self.AFHROM GET:@"http://218.75.197.124:83/xskbcx.aspx?" parameters:parameters2
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
                     
                     NSData *data=responseObject;
                     NSString *transStr=[[NSString alloc]initWithData:data encoding:enc];
                     
                     NSLog(@"huoqushuju: %ld",(long)operation.response.statusCode);
                     NSLog(@"课表数据：%@",transStr);
                     NSString *utf8HtmlStr = [transStr stringByReplacingOccurrencesOfString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
                     NSData *htmlDataUTF8 = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
                     TFHpple *xpathParser = [[TFHpple alloc]initWithHTMLData:htmlDataUTF8];
                     NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@id='Table1']/tr/td/child::text()"];
                     
                     // Access the first cell
                     NSUInteger count=[elements count];
                     NSMutableArray *allContents=[NSMutableArray array];
                     for (int i=0; i<count; i++) {
                         
                         TFHppleElement *element = [elements objectAtIndex:i];
                         
                         // Get the text within the cell tag
                         NSString *content = [element text];
                         NSString *ta=[element tagName];
                         NSDictionary *dic=[element attributes];
                         NSString *nodeContent=[element content];
                         //NSLog(@"课程为%@%@",nodeContent,ta);
                         NSLog(@"%@",nodeContent);
                         [allContents addObject:nodeContent];
                     }
                     
                     [self sortData:allContents];
                     NSLog(@"---------整理后---------------");
                     //              for(NSString *a in allContents){
                     //                  NSLog(@"%@",a);
                     //              }
                     __block int i=0;
                     [allContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                         i++;
                         NSLog(@"%@",obj);
                         if (i%4==0) {
                             NSLog(@"------------");
                         }
                     }];
                     
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", [error debugDescription]);
                 }];//获取登陆后的网页
    }
}
-(void)sortData:(NSMutableArray*)arrayData{
    __block NSMutableIndexSet* indexSet=[NSMutableIndexSet indexSet];
    [arrayData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *string=obj;
        if([string isEqualToString:@" "]||[string hasPrefix:@"星期"]||[string isEqualToString:@"上午"]||[string isEqualToString:@"下午"]||[string isEqualToString:@"早晨"]||[string isEqualToString:@"晚上"]){
            [indexSet addIndex:idx];
        }
        if([string hasPrefix:@"第"]&&[string hasSuffix:@"节"]){
            [indexSet addIndex:idx];
        }
        if([string isEqualToString:@"时间"]){
            [indexSet addIndex:idx];
        }
        if ([string hasPrefix:@"2014年"]) {
            [indexSet addIndex:idx];
            [indexSet addIndex:idx+1];
        }
        
    }];
    [arrayData removeObjectsAtIndexes:indexSet];
}


-(AFHTTPRequestOperationManager*)AFHROM{
    if (!AFHROM) {
        AFHROM=[AFHTTPRequestOperationManager manager];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
        AFHROM.responseSerializer.stringEncoding=enc;
        AFHROM.requestSerializer.stringEncoding = enc;
        AFHROM.responseSerializer=[AFHTTPResponseSerializer serializer];
        AFHROM.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return AFHROM;
}
@end
