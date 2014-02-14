//
//  ApproveViewController.h
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 6/22/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopIndAgViewController.h"

@interface ApproveViewController : UITableViewController
<UIPopoverControllerDelegate, PopIndAgDelegate>

@property (strong, nonatomic) id quoteItem;
@property (strong, nonatomic) id userName;
@property (strong, nonatomic) UIStoryboardPopoverSegue *popover;
@property (strong, nonatomic) PopIndAgViewController *pvc;
@property (strong, nonatomic) id IndAg; //mw 10-31-2013

@end
