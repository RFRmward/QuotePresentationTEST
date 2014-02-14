//
//  SearchQuoteViewController.h
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 10/26/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchQuoteViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) id quoteItem;
@property (weak, nonatomic) IBOutlet UISearchBar *searchQuote;
@property (weak, nonatomic) IBOutlet UITableView *tblSearch;
@property (strong, nonatomic) id branchNum;
@property (strong, nonatomic) id IndAg; //mw 10-31-2013

@end
