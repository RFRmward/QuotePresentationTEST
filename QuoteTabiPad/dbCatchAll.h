//
//  dbCatchAll.h
//  QuotePresentation
//
//  Created by M. Randall VandenHoek on 12/16/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dbCatchAll : NSObject

+(NSString *)dataFilePath;
+(void)configureDB;
+(void)insertNewQuoteTableItemForQuote:(NSString *)Quote
                            withDetail:(NSString *)detailStuff
                          withFileName:(NSString *)fileName
                               forCust:(NSString *)custName;
+(NSDictionary*)selectQuoteRecordByFileName:(NSString*)fileName;
+(NSDictionary*)selectQuoteRecordByQuoteNum:(NSString*)quoteNumber;
+(void)flagAsSigned:(NSString*)quoteNumber;
+(void)flagAsSubimtted:(NSString*)quoteNumber;
+(void)deleteRecordByQuoteNum:(NSString*)quote;


@end

