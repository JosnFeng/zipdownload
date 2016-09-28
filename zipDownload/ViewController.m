//
//  ViewController.m
//  zipDownload
//
//  Created by fdd on 16/9/20.
//  Copyright © 2016年 fdd. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "ZipArchive.h"
#import "HYBNetworking.h"
#import "WebViewJavascriptBridge.h"
#import <CommonCrypto/CommonCrypto.h>
#import "FileHash.h"

@interface ViewController ()
@property (nonatomic, copy) NSString *savedPath;
@property (nonatomic, copy) NSString *unZipFile;

@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(10, 100, 40, 40);
    [btn addTarget:self action:@selector(loadBigGift) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
}
- (void)loadBigGift {
    
    NSString *savedPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/gift.zip"];
    NSString * unZipFile =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/h5plugin"];
    [HYBNetworking downloadWithUrl:@"http://h5plugin.bj.bcebos.com/9b04a8a63d793fb58ddd0f76e9433ff2.zip" saveToPath:savedPath progress:^(int64_t bytesRead, int64_t totalBytesRead) {
        NSLog(@"%lld", totalBytesRead);
    } success:^(id response) {
        NSLog(@"11111");
        
        
        NSFileManager *filemanager = [NSFileManager defaultManager];
        [filemanager createDirectoryAtPath:unZipFile withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *md5string = [FileHash md5HashOfFileAtPath:savedPath];
        
        if (![[self get_url_md5] isEqualToString:md5string]) {//不相等停止解压,文件下载可能出错
            return ;
        }
        
        ZipArchive *archive = [[ZipArchive alloc] init];
        BOOL is = [archive UnzipOpenFile:savedPath];
        if (is) {
            BOOL ret = [archive UnzipFileTo:unZipFile overWrite:YES];
            if (ret == NO) {
                
            }
            
            [archive UnzipCloseFile];
        }
    } failure:^(NSError *error) {
        NSLog(@"22222");
    }];
    
    
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(50, 50, 300, 400)];
    //    self.webView.alpha = 0.3;
    self.webView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.webView];
    
    NSString *htmlPath = [unZipFile stringByAppendingString:@"/starshow/index.html"];
    NSError *error;
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        
        
        NSLog(@"shi bai");
        
    }
    
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:[unZipFile stringByAppendingString:@"/starshow/"]]];
    //    [self.webView loadRequest:@""];
    
}
- (NSString *)get_url_md5 {//对比用的
    NSArray *arr = [@"http://h5plugin.bj.bcebos.com/9b04a8a63d793fb58ddd0f76e9433ff2.zip" componentsSeparatedByString:@"/"];
    NSString *str = [arr lastObject];
    NSArray *arrt = [str componentsSeparatedByString:@"."];
    NSString *strt = [arrt firstObject];
    return strt;
}
//
//- (NSString *) md5:(NSMutableString *)str
//{
//    if (str==nil) {
//        return nil;
//    }
//    const char *cStr = [str UTF8String];
//    unsigned char result[16];
//    CC_MD5( cStr, strlen(cStr), result );
//    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//            result[0], result[1], result[2], result[3],
//            result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11],
//            result[12], result[13], result[14], result[15]
//            ];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
