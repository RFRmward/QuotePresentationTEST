//
//  CanGoThere.h
//  QuotesApprover
//
//  Created by M. Randall VandenHoek on 7/17/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <Foundation/Foundation.h>




typedef enum
{
    ReachableURL  = 1,
	NotReachable  = 2,
	NotValidLogin = 3	
} NetworkStatus;





@interface CanGoThere : NSObject


+(NSInteger)stopGap:(NSDictionary *)theCredentials;

+(NSDictionary *)getLogin;

+(BOOL)HasConnection:(NSDictionary *)theCredentials;


+ (void)clearTmpDirectory;


//NSString *formatTheCurrencyValue(double value); //, BOOL swSuppressZero);

+(NSString*)formatTheCurrencyValue:(double)value suppressZero:(BOOL)swSuppress;

//NSString *formatTheCurrencyValue(double value, BOOL swSuppress);


@end
