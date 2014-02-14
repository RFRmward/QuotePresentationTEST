//
//  SearchCustViewController.m
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 10/27/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "SearchCustViewController.h"
#import "CanGoThere.h"


NSString *customersearchURL = @"http://customer.rainforrent.com/QuotePresentationPortalWCF/QuotePresentationPortal.svc/getApprovedQuotesByCustName";
//@"http://customer.rainforrent.com/QuotePresentationPortalWCF/QuotePresentationPortal.svc/getApprovedQuotesByCustName?guid=d5d0cd1a-b172-443a-a726-df3f98af6a41&ProgType=";mrv
NSString *IndAgSwth=nil;
NSString *encodedcustname=nil; //mw 10-31-2013
NSDictionary *userSettings;


@interface SearchCustViewController (){
    NSMutableArray *_quoteList;
    NSMutableArray *_custList;
    NSString *quoteSelect;
}

@end

@implementation SearchCustViewController
@synthesize searchCustomer;
@synthesize tblCustSearch;

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

    self.navigationItem.title =@"Customer Name Search";
    IndAgSwth=@"Ind";
    searchCustomer.keyboardType=UIKeyboardTypeAlphabet;
    _custList = [[NSMutableArray alloc] initWithObjects:@"Search By Customer Name", nil];
    _quoteList = [[NSMutableArray alloc] initWithObjects:@"QuoteNum", nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [searchCustomer becomeFirstResponder];
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
    return cell;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        quoteSelect = _quoteList[indexPath.row];
        [self performSegueWithIdentifier:@"showCustResult" sender:self];
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
        IndAgSwth=@"Ind";
    }else {
        IndAgSwth=@"Ag";
    }
}


//static method used for encoding custname. //mw 10-31-2013
+ (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                       (__bridge CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
                                                                                       CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    if (newString)
    {
        return newString;
    }
    return @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSInteger selectedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    if (selectedScopeButtonIndex == 0)
    {
        NSString *sQuoteSearch = searchBar.text;
        if (sQuoteSearch.length < 2)
        {
            UIAlertView *alertA = [[UIAlertView alloc] initWithTitle:@"Search String"
                                                             message:@"Not enough letters to Search"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alertA show];
        }
        else {
            NSError *error = nil;
            encodedcustname = [SearchCustViewController encodeURL:sQuoteSearch];  //mw 10-31-2013
            
            
            
            NSString *tempURL;
            
            tempURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                       customersearchURL,
                       @"?guid=",
                       [userSettings objectForKey:@"guid"],
                       @"&ProgType=",
                       IndAgSwth,
                       @"&DivId=",
                       _branchNum,
                       @"&CustName=",
                       encodedcustname
                       ];
            
            
//            tempURL = [customersearchURL stringByAppendingString:IndAgSwth];
//            tempURL=[tempURL stringByAppendingString:@"&DivId="];
//            tempURL=[tempURL stringByAppendingString:_branchNum];
//            tempURL=[tempURL stringByAppendingString:@"&CustName="];
//            tempURL=[tempURL stringByAppendingString:encodedcustname];  //mw 10-31-2013
            
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
        if (sQuoteSearch.length < 2)
        {
            UIAlertView *alertB = [[UIAlertView alloc] initWithTitle:@"Search String"
                                                             message:@"Not enough letters to Search"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles: nil];
            [alertB show];
        }else {
            NSError *error = nil;
            encodedcustname = [SearchCustViewController encodeURL:sQuoteSearch];  //mw 11-4-2013
            

            NSString *tempURL;
            
            tempURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                       customersearchURL,
                       @"?guid=",
                       [userSettings objectForKey:@"guid"],
                       @"&ProgType=",
                       IndAgSwth,
                       @"&DivID=",
                       _branchNum,
                       @"&CustName=",
                       encodedcustname
                       ];
//            NSString *tempURL = [customersearchURL stringByAppendingString:IndAgSwth];
//            tempURL=[tempURL stringByAppendingString:@"&DivId="];
//            tempURL=[tempURL stringByAppendingString:_branchNum];
//            tempURL=[tempURL stringByAppendingString:@"&CustName="];
//            tempURL=[tempURL stringByAppendingString:encodedcustname];  //mw 11-4-2013
            
    
            
            
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showCustResult"]) {
        
        [[segue destinationViewController]  setQuoteItem:quoteSelect];
        [[segue destinationViewController]  setIndAg:IndAgSwth];  //mw 11-1-2013
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
