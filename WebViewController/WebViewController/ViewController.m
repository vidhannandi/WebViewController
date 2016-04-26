//
//  ViewController.m
//  WebViewController
//
//  Created by Vidhan Nandi on 26/04/16.
//  Copyright © 2016 VNTech. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Base View Controller";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showWebView:(id)sender {
    WebViewController *webView = [[WebViewController alloc] init];
    webView.urlString = @"https://www.apple.com";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webView];
    [self presentViewController:nav animated:true completion:nil];
}

@end
