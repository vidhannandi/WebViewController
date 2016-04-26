//
//  WebViewController.m
//  WebViewController
//
//  Created by Vidhan Nandi on 26/04/16.
//  Copyright © 2016 VNTech. All rights reserved.
//

#import "WebViewController.h"
#define ReloadImage [UIImage imageNamed:@"Reload"]
#define StopImage [UIImage imageNamed:@"Stop"]
#define BackImage [UIImage imageNamed:@"Back"]
#define ForwardImage [UIImage imageNamed:@"Forward"]
#define GoogleString @"https://www.google.co.in/search?q="

@interface WebViewController ()<UIWebViewDelegate, UISearchBarDelegate, UIScrollViewDelegate>{
   
    // LocalVariables
    UIWebView *webView;
    UISearchBar *urlBar;
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
}

@end

@implementation WebViewController

#pragma mark - Life Cycle

- (void)loadView{
    [super loadView];
    [self setupView];
}
- (void)dealloc
{
    [webView stopLoading];
    webView = nil;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:true];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Additional Methods
- (void)setupView{
    [self setupToolBar];
    [self setupSearchBar];
    [self setupWebView];
    [self updateNavigationButtons];
    [self loadRequestWithString:self.urlString];
    [self.navigationController setHidesBarsOnSwipe:true];
}
- (void)setupWebView{
    webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [webView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [webView.scrollView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [webView setDelegate:self];
    [webView.scrollView setDelegate:self];
    [webView setScalesPageToFit:true];
    [webView setDataDetectorTypes:UIDataDetectorTypeAll];
    [webView setAllowsPictureInPictureMediaPlayback:true];
    [webView setClearsContextBeforeDrawing:true];
    [webView.scrollView setShowsHorizontalScrollIndicator:false];
    [webView.scrollView setShowsVerticalScrollIndicator:false];
    [self.view addSubview:webView];
}
- (void)setupSearchBar{
    urlBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), self.navigationController.navigationBar.frame.size.height)];
    [urlBar setSearchBarStyle:UISearchBarStyleMinimal];
    [urlBar setKeyboardType:UIKeyboardTypeURL];
    [urlBar setDelegate:self];
    [urlBar setShowsBookmarkButton:true];
    self.navigationItem.titleView = urlBar;
    UIBarButtonItem *barButtonItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}
- (void)setupToolBar{
    [self.navigationController setToolbarHidden:false];
    backButton = [[UIBarButtonItem alloc] initWithImage:BackImage style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 30;
    forwardButton = [[UIBarButtonItem alloc] initWithImage:ForwardImage style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction:)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
    [self setToolbarItems:@[backButton, fixedItem, forwardButton, flexibleItem,shareItem] animated:true];
}

- (void)updateNavigationButtons{
    if (webView.canGoBack) { // For Moving Back
        [backButton setEnabled:true];
    }else{
        [backButton setEnabled:false];
    }
    if (webView.canGoForward) { // For Moving Forward
        [forwardButton setEnabled:true];
    }else{
        [forwardButton setEnabled:false];
    }
}
- (void)loadRequestWithString:(NSString *)url{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
- (NSString *)checkUrlExists:(NSString *)url{
    if ([self validateUrl:url]) {
        return url;
    }else{
        return [NSString stringWithFormat:@"%@%@",GoogleString,[self  getUrlEncodedString:urlBar.text]];
    }
}
- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}
- (NSMutableString *)getUrlEncodedString:(NSString *)unencodedString {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[unencodedString UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || thisChar == '=' || thisChar == '&' || thisChar == ':' || thisChar == '/' || thisChar == '?' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
- (void)showAlertWithMessage:(NSString *)message{
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:@"Error!!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:true completion:nil];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2){
    if ([urlBar isFirstResponder]) {
        [urlBar resignFirstResponder];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([urlBar isFirstResponder]) {
        [urlBar resignFirstResponder];
    }
}

#pragma mark - SearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *url = searchBar.text;
    if (!([url containsString:@"http://"] || [url containsString:@"https://"])) {
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    url = [self checkUrlExists:url];
    [self loadRequestWithString:url];
    [searchBar resignFirstResponder];
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    if (webView.isLoading) {
        [webView stopLoading];
    }else{
        [webView reload];
    }
    [searchBar resignFirstResponder];
}
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
    [urlBar setText:request.URL.absoluteString];
    [self updateNavigationButtons];
    [urlBar setImage:StopImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    return true;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self updateNavigationButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self updateNavigationButtons];
    [urlBar setImage:ReloadImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self updateNavigationButtons];
    if (error.code < kCFURLErrorUnsupportedURL && error.code >= kCFURLErrorDataLengthExceedsMaximum ) {
        [self showAlertWithMessage:error.localizedDescription];
    }
    [urlBar setImage:ReloadImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
}
#pragma mark - ButtonActions
- (IBAction)backAction:(id)sender {
    [webView goBack];
}
- (IBAction)shareAction:(id)sender {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[urlBar.text] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}
- (IBAction)forwardAction:(id)sender {
    [webView goForward];
}
- (IBAction)closeAction:(id)sender {
        [self dismissViewControllerAnimated:true completion:nil];
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
