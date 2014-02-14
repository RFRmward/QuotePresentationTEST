//
//  ShowQuoteViewController.h
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 6/22/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PopShowQuoteMenuViewController.h"

@class UIPrintInteractionController;

@interface ShowQuoteViewController : UIViewController <UIDocumentInteractionControllerDelegate,UIPopoverControllerDelegate, PopShowQuoteMenuDelegate>
{
    
    UIPrintInteractionController *printController;
    UIDocumentInteractionController *docController;
}

@property (strong, nonatomic) id quoteItem;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *lblLoading;
@property (strong, nonatomic) NSString *IndAg; //mw 10-31-2013
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnMenu;
@property (nonatomic, retain) NSString *pdfPath; //rw 12/3/2013
@property (strong, nonatomic) NSString *detailLine; //rv 12/19/2013
@property (strong, nonatomic) NSString *custName; //rv 12/19/2013
@property (strong, nonatomic) UIStoryboardPopoverSegue *popover; //rw 01/3/2014
@property (strong, nonatomic) PopShowQuoteMenuViewController *pvc; //rw 01/3/2014
@property (strong, nonatomic) id fileName;

- (IBAction)showMenu:(id)sender;

@end
