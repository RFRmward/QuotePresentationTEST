//
//  CanGoThere.m
//  QuotesApprover
//
//  Created by M. Randall VandenHoek on 7/17/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "CanGoThere.h"


@implementation CanGoThere








+(NSInteger)stopGap:(NSDictionary *)theCredentials
{
    //BOOL win = NO;
    NSInteger netStat = 0 ;
    
    
    //NSString *inTest = [theCredentials objectForKey:@"inTestMode"];

    NSString *UserID = [theCredentials objectForKey:@"UserID"];
    NSString *theGuid = [theCredentials objectForKey:@"guid"];

    NSString *sanityCheck; // = [sURLCheck stringByAppendingString:UserID];
    
    
    
    //if ([inTest isEqualToString:@"YES"] ) {
         sanityCheck = [NSString stringWithFormat:@"%@%@%@%@%@",
                                 sURLTestCheck,
                                 @"?guid=",
                                 theGuid,
                                 @"&usr=",
                                 UserID];
    
//    } else {
//     sanityCheck = [NSString stringWithFormat:@"%@%@%@%@%@",
//                                  sURLCheck,
//                                  @"?guid=",
//                                  theGuid,
//                                  @"&usr=",
//                                  UserID];
//    }
    
    NSURL *validCheckURL = [NSURL URLWithString:sanityCheck];
   
    NSError *error = nil;
    NSData *vData = [NSData dataWithContentsOfURL:validCheckURL
                                          options:NSDataReadingUncached
                                            error:&error];
    if(error)
    {
        UIAlertView *noEntry = [[UIAlertView alloc]
                                initWithTitle:@"Network error"
                                message:@"Could not connect"
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles: nil];
        [noEntry show];
        netStat = 2;
    } else {
        NSDictionary *dict1 = [NSJSONSerialization
                               JSONObjectWithData:vData
                               options:NSJSONReadingMutableContainers
                               error:&error];
//        if (error)//will not happen if passed above check
//        {
//            UIAlertView *noEntry = [[UIAlertView alloc]
//                                    initWithTitle:@"Error occured in user validation"
//                                    message:error.description
//                                    delegate:self
//                                    cancelButtonTitle:@"OK"
//                                    otherButtonTitles: nil];
//            [noEntry show];
//          netStat = 2;
//        } else {
            NSString *logResult =  [dict1 objectForKey:@"IsValidResult"];
            if ([logResult isEqualToString:@"True"])
            {
                
                netStat = 1;
              //win = YES;
            } else {
                UIAlertView *noEntry = [[UIAlertView alloc]
                                        initWithTitle:@"Error occured in user validation"
                                        message:error.description
                                        delegate:self
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles: nil];
                [noEntry show];
                netStat = 3;
            }
        }
//    }
    //return win;
    return netStat;
}




+(NSDictionary *)getLogin {
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"login.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    return dict;
}



+(BOOL)HasConnection:(NSDictionary *)theCredentials
{
    BOOL win = NO;
    NSString *UserID = [theCredentials objectForKey:@"UserID"];
    NSString *sanityCheck = [sURLCheck stringByAppendingString:UserID];
    NSURL *validCheckURL = [NSURL URLWithString:sanityCheck];
    NSError *error = nil;
    NSData *vData = [NSData dataWithContentsOfURL:validCheckURL
                                          options:NSDataReadingUncached
                                            error:&error];
    if (vData)
    {
        win = YES;
    } else {
        win = NO;
        UIAlertView *noEntry = [[UIAlertView alloc]
                                    initWithTitle:@"Network error"
                                       message:@"Could not connect"
                                    delegate:self
                                       cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
            [noEntry show];
        
    }
    return win;
}




+ (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}


//NSString *formatTheCurrencyValue(double value) //, BOOL swSuppressZero)

+(NSString *)formatTheCurrencyValue:(double)value suppressZero:(BOOL)swSuppress
//NSString *formatTheCurrencyValue(double value, BOOL swSuppress)
{
    if (value == 0){
       if (swSuppress)
            return [[NSString alloc] init];
        else
            return @"$0.00";  //[[NSString alloc] initWithString:@"$0.00"];
    }
    else
    {
        NSNumberFormatter *mater = [[NSNumberFormatter alloc] init];
        [mater setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [mater setCurrencySymbol: @"$"];
        [mater setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSNumber *c = [NSNumber numberWithFloat:value];
        return [mater stringFromNumber:c];
    }
}





@end
