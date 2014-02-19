//
//  ApproveViewController.m
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 6/22/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

#import "ApproveViewController.h"
#import "ShowQuoteViewController.h"
#import "dbCatchAll.h"
#import "CanGoThere.h"


NSString *branch =nil;
NSString *IndAg=nil;
NSString *status=nil;
NSString *defaultBrh=nil; //mw 10-31-2013
NSString *querytype=nil;  //mw 10-21-2013
NSString *fullname=nil;  //mw 10-21-2013
NSString *encodedfullname=nil;  //mw 10-22-2013
//NSString *quotenum=nil;  //mw 10-23-2013
NSString *tempURL;  //mw 10-21-2013




@interface ApproveViewController (){
    NSMutableArray *_listOfBranches; //mw 10-31-2013
    NSMutableArray *_listCustomers;
    NSMutableArray *_listQuotes;
    NSMutableArray *_listOfQuotes;
    BOOL bConnect;
}


@end

@implementation ApproveViewController

@synthesize popover;
@synthesize pvc;

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

- (void)setUserID:(id)newUserID
{
    if (_userName != newUserID) {
        _userName = newUserID;
        
    }
}

- (void)setBranchNum:(id)newBranchNum
{
    if (branch != newBranchNum) {
        branch = newBranchNum;
        
    }
}

- (void)viewDidLoad
{
    userSettings = [CanGoThere getLogin];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Approved Quotes %@", [formatter stringFromDate:[NSDate date]]];
    self.navigationItem.title = NSLocalizedString(lastUpdated, lastUpdated);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [super viewDidLoad];
    IndAg=@"Ind";
    status=@"3";
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    //Get the branch list here and set the first branch as default. //mw 10-31-2013
    //get Branch list from WebService
    NSError *error = nil;
    NSString *userName = _userName; //@"rwhitten";
    
    NSString *tempURL = [NSString stringWithFormat:@"%@%@%@%@%@",
                         getbranchListURL,
                         @"?guid=",
                         [userSettings objectForKey:@"guid"],
                         @"&UsrName=",
                         userName
                         ];
    
    //[getbranchListURL stringByAppendingString:userName];
    
    
    NSURL *QuotesApproveURL = [NSURL URLWithString:tempURL];
    NSData *data = [NSData dataWithContentsOfURL:QuotesApproveURL
                                         options:NSDataReadingUncached
                                           error:&error];
    if (!error) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        
        NSMutableArray *array = [json objectForKey:@"BranchList"];
        int iCount = 0;
        for (int i=0; i< array.count; i++){
            NSDictionary *branchInfo = [array objectAtIndex:i];
            NSString *branch = [branchInfo objectForKeyedSubscript:@"BranchNum"];
            [_listOfBranches addObject:branch];
            if(defaultBrh == nil)  //mw 10-31-2013
            {
                defaultBrh = [branch substringWithRange:NSMakeRange(7, 3)];
            }
            iCount = iCount + 1;
        }
    }
    

    [self configureView];
   }

-(void)handleBack:(id)sender
{
    NSString *outMessage =@"Will Require RFR Network Login";
    UIAlertView *alertA = [[UIAlertView alloc] initWithTitle:@"Change login info?"
                                                     message:outMessage
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Logout", nil];
    [alertA show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:@"Logout"])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

//static method used for encoding user fullname.
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

- (void)configureView
{
    NSError *error = nil;
    if(branch == nil){
        branch = defaultBrh; //@"017"; //mw 10-31-2013
        if (defaultBrh == nil) {
            branch = @"017";
        }
    }
    if(querytype == nil){
        querytype = @"1";
    }
    if ([querytype isEqual: @"1"])  //mw 10-21-2013
    {
        
    tempURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
               branchURL,
               @"?guid=",
               [userSettings objectForKey:@"guid"],
               @"&ProgType=",
               IndAg,
               @"&Status=",
               status,
               @"&DivId=",
               branch];
//        tempURL = [branchURL stringByAppendingString:IndAg];
//        tempURL = [tempURL stringByAppendingString:@"&Status="];
//        tempURL = [tempURL stringByAppendingString:status];
//        tempURL = [tempURL stringByAppendingString:@"&DivId="];
//        tempURL = [tempURL stringByAppendingString:branch];
    }
    if ([querytype isEqual: @"2"])  //mw 10-21-2013
    {
        encodedfullname = [ApproveViewController encodeURL: fullname];
        tempURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                   salesmanURL,
                   @"?guid=",
                   [userSettings objectForKey:@"guid"],
                   @"&ProgType=",
                   IndAg,
                   @"&Status=",
                   status,
                   @"&FuleName=",
                   encodedfullname
                   ];
//        tempURL = [salesmanURL stringByAppendingString:IndAg];
//        tempURL = [tempURL stringByAppendingString:@"&Status="];
//        tempURL = [tempURL stringByAppendingString:status];
//        tempURL = [tempURL stringByAppendingString:@"&FullName="];
//        tempURL = [tempURL stringByAppendingString:encodedfullname];
    }
    
    NSURL *QuotesApproveURL = [NSURL URLWithString:tempURL];
    NSData *data = [NSData dataWithContentsOfURL:QuotesApproveURL
                                         options:NSDataReadingUncached
                                           error:&error];
    
    
    _listCustomers = [[NSMutableArray alloc] init];
    _listQuotes = [[NSMutableArray alloc] init];
    _listOfQuotes = [[NSMutableArray alloc] init];

    if(error) {
        UIAlertView *cantConn = [[UIAlertView alloc] initWithTitle:@"Connection Unavailable" message:@"Local Files Only" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [cantConn show];
        bConnect=FALSE;
    }
    if (!error) {
        bConnect=TRUE;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        
        NSMutableArray *array = [json objectForKey:@"ApprovedQuotes"];
        int iCount = 0;
        
        for (int i=0; i< array.count; i++){
            NSDictionary *custInfo = [array objectAtIndex:i];
            NSDictionary *quoteInfo = [array objectAtIndex:i];
            
            NSString *entry = [quoteInfo objectForKeyedSubscript:@"custname"];
            [_listQuotes addObject:entry];
            NSString *cust = [custInfo objectForKeyedSubscript:@"quotenum"];
            cust = [cust stringByAppendingString:@"   $"];
            NSString *total = [custInfo objectForKey:@"grandtotal"];
            cust = [cust stringByAppendingString:total];
            cust = [cust stringByAppendingString:@"   "];  //mw 11-4-2013
            NSString *status = [custInfo objectForKey:@"status"];  //mw 11-4-2013
            cust = [cust stringByAppendingString:status];  //mw 11-4-2013
            
            [_listCustomers addObject:cust];
            NSString *quote = [custInfo objectForKeyedSubscript:@"quotenum"];
            [_listOfQuotes addObject:quote];
            iCount = iCount + 1;
            
        }
        if ([querytype isEqual: @"1"])  //mw 10-22-2013
        {
            NSString *iCountStr=[NSString stringWithFormat:@"%d",iCount];
            NSString *stringNum = @"Branch ";
            stringNum = [stringNum stringByAppendingPathComponent:branch];
            stringNum = [stringNum stringByAppendingPathComponent:@" - "];
            stringNum = [stringNum stringByAppendingPathComponent:iCountStr];
            if ([status isEqual: @"1"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Won "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"2"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Lost "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"3"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Active "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes"];}
            stringNum = [stringNum stringByReplacingOccurrencesOfString:@"/" withString:@""];
            self.navigationItem.prompt = stringNum;
        }
        if ([querytype isEqual: @"2"])  //mw 10-22-2013
        {
            NSString *iCountStr = [NSString stringWithFormat:@"%d", iCount];
            NSString *stringNum=fullname;
            stringNum = [stringNum stringByAppendingPathComponent:@" - "];
            stringNum = [stringNum stringByAppendingPathComponent:iCountStr];
            if ([status isEqual: @"1"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Won "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"2"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Lost "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"3"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Active "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes"];}
            stringNum = [stringNum stringByReplacingOccurrencesOfString:@"/" withString:@""];
            self.navigationItem.prompt = stringNum;
        }
    }
    else //unconnected file list
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSError *errorConnect;
        NSArray *directoryContents = [[[NSArray alloc] init] autoContentAccessingProxy];
        directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&errorConnect];
        //NSLog(@"directoryContents ====== %@",directoryContents);
        int iCount = 0;
        for (int i=0; i< directoryContents.count; i++){
            NSString *fileN = [directoryContents objectAtIndex:i];
            NSString *beginN = [fileN substringToIndex:6];
            if ([beginN isEqualToString:@"Quote_"]) {
                //rv 12/19/2013
                NSDictionary *unConnected = [dbCatchAll selectQuoteRecordByFileName:fileN];
                [_listQuotes addObject:[unConnected objectForKey:@"custName"]];
                [_listCustomers addObject:[unConnected objectForKey:@"cellDetail"]];
                [_listOfQuotes addObject:[unConnected objectForKey:@"quoteNumber"]];
                /*NSString *entry = fileN;
                [_listQuotes addObject:entry];
                NSString *quoteNum = [fileN substringWithRange:NSMakeRange(6, fileN.length -10)];
                
                NSString *cust = quoteNum;
                cust = [cust stringByAppendingString:@""];
                NSString *total = @"";
                cust = [cust stringByAppendingString:total];
                [_listCustomers addObject:cust];
                NSString *quote = quoteNum;
                [_listOfQuotes addObject:quote];*/
                iCount = iCount + 1;
            }
        }
        NSString *stringNum=[NSString stringWithFormat:@"%d",iCount];
        stringNum = [stringNum stringByAppendingPathComponent:@" Local Quotes"];
        stringNum = [stringNum stringByReplacingOccurrencesOfString:@"/" withString:@""];
        self.navigationItem.prompt = stringNum;
    }
}

-(void)refreshView: (UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    NSError *error = nil;
    if(branch == nil){
        branch = defaultBrh; //@"017"; //mw 10-31-2013
    }
    if(querytype == nil){
        querytype = @"1";
    }
    if ([querytype isEqual: @"1"])  //mw 10-21-2013
    {
        tempURL = [branchURL stringByAppendingString:IndAg];
        tempURL = [tempURL stringByAppendingString:@"&Status="];
        tempURL = [tempURL stringByAppendingString:status];
        tempURL = [tempURL stringByAppendingString:@"&DivId="];
        tempURL = [tempURL stringByAppendingString:branch];
    }
    if ([querytype isEqual: @"2"])  //mw 10-21-2013
    {
        encodedfullname = [ApproveViewController encodeURL: fullname];
        tempURL = [salesmanURL stringByAppendingString:IndAg];
        tempURL = [tempURL stringByAppendingString:@"&Status="];
        tempURL = [tempURL stringByAppendingString:status];
        tempURL = [tempURL stringByAppendingString:@"&FullName="];
        tempURL = [tempURL stringByAppendingString:encodedfullname];
    }
   
    NSURL *QuotesApproveURL = [NSURL URLWithString:tempURL];
    NSData *data = [NSData dataWithContentsOfURL:QuotesApproveURL
                                         options:NSDataReadingUncached
                                           error:&error];
    
    _listCustomers = [[NSMutableArray alloc] init];
    _listQuotes = [[NSMutableArray alloc] init];
    _listOfQuotes = [[NSMutableArray alloc] init];
    
    if(!error) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        
        NSMutableArray *array = [json objectForKey:@"ApprovedQuotes"];
        int iCount = 0;
        
        for (int i=0; i< array.count; i++){
            NSDictionary *custInfo = [array objectAtIndex:i];
            NSDictionary *quoteInfo = [array objectAtIndex:i];
            
            //NSString *status = [quoteInfo objectForKeyedSubscript:@"status"];
            //NSLog(status);
            //if ([status isEqualToString:@"Active"])
            //{
            NSString *entry = [quoteInfo objectForKeyedSubscript:@"custname"];
            [_listQuotes addObject:entry];
            NSString *cust = [custInfo objectForKeyedSubscript:@"quotenum"];
            cust = [cust stringByAppendingString:@"   $"];
            NSString *total = [custInfo objectForKey:@"grandtotal"];
            cust = [cust stringByAppendingString:total];
            cust = [cust stringByAppendingString:@"   "];  //mw 11-4-2013
            NSString *status = [custInfo objectForKey:@"status"];  //mw 11-4-2013
            cust = [cust stringByAppendingString:status];  //mw 11-4-2013
            
            [_listCustomers addObject:cust];
            NSString *quote = [custInfo objectForKeyedSubscript:@"quotenum"];
            [_listOfQuotes addObject:quote];
            iCount = iCount + 1;
            //}
        }
        
        if ([querytype isEqual: @"1"])  //mw 10-22-2013
        {
            NSString *iCountStr=[NSString stringWithFormat:@"%d",iCount];
            NSString *stringNum = @"Branch ";
            stringNum = [stringNum stringByAppendingPathComponent:branch];
            stringNum = [stringNum stringByAppendingPathComponent:@" - "];
            stringNum = [stringNum stringByAppendingPathComponent:iCountStr];
            if ([status isEqual: @"1"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Won "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"2"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Lost "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"3"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Active "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes"];}
            stringNum = [stringNum stringByReplacingOccurrencesOfString:@"/" withString:@""];
            self.navigationItem.prompt = stringNum;
        }
        if ([querytype isEqual: @"2"])  //mw 10-22-2013
        {
            NSString *iCountStr = [NSString stringWithFormat:@"%d", iCount];
            NSString *stringNum=fullname;
            stringNum = [stringNum stringByAppendingPathComponent:@" - "];
            stringNum = [stringNum stringByAppendingPathComponent:iCountStr];
            if ([status isEqual: @"1"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Won "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"2"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Lost "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes (Last 30 Days)"];}
            if ([status isEqual: @"3"])
            {stringNum = [stringNum stringByAppendingPathComponent:@" Active "];
                stringNum = [stringNum stringByAppendingPathComponent:IndAg];
                stringNum = [stringNum stringByAppendingPathComponent:@" Quotes"];}
            stringNum = [stringNum stringByReplacingOccurrencesOfString:@"/" withString:@""];
            self.navigationItem.prompt = stringNum;
        }
    }
    [self.tableView reloadData];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
    NSString *titleUpdated = [NSString stringWithFormat:@"Approved Quotes %@", [formatter stringFromDate:[NSDate date]]];
    self.navigationItem.title = NSLocalizedString(titleUpdated, titleUpdated);
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
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
    return [_listQuotes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [_listQuotes objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_listCustomers objectAtIndex:indexPath.row];
    
    NSString *fileName = [@"Quote_" stringByAppendingString:_listOfQuotes[indexPath.row]];
    fileName = [fileName stringByAppendingString:@".pdf"];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* findFile = [documentsPath stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:findFile];
    //if (fileExists == YES) {
        //cell.imageView.image = [UIImage imageNamed:@"Acroread.png"];
    //}
    fileExists = NO;
    //cell.imageView.image = [UIImage imageNamed:@"Acroread.png"];
    return cell;
}

- (void)dismissPop:(NSString *)value {
    
    //NSString *sSearch;
    NSArray *arrReturn = [value componentsSeparatedByString:@","];
    int iMenuReturn = [[arrReturn objectAtIndex:0] intValue];
    switch (iMenuReturn) {
        case 1:
            querytype = @"1"; //mw 10-21-2013
            branch = [arrReturn objectAtIndex:1];
            IndAg = [arrReturn objectAtIndex:2];
            status = [arrReturn objectAtIndex:3];
            [[popover popoverController] dismissPopoverAnimated:YES];
            [self configureView];
            [self.tableView reloadData];
            break;
        case 2:
            querytype = @"2";
            branch = [arrReturn objectAtIndex:1]; //mw 10-21-2013
            IndAg = [arrReturn objectAtIndex:2]; //mw 10-21-2013
            status = [arrReturn objectAtIndex:3]; //mw 10-21-2013
            fullname = [arrReturn objectAtIndex:4]; //mw 10-21-2013
            [[popover popoverController] dismissPopoverAnimated:YES]; //mw 10-21-2013
            [self configureView]; //mw 10-21-2013
            [self.tableView reloadData]; //mw 10-21-2013
            break;
        case 3:
            //querytype = @"3";
            [[popover popoverController] dismissPopoverAnimated:YES];
            [self toSearch:0];
            break;
        case 4:
            //querytype = @"4";
            [[popover popoverController] dismissPopoverAnimated:YES];
            [self toCustSearch:0];
            break;
        case 5:
            [[popover popoverController] dismissPopoverAnimated:YES];
            [self LocalFiles];
            //[self.tableView setEditing:YES animated:YES];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    
}

-(void)toSearch:(id) sender {
    [self performSegueWithIdentifier:@"showSearch" sender:sender];
}

-(void)toCustSearch:(id) sender {
    [self performSegueWithIdentifier:@"showCustSearch" sender:sender];
}

-(void)LocalFiles {
    [_listCustomers removeAllObjects];
    [_listQuotes removeAllObjects];
    [_listOfQuotes removeAllObjects];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *errorConnect;
    NSArray *directoryContents = [[[NSArray alloc] init] autoContentAccessingProxy];
    directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&errorConnect];
    //NSLog(@"directoryContents ====== %@",directoryContents);
    int iCount = 0;
    for (int i=0; i< directoryContents.count; i++){
        NSString *fileN = [directoryContents objectAtIndex:i];
        NSString *beginN = [fileN substringToIndex:6];
        if ([beginN isEqualToString:@"Quote_"]) {
            NSDictionary *unConnected = [dbCatchAll selectQuoteRecordByFileName:fileN];
            [_listQuotes addObject:[unConnected objectForKey:@"custName"]];
            [_listCustomers addObject:[unConnected objectForKey:@"cellDetail"]];
            [_listOfQuotes addObject:[unConnected objectForKey:@"quoteNumber"]];
            /*NSString *entry = fileN;
            [_listQuotes addObject:entry];
            NSString *quoteNum = [fileN substringWithRange:NSMakeRange(6, fileN.length -10)];
            
            NSString *cust = quoteNum;
            cust = [cust stringByAppendingString:@""];
            NSString *total = @"";
            cust = [cust stringByAppendingString:total];
            [_listCustomers addObject:cust];
            NSString *quote = quoteNum;
            [_listOfQuotes addObject:quote];*/
            iCount = iCount + 1;
        }
    }
    NSString *stringNum=[NSString stringWithFormat:@"%d",iCount];
    stringNum = [stringNum stringByAppendingPathComponent:@" Local Quotes"];
    stringNum = [stringNum stringByReplacingOccurrencesOfString:@"/" withString:@""];
    self.navigationItem.prompt = stringNum;
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuote"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *quoteNum = _listOfQuotes[indexPath.row];
        NSString *custName = [_listQuotes objectAtIndex:indexPath.row];
        
        NSString *quoteDetails = [_listCustomers objectAtIndex:indexPath.row];
        [[segue destinationViewController]  setQuoteItem:quoteNum];
        [[segue destinationViewController] setIndAg:IndAg]; //mw 10-31-2013
        [[segue destinationViewController] setDetailLine:quoteDetails];
        [[segue destinationViewController] setCustName:custName];
    }
    if ([[segue identifier] isEqualToString:@"showSearch"]) {
        [[segue destinationViewController]  setBranchNum:branch];
    }
    if ([[segue identifier] isEqualToString:@"showCustSearch"]) {
        [[segue destinationViewController]  setBranchNum:branch];
    }
    if ([[segue identifier] isEqualToString:@"showMenu"]) {
        if (bConnect)
        {
            popover = (UIStoryboardPopoverSegue *)segue;
            pvc = [segue destinationViewController];
            [pvc setDelegate:self];
            
            [[segue destinationViewController]  setUserName:_userName];  //mw 14-4-2013
            [[segue destinationViewController] setDefaultBrh:defaultBrh];  //mw 10-21-2013
            
            if (_listOfQuotes.count != 0)
            {
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];  //mw 10-21-2013
                NSString *quoteNum = _listOfQuotes[indexPath.row];  //mw 10-21-2013
                [[segue destinationViewController]  setQuoteNum:quoteNum];  //mw 10-21-2013
            }
        }
        else {
            UIAlertView *cantConn = [[UIAlertView alloc] initWithTitle:@"Connection Unavailable" message:@"Local Files Only" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [cantConn show];
        }
    }
}

@end
