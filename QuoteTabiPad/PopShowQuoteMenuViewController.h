//
//  PopShowQuoteMenuViewController.h
//  QuotePresentation
//
//  Created by Ralph Whitten on 12/23/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopShowQuoteMenuDelegate;


@interface PopShowQuoteMenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{

}
@property (nonatomic, retain) UITableView *tblMenu;
@property (weak)id<PopShowQuoteMenuDelegate> delegate;
@property (strong, nonatomic) NSString *sPassValue;

@end

@protocol PopShowQuoteMenuDelegate <NSObject>
@required
- (void)dismissPop:(NSString *)value;

@end

