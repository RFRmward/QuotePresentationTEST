//
//  SignaturePageViewController.m
//  QuotePresentation
//
//  Created by Ralph Whitten on 1/4/14.
//  Copyright (c) 2014 Ralph Whitten. All rights reserved.
//

#import "SignaturePageViewController.h"

@interface SignaturePageViewController ()

@end

@implementation SignaturePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)setQuoteItem:(id)newQuoteItem
{
    if (_quoteItem != newQuoteItem) {
        _quoteItem = newQuoteItem;
        
    }
}

- (void)setFileName:(id)newFileName
{
    if (_fileName != newFileName) {
        _fileName = newFileName;
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSURL *url = [NSURL fileURLWithPath:_fileName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:request];
    [self webView].scalesPageToFit=YES;
    //[self.webView setFrame:CGRectMake(0, 0, 720, 916)];
    [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.webView setHidden:FALSE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
