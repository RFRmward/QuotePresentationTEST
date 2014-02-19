//
//  PopIndAgViewController.m
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 10/9/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "PopIndAgViewController.h"
#import "CanGoThere.h"


NSDictionary *userSettings;

@interface PopIndAgViewController (){
    NSMutableArray *_listMenu;
    NSMutableArray *_listCurrent;
    NSArray *arrMenu;
    NSString *sTableView;
    BOOL bReload;
    NSString *sIndAg;
    NSString *status;
    int iCurrCount;
    //BOOL bMulti;
}


@end

@implementation PopIndAgViewController

@synthesize switchIndAg;
@synthesize lblIndAg;
@synthesize sliderStatus;
@synthesize lblStatus;
@synthesize numSlide;
@synthesize tblMenu;
@synthesize lblPickBrh;
@synthesize sPassValue;
@synthesize delegate;
@synthesize btnDays;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    numSlide = [[NSMutableArray alloc] init];
    [numSlide addObject:[NSNumber numberWithInt:0]];
    [numSlide addObject:[NSNumber numberWithInt:1]];
    [numSlide addObject:[NSNumber numberWithInt:2]];
    [super viewDidLoad];
    userSettings = [CanGoThere getLogin];
    
    bReload=FALSE;
    arrMenu = @[@"Menu",@"Branch",@"Salesman",@"QuoteSearch",@"CustSearch"];
    sTableView=@"Menu";
    //[lblPickBrh setHidden:TRUE];
    lblIndAg.text=@"Industrial";
    sIndAg=@"Ind";
    switchIndAg.on = YES;
    [switchIndAg setHidden:FALSE];
    sliderStatus.continuous = YES;
    status=@"3";
    lblStatus.text = @"Active";
    [sliderStatus setMinimumValue:0];
    [sliderStatus setMaximumValue:((float)[numSlide count] -1)];
    sliderStatus.value=0;
    [sliderStatus setHidden:FALSE];
    _listMenu = [[NSMutableArray alloc] init];
    [_listMenu addObject:@"Search Branch Last 30 Days"];
    [_listMenu addObject:@"Search Salesman Last 30 Days"];
    [_listMenu addObject:@"Search by Quote Number"];
    [_listMenu addObject:@"Search by Customer Name"];
    [_listMenu addObject:@"Local Downloaded Quotes"];
    _listCurrent = [[NSMutableArray alloc] init];
    [_listCurrent addObject:@"PlaceHolder"];
}

- (IBAction)toggleIndAgSwitch:(id)sender {
    if ([sender isOn]) {
        lblIndAg.text=@"Industrial";
        sIndAg=@"Ind";
    }else {
        lblIndAg.text=@"Ag";
        sIndAg=@"Ag";
    }
}

- (IBAction)sliderStatusChanged:(id)sender {
    NSUInteger index = (NSUInteger)(sliderStatus.value + 0.5);
    [sliderStatus setValue:index animated:NO];
    
    if (index == 0) {
        lblStatus.text = @"Active";
        status=@"3";
    }
    if (index == 1) {
        lblStatus.text = @"Won";
        status=@"1";
    }
    if (index == 2) {
        lblStatus.text = @"Lost";
        status=@"2";
    }
}

- (IBAction)selectDays:(id)sender {
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Select Days" message:@" " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"7 Days",@"14 Days",@"30 Days",@"60 Days",nil];
    [alertview show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listMenu count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
    NSString *cellValue = [_listMenu objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int operator = [arrMenu indexOfObject:sTableView];
    
    switch (operator) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    btnDays.width = 0.1;//rw 11-21-2013
                    [self BranchPicker];
                    break;
                case 1:
                    btnDays.width = 0.1;
                    [self SalesmanPicker];
                    break;
                case 2:
                    [self QuoteSearch];
                    break;
                case 3:
                    [self CustSearch];
                    break;
                case 4:
                    [self LocalFiles];
                    break;
                default:
                    break;
            }
        case 1:
            if (bReload == FALSE) {
                NSString *brh =_listMenu[indexPath.row];
                if ([brh  isEqual: @"More . . ."]) {
                    [self viewMore];
                }
                else if ([brh  isEqual: @"Top . . ."])
                {
                    [self BranchPicker];
                }
                else{
                NSString *temp = @"1,";
                brh=[brh substringWithRange:NSMakeRange(7, 3)];
                sPassValue=[temp stringByAppendingString:brh];
                sPassValue=[sPassValue stringByAppendingString:@","];
                sPassValue=[sPassValue stringByAppendingString:sIndAg];
                sPassValue=[sPassValue stringByAppendingString:@","];
                sPassValue=[sPassValue stringByAppendingString:status];
                //NSLog(sPassValue);
                [delegate dismissPop:sPassValue];
                }
            }
            break;
        case 2:
            if (bReload == FALSE) {
                NSString *fullname =_listMenu[indexPath.row];  //mw 10-21-2013
                if ([fullname  isEqual: @"More . . ."]) {
                    [self viewMoreSalesman];
                }
                else if ([fullname isEqual: @"Top . . ."])
                {
                    [self SalesmanPicker];
                }
                else{
                NSString *temp = @"2,";  //mw 10-21-2013
                NSString *brh;  //mw 10-21-2013
                
                if (_quoteNum == nil)  //mw 11-4-2013
                {
                    brh = _defaultBrh;
                }
                else
                {
                    brh=[_quoteNum substringWithRange:NSMakeRange(3, 3)];  //mw 11-4-2013
                }
                sPassValue=[temp stringByAppendingString:brh];
                sPassValue=[sPassValue stringByAppendingString:@","];
                sPassValue=[sPassValue stringByAppendingString:sIndAg];
                sPassValue=[sPassValue stringByAppendingString:@","];
                sPassValue=[sPassValue stringByAppendingString:status];
                sPassValue=[sPassValue stringByAppendingString:@","];  //mw 10-21-2013
                sPassValue=[sPassValue stringByAppendingString:fullname];  //mw 10-21-2013
                //NSLog(sPassValue);
                [delegate dismissPop:sPassValue];
                }
            }
            break;
        case 3:
            if (bReload == FALSE) {
                NSString *temp = @"1,";
                NSString *brh =_listMenu[indexPath.row];
                brh=[brh substringWithRange:NSMakeRange(7, 3)];
                sPassValue=[temp stringByAppendingString:brh];
                //NSLog(sPassValue);
                [delegate dismissPop:sPassValue];
            }
            break;
        default:
            break;
    }
    bReload=FALSE;
}

- (void)BranchPicker {
    //[switchIndAg setHidden:TRUE];
    //[sliderStatus setHidden:TRUE];
    [_listMenu removeAllObjects];
    [_listCurrent removeAllObjects];
    lblPickBrh.text=@"Pick Branch";
    //get Branch list from WebService
    NSError *error = nil;
    NSString *userName = _userName; //@"rwhitten";  //mw 11-4-2013
    

    //NSString *tempURL = [branchListURL stringByAppendingString:userName];
   
    NSString *tempURL = [NSString stringWithFormat:@"%@%@%@%@%@",
                     branchListURL,
                     @"?guid=",
                     [userSettings objectForKey:@"guid"],
                     @"&UsrName=",
                     userName
                     ];
    
    
    NSURL *QuotesApproveURL = [NSURL URLWithString:tempURL];
    NSData *data = [NSData dataWithContentsOfURL:QuotesApproveURL
                                         options:NSDataReadingUncached
                                           error:&error];
    int iCount = 0;  //mw 11-4-2013
    if (!error) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];

        NSMutableArray *array = [json objectForKey:@"BranchList"];
        iCurrCount = 0;
        for (int i=0; i< array.count; i++){
            NSDictionary *branchInfo = [array objectAtIndex:i];
            NSString *branch = [branchInfo objectForKeyedSubscript:@"BranchNum"];
            if (i > 12) { //rw 11-21-2013
                [_listCurrent addObject:branch];
            }
            else {
                [_listMenu addObject:branch];
                [_listCurrent addObject:branch];
                
            }
            iCount = iCount + 1;
        }
    }
    iCurrCount = 13;
    if (_listMenu.count > 12) {[_listMenu addObject:@"More . . ."];}
    
    if (iCount==1)  //mw 11-4-2013 if user only has 1 branch bypass the branch selection.
    {
        NSString *sBrh = _defaultBrh;
        NSString *temp = @"1,";
        sPassValue=[temp stringByAppendingString:sBrh];
        sPassValue=[sPassValue stringByAppendingString:@","];
        sPassValue=[sPassValue stringByAppendingString:sIndAg];
        sPassValue=[sPassValue stringByAppendingString:@","];
        sPassValue=[sPassValue stringByAppendingString:status];
        [delegate dismissPop:sPassValue];
    }
    else
    {
        //[lblPickBrh setHidden:FALSE];
        bReload=TRUE;
        [tblMenu reloadData];
        //int PopoverHeight = 70 * iCount;  //mw 11-4-2013
        self.contentSizeForViewInPopover = CGSizeMake(620, 100 + self.tblMenu.contentInset.top + self.tblMenu.contentSize.height + self.tblMenu.contentInset.bottom);
        //self.contentSizeForViewInPopover = CGSizeMake(620, PopoverHeight);  //mw 11-4-2013
        //[self goToBottom];
        sTableView=@"Branch";
        //bReload=FALSE;
    }
}

-(void)viewMore //rw 11-21-2013
{
    int iCount = iCurrCount;
    iCurrCount =iCurrCount + 13;
    if (iCurrCount > _listCurrent.count) {
        iCurrCount = _listCurrent.count;
    }
    [_listMenu removeAllObjects];
    NSMutableArray *array = _listCurrent;
    for (int i=iCount; i< iCurrCount; i++){
        NSString *branch = [array objectAtIndex:i];

            [_listMenu addObject:branch];
        
        }
    if (_listMenu.count > 12) {[_listMenu addObject:@"More . . ."];}
    if (_listMenu.count < 12) {[_listMenu addObject:@"Top . . ."];}

    bReload=TRUE;
    [tblMenu reloadData];
    self.contentSizeForViewInPopover = CGSizeMake(620, 100 + self.tblMenu.contentInset.top + self.tblMenu.contentSize.height + self.tblMenu.contentInset.bottom);
    sTableView=@"Branch";
    
}

-(void)viewMoreSalesman //rw 11-21-2013
{
    int iCount = iCurrCount;
    iCurrCount =iCurrCount + 13;
    if (iCurrCount > _listCurrent.count) {
        iCurrCount = _listCurrent.count;
    }
    [_listMenu removeAllObjects];
    NSMutableArray *array = _listCurrent;
    for (int i=iCount; i< iCurrCount; i++){
        NSString *salesman = [array objectAtIndex:i];
        
        [_listMenu addObject:salesman];
        
    }
    if (_listMenu.count > 12) {[_listMenu addObject:@"More . . ."];}
    if (_listMenu.count < 12) {[_listMenu addObject:@"Top . . ."];}
    
    bReload=TRUE;
    [tblMenu reloadData];
    self.contentSizeForViewInPopover = CGSizeMake(620, 100 + self.tblMenu.contentInset.top + self.tblMenu.contentSize.height + self.tblMenu.contentInset.bottom);
    sTableView=@"Salesman";
    
}

-(void)goToBottom
{
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    [self.tblMenu scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(NSIndexPath *)lastIndexPath
{
    NSInteger lastSectionIndex = MAX(0, [self.tblMenu numberOfSections]-1);
    NSInteger lastRowIndex = MAX(0, [self.tblMenu numberOfRowsInSection:lastSectionIndex] -1);
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}

- (void)setQuoteNum:(id)newQuoteNum  //mw 10-21-2013
{
    if (_quoteNum != newQuoteNum) {
        _quoteNum = newQuoteNum;
        
    }
}

- (void)setUserName:(id)newUserName  //mw 10-28-2013
{
    if (_userName != newUserName) {
        _userName = newUserName;
        
    }
}

- (void)setDefaultBrh:(id)newDefaultBrh
{
    if (_defaultBrh != newDefaultBrh) {
        _defaultBrh = newDefaultBrh;
    }
}
- (void)SalesmanPicker {
    //[switchIndAg setHidden:TRUE];
    //[sliderStatus setHidden:TRUE];
    [_listMenu removeAllObjects];
    [_listCurrent removeAllObjects];
    lblPickBrh.text=@"Pick Salesman";
    //get Salesman list from WebService
    NSError *error = nil;
    NSString *DivId;
    
    if (_quoteNum == nil)
    {
        DivId = _defaultBrh;
    }
    else
    {
        DivId = [_quoteNum substringWithRange:NSMakeRange(3, 3)]; //@"099";  //mw 11-4-2013
        if (DivId == nil) {DivId = _defaultBrh;}
    }
    //NSString *DivId = [_quoteNum substringWithRange:NSMakeRange(3, 3)]; //@"099";  //mw 10-21-2013
    //if (DivId == nil) {DivId = @"000";}
    
    //NSString *tempURL = [salesmenListURL stringByAppendingString:DivId];
    
    NSString *tempURL = [NSString stringWithFormat:@"%@%@%@%@%@",
                         salesmenListURL,
                         @"?guid=",
                         [userSettings objectForKey:@"guid"],
                         @"&DivId=",
                         DivId
                         ];
    
    NSURL *QuotesApproveURL = [NSURL URLWithString:tempURL];
    NSData *data = [NSData dataWithContentsOfURL:QuotesApproveURL
                                         options:NSDataReadingUncached
                                           error:&error];
    int iCount = 0;  //mw 11-4-2013
    if (!error) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        
        NSMutableArray *array = [json objectForKey:@"SalesmenList"];
        //int iCount = 0;  //mw 11-4-2013
        for (int i=0; i< array.count; i++){
            NSDictionary *salesmenInfo = [array objectAtIndex:i];
            NSString *salesmen = [salesmenInfo objectForKeyedSubscript:@"FullName"];
            if (i > 12) { //rw 11-21-2013
                [_listCurrent addObject:salesmen];
            }
            else {
                [_listMenu addObject:salesmen];
                [_listCurrent addObject:salesmen];
                
            }
            iCount = iCount + 1;
        }
    }
    iCurrCount = 13;
    if (_listMenu.count > 12) {[_listMenu addObject:@"More . . ."];}
    //[lblPickBrh setHidden:FALSE];
    bReload=TRUE;
    [tblMenu reloadData];
    //int PopoverHeight = 50 * iCount; //mw 11-4-2013
    self.contentSizeForViewInPopover = CGSizeMake(620, 100 + self.tblMenu.contentInset.top + self.tblMenu.contentSize.height + self.tblMenu.contentInset.bottom);
    //self.contentSizeForViewInPopover = CGSizeMake(620, PopoverHeight);  //mw 11-4-2013
    sTableView=@"Salesman";
}

- (void)QuoteSearch {
    bReload=TRUE;
    sPassValue = @"3,000,Quote";
    [delegate dismissPop:sPassValue];
}

- (void)CustSearch {
    bReload=TRUE;
    sPassValue = @"4,000,Quote";
    [delegate dismissPop:sPassValue];
}

- (void)LocalFiles {
    bReload=TRUE;
    sPassValue=@"5,000,Quote";
    [delegate dismissPop:sPassValue];
}

- (void)setMenuItem:(id)newMenuItem
{
    if (_menuItem != newMenuItem) {
        _menuItem = newMenuItem;
        
    }
}

/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pushTest"]) {
        NSIndexPath *indexPath = [self.tblMenu indexPathForSelectedRow];
        NSString *quoteNum = _listMenu[indexPath.row];
        
        [[segue destinationViewController]  setMenuItem:quoteNum];
        
    }
    
}*/


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
