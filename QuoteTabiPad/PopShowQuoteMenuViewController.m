//
//  PopShowQuoteMenuViewController.m
//  QuotePresentation
//
//  Created by Ralph Whitten on 12/23/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "PopShowQuoteMenuViewController.h"


@interface PopShowQuoteMenuViewController ()
{
     NSMutableArray *_listMenu;
}

@end

@implementation PopShowQuoteMenuViewController
@synthesize sPassValue;
@synthesize delegate;
@synthesize tblMenu;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _listMenu = [[NSMutableArray alloc] init];
    [_listMenu addObject:@"Sign"];
    [_listMenu addObject:@"Submit"];
    [_listMenu addObject:@"Email"];
    [_listMenu addObject:@"Print"];
    [_listMenu addObject:@"Cancel"];
    self.contentSizeForViewInPopover = CGSizeMake(620, 240 + self.tblMenu.contentInset.top + self.tblMenu.contentSize.height + self.tblMenu.contentInset.bottom);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            switch (indexPath.row) {
                case 0:
                    [self SignaturePop];
                    break;
                case 1:
                    sPassValue = @"1";
                    [delegate dismissPop:sPassValue];
                    break;
                case 2:
                    
                    break;
                case 3:
                    
                    break;
                case 4:
                    
                    break;
                default:
                    break;
            }
}

- (void)SignaturePop {
    tblMenu.hidden =YES;
    
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
