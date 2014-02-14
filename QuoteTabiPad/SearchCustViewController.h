//
//  SearchCustViewController.h
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 10/27/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCustViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchCustomer;
@property (weak, nonatomic) IBOutlet UITableView *tblCustSearch;
@property (strong, nonatomic) id quoteItem;
@property (strong, nonatomic) id branchNum;
@property (strong, nonatomic) id IndAg; //mw 10-31-2013

@end
