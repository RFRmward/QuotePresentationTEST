//
//  PopIndAgViewController.h
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 10/9/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopIndAgDelegate;

@interface PopIndAgViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UISwitch *switchIndAg;
    IBOutlet UILabel *lblIndAg;
    IBOutlet UISlider *sliderStatus;
    IBOutlet UILabel *lblStatus;
    IBOutlet UITableView *tblMenu;
    IBOutlet UILabel *lblPickBrh;
    IBOutlet UIBarButtonItem *btnDays;
}
@property (nonatomic, retain) UISwitch *switchIndAg;
@property (nonatomic, retain) UILabel *lblIndAg;
@property (nonatomic, retain) UISlider *sliderStatus;
@property (nonatomic, retain) UILabel *lblStatus;
@property (nonatomic, retain) NSMutableArray *numSlide;
@property (nonatomic, retain) UITableView *tblMenu;
@property (nonatomic, retain) UILabel *lblPickBrh;
@property (strong, nonatomic) id menuItem; //?? may not need
@property (weak)id<PopIndAgDelegate> delegate;
@property (strong, nonatomic) NSString *sPassValue;
@property (strong, nonatomic) id quoteNum;
@property (strong, nonatomic) id userName;  //mw 11-4-2013
@property (strong, nonatomic) NSString *defaultBrh; //mw 10-31-2013
@property (strong, nonatomic) UIBarButtonItem *btnDays;


- (IBAction)toggleIndAgSwitch:(id)sender;
- (IBAction)sliderStatusChanged:(id)sender;
- (IBAction)selectDays:(id)sender;


@end

@protocol PopIndAgDelegate <NSObject>
@required
- (void)dismissPop:(NSString *)value;


@end

