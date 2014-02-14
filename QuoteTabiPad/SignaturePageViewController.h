//
//  SignaturePageViewController.h
//  QuotePresentation
//
//  Created by Ralph Whitten on 1/4/14.
//  Copyright (c) 2014 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignaturePageViewController : UIViewController

@property (strong, nonatomic) id quoteItem;
@property (strong, nonatomic) id fileName;
@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end


