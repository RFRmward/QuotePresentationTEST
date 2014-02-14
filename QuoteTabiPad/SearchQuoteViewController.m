//
//  SearchQuoteViewController.m
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 10/26/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "SearchQuoteViewController.h"
#import "CanGoThere.h"

NSString *quotesearchURL = @"http://customer.rainforrent.com/QuotePresentationPortalWCF/QuotePresentationPortal.svc/getApprovedQuotesByQuoteNumber";
//@"http://customer.rainforrent.com/QuotePresentationPortalWCF/QuotePresentationPortal.svc/getApprovedQuotesByQuoteNumber?guid=d5d0cd1a-b172-443a-a726-df3f98af6a41&ProgType=";
NSString *IndAgSwitch=nil;
NSDictionary *userSettings;


@interface SearchQuoteViewController (){
    NSMutableArray *_quoteList;
    NSMutableArray *_custList;
    NSString *quoteSelect;
}

@end

@implementation SearchQuoteViewController
@synthesize searchQuote;
@synthesize tblSearch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)setBranchNum:(id) newbranchNum
{
    if (_branchNum != newbranchNum) {
        _branchNum = newbranchNum;
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userSettings = [CanGoThere getLogin];
    

    self.navigationItem.title =@"Quote Number Search";
    IndAgSwitch=@"Ind";
    NSString *sSearch;
    sSearch = @"10-";
    sSearch = [sSearch stringByAppendingString:_branchNum];
    sSearch = [sSearch stringByAppendingString:@"-"];
    searchQuote.text= sSearch;
    searchQuote.keyboardType=UIKeyboardTypeNumberPad;
    _custList = [[NSMutableArray alloc] initWithObjects:@"Search By Quote Number", nil];
    _quoteList = [[NSMutableArray alloc] initWithObjects:@"QuoteNum", nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [searchQuote becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_quoteList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *cellValue = [_custList objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        quoteSelect = _quoteList[indexPath.row];
        [self performSegueWithIdentifier:@"showQuoteResult" sender:self];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSInteger selectedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    if (selectedScopeButtonIndex == 0)
    {
        NSString *sQuoteSearch = searchBar.text;
        if (sQuoteSearch.length < 10)
        {
            UIAlertView *alertA = [[UIAlertView alloc] initWithTitle:@"Search String"
                                                             message:@"Not enough numbers to Search"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alertA show];
        }
        else {
            NSError *error = nil;

            NSString *tempURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                                 quotesearchURL,
                                 @"guid=",
                                 [userSettings objectForKey:@"guid"],
                                 @"&ProgType=",
                                 IndAgSwitch,
                                 @"&QtNum=",
                                 sQuoteSearch
                                 ];
            
            
//            NSString *tempURL = [quotesearchURL stringByAppendingString:IndAgSwitch];
//            tempURL=[tempURL stringByAppendingString:@"&QtNum="];
//            tempURL=[tempURL stringByAppendingString:sQuoteSearch];
            
            NSURL *QuoteSearchURL = [NSURL URLWithString:tempURL];
            NSData *data = [NSData dataWithContentsOfURL:QuoteSearchURL
                                                 options:NSDataReadingUncached
                                                   error:&error];
            if (!error) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
                
                NSMutableArray *array = [json objectForKey:@"ApprovedQuotes"];
                int iCount = 0;
                [_custList removeAllObjects];
                [_quoteList removeAllObjects];
                for (int i=0; i< array.count; i++){
                    NSDictionary *quoteInfo = [array objectAtIndex:i];
                    NSString *customer = [quoteInfo objectForKeyedSubscript:@"quotenum"];
                    customer =[customer stringByAppendingString:@" "];
                    customer =[customer stringByAppendingString:[quoteInfo objectForKeyedSubscript:@"custname"]];
                    customer =[customer stringByAppendingString:@" $"];
                    customer =[customer stringByAppendingString:[quoteInfo objectForKeyedSubscript:@"grandtotal"]];
                    customer =[customer stringByAppendingString:@" "];
                    customer =[customer stringByAppendingString:[quoteInfo objectForKeyedSubscript:@"status"]];
                    [_custList addObject:customer];
                    NSString *quote = [quoteInfo objectForKeyedSubscript:@"quotenum"];
                    [_quoteList addObject:quote];
                    iCount = iCount + 1;
                }
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        
    }
    if (selectedScopeButtonIndex == 1)
    {
        NSString *sQuoteSearch = searchBar.text;
        if (sQuoteSearch.length < 10)
        {
        UIAlertView *alertB = [[UIAlertView alloc] initWithTitle:@"Search String"
                                                         message:@"Not enough numbers to Search"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles: nil];
        [alertB show];
        }else {
            NSError *error = nil;
            
            NSString *tempURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                                 quotesearchURL,
                                 @"?guid=",
                                 [userSettings objectForKey:@"guid"],
                                 @"&ProgType=",
                                 IndAgSwitch,
                                 @"&QtNum=",
                                 sQuoteSearch
                                 ];
            
//            NSString *tempURL = [quotesearchURL stringByAppendingString:IndAgSwitch];
//            tempURL=[tempURL stringByAppendingString:@"&QtNum="];
//            tempURL=[tempURL stringByAppendingString:sQuoteSearch];
//            
            
            NSURL *QuoteSearchURL = [NSURL URLWithString:tempURL];
            NSData *data = [NSData dataWithContentsOfURL:QuoteSearchURL
                                                 options:NSDataReadingUncached
                                                   error:&error];
            if (!error) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
                
                NSMutableArray *array = [json objectForKey:@"ApprovedQuotes"];
                int iCount = 0;
                [_custList removeAllObjects];
                [_quoteList removeAllObjects];
                for (int i=0; i< array.count; i++){
                    NSDictionary *quoteInfo = [array objectAtIndex:i];
                    NSString *customer = [quoteInfo objectForKeyedSubscript:@"quotenum"];
                    customer =[customer stringByAppendingString:@" "];
                    customer =[customer stringByAppendingString:[quoteInfo objectForKeyedSubscript:@"custname"]];
                    customer =[customer stringByAppendingString:@" $"];
                    customer =[customer stringByAppendingString:[quoteInfo objectForKeyedSubscript:@"grandtotal"]];
                    customer =[customer stringByAppendingString:@" "];
                    customer =[customer stringByAppendingString:[quoteInfo objectForKeyedSubscript:@"status"]];
                    [_custList addObject:customer];
                    NSString *quote = [quoteInfo objectForKeyedSubscript:@"quotenum"];
                    [_quoteList addObject:quote];
                    iCount = iCount + 1;
                }
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if (searchBar.selectedScopeButtonIndex == 0) {
        IndAgSwitch=@"Ind";
    }else {
        IndAgSwitch=@"Ag";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuoteResult"]) {
        
        [[segue destinationViewController]  setQuoteItem:quoteSelect];
        [[segue destinationViewController]  setIndAg:IndAgSwitch];
    }
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
