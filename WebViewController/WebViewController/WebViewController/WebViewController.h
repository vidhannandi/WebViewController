//
//  WebViewController.h
//  WebViewController
//
//  Created by Vidhan Nandi on 26/04/16.
//  Copyright © 2016 VNTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
+ (id)getWebViewWithUrlString:(NSString *)urlString;
@property (nonatomic, weak) NSString *urlString;
@end
