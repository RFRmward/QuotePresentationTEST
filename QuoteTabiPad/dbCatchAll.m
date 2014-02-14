//
//  dbCatchAll.m
//  QuotePresentation
//
//  Created by M. Randall VandenHoek on 12/16/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "dbCatchAll.h"
#import <sqlite3.h>


@implementation dbCatchAll


+(NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
}



+(NSString *)columnList
{
    NSString *list = @"rowID, fileName, quoteNumber, custName, cellDetail, downloadDate, "
    "signedDate, submittedDate, signed, submitted, deleted, versionNumber ";
    return list;
    // 0 rowID
    // 1 fileName
    // 2 quoteNumber
    // 3 custName
    // 4 cellDetail
    // 5 downloadDate
    // 6 signedDate
    // 7 submittedDate
    // 8 signed
    // 9 submitted
    // 10 deleted
    // 11 versionNumber
}



+(void)configureDB
{
    sqlite3 *database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String ], &database) != SQLITE_OK){
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS QuoteTable "
    "(rowID INTEGER PRIMARY KEY NOT NULL,  fileName TEXT, quoteNumber TEXT, "
    "custName TEXT, cellDetail TEXT, downloadDate TEXT,  signedDate TEXT, submittedDate TEXT, "
    "submitted INTEGER, signed INTEGER ,  deleted INTEGER, versionNumber TEXT) ";
    
    char *errorMsg;
    if (sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert (0, @"Error creating quote table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS EMAILHIST "
    "(rowID INTEGETR PRIMARY KEY NOT NULL, dateSent TEXT, quoteID INTEGER, versionSent TEXT, whereSent TEXT)";
    
    if (sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        
        NSAssert(0, @"Error creating hist table: %s", errorMsg);
    }
}



+(void)insertNewQuoteTableItemForQuote:(NSString *)Quote
                            withDetail:(NSString *)detailStuff
                          withFileName:(NSString *)fileName
                               forCust:(NSString *)custName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    sqlite3 *database;
    
    if (sqlite3_open([[dbCatchAll dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"1: Failed to open database");
    }
    
    char *insertStmt = "INSERT INTO QuoteTable "
    "(quoteNumber, fileName, cellDetail, custName, downloadDate, deleted, signed, submitted) "
    "VALUES (?, ?, ?, ?, ?, 0, 0, 0);";
    
    //char *errorMsg = NULL;
    
    sqlite3_stmt *stmt;
    
    if (sqlite3_prepare_v2(database, insertStmt, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text (stmt, 1, [Quote UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [fileName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [detailStuff UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [custName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [[formatter stringFromDate:[NSDate date]] UTF8String], -1, NULL);
        
        if (sqlite3_step(stmt) != SQLITE_DONE)
            NSAssert (0, @"5: Error updating table: %s", sqlite3_errmsg(database));
    }
    
    sqlite3_close(database);
    
}


+(NSDictionary*)selectQuoteRecordByFileName:(NSString*)fileName
{
    NSDictionary *dict;
    NSString *stmt = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                      @" SELECT  ",
                      [self columnList],
                      @" FROM QuoteTable ",
                      @" WHERE fileName = '",
                      fileName,
                      @"' AND deleted = 0"];
    
    dict = [self databaseQuery:stmt];
    return dict;
}



+(NSDictionary*)selectQuoteRecordByQuoteNum:(NSString*)quoteNumber
{
    NSDictionary *dict;
    NSString *stmt = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                      @" SELECT  ",
                      [self columnList],
                      @" FROM QuoteTable ",
                      @" WHERE quoteNumber = '",
                      quoteNumber,
                      @"' AND deleted = 0"];
    
    dict = [self databaseQuery:stmt];
    return dict;
}


//dictionary for query returning one record
+(NSDictionary *)databaseQuery:(NSString *)stmt
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"2: Failed to open database");
    }
    sqlite3_stmt *selectStatement;
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    if (sqlite3_prepare_v2(database, [stmt UTF8String], -1, &selectStatement, nil) == SQLITE_OK)
    {
        
        if (sqlite3_step(selectStatement) == SQLITE_ROW)
        {
            char *crowID = (char *)sqlite3_column_text(selectStatement , 0);
            NSString *srowID = [[NSString alloc] initWithUTF8String:crowID];
            
            char *cfileName = (char *)sqlite3_column_text(selectStatement, 1);
            NSString *sfileName;
            if (cfileName == nil)
                sfileName = @"";
            else
                sfileName = [[NSString alloc] initWithUTF8String:cfileName];
            
            char *cquoteNumber = (char *)sqlite3_column_text(selectStatement, 2);
            NSString *squoteNumber;
            if (cquoteNumber == nil)
                squoteNumber = @"";
            else
                squoteNumber = [[NSString alloc] initWithUTF8String:cquoteNumber];
            
            char *ccustName = (char *)sqlite3_column_text(selectStatement, 3);
            NSString *scustName;
            if(ccustName == nil)
                scustName = @"";
            else
                scustName = [[NSString alloc] initWithUTF8String:ccustName];
            
            char *ccellDetail = (char *)sqlite3_column_text(selectStatement, 4);
            NSString *scellDetail;
            if (ccellDetail == nil)
                scellDetail = @"";
            else
                scellDetail = [[NSString alloc] initWithUTF8String:ccellDetail];
            
            char *cdownloadDate = (char *)sqlite3_column_text(selectStatement, 5);
            NSString *sdownloadDate;
            if (cdownloadDate == nil)
                sdownloadDate = @"";
            else
                sdownloadDate = [[NSString alloc] initWithUTF8String:cdownloadDate];
            
            char *csignedDate = (char *)sqlite3_column_text(selectStatement, 6);
            NSString *ssignedDate;
            if (csignedDate == nil)
                ssignedDate = @"";
            else
                ssignedDate  = [[NSString alloc] initWithUTF8String:csignedDate];
            
            char *csubmittedDate = (char *)sqlite3_column_text(selectStatement, 7);
            NSString *ssubmittedDate;
            if (csubmittedDate == nil)
                ssubmittedDate = @"";
            else
                ssubmittedDate = [[NSString alloc] initWithUTF8String:csubmittedDate];
            
            char *csigned = (char *)sqlite3_column_text(selectStatement, 8);
            NSString *ssigned;
            if (csigned == nil)
                ssigned = @"";
            else
                ssigned    = [[NSString alloc] initWithUTF8String:csigned];
            
            char *csubmitted = (char *)sqlite3_column_text(selectStatement, 9);
            NSString *ssubmitted;
            if (csubmitted == nil)
                ssubmitted = @"";
            else
                ssubmitted = [[NSString alloc] initWithUTF8String:csubmitted];
            
            char *cdeleted = (char *)sqlite3_column_text(selectStatement, 10);
            NSString *sdeleted;
            if (cdeleted == nil)
                sdeleted = @"";
            else
                sdeleted = [[NSString alloc] initWithUTF8String:cdeleted];
            
            char *cversionNumber = (char *)sqlite3_column_text(selectStatement, 11);
            NSString *sversionNumber;
            if (cversionNumber  == nil)
                sversionNumber = @"";
            else
                sversionNumber = [[NSString alloc] initWithUTF8String:cversionNumber];
            
            [returnDict setValue:srowID forKey:@"rowID"];
            [returnDict setValue:sfileName forKey:@"fileName"];
            [returnDict setValue:squoteNumber forKey:@"quoteNumber"];
            [returnDict setValue:scustName forKey:@"custName"];
            [returnDict setValue:scellDetail forKey:@"cellDetail"];
            [returnDict setValue:sdownloadDate forKey:@"downloadDate"];
            [returnDict setValue:ssignedDate forKey:@"signedDate"];
            [returnDict setValue:ssubmittedDate forKey:@"submittedDate"];
            [returnDict setValue:ssigned  forKey:@"signed"];
            [returnDict setValue:ssubmitted forKey:@"submitted"];
            [returnDict setValue:sdeleted forKey:@"deleted"];
            [returnDict setValue:sversionNumber forKey:@"versionNumber"];
        }
    }
    sqlite3_close(database);
    return returnDict;
}



//mrv added 1/6/2014
+(void)flagAsSigned:(NSString*)quoteNumber;
{
    NSString *flagCmd = @"UPDATE QuoteTable "
    @"SET signed = 1, signedDate = ? "
    @" WHERE quoteNumber = ? ";
    
    [self flagRecordWithDate:flagCmd forQuoteNumber:quoteNumber];
}


//mrv flag as submitted added 1/6/2014
+(void)flagAsSubimtted:(NSString*)quoteNumber
{
    NSString *flagCmd = @"UPDATE QuoteTable "
    @"SET submitted = 1, submittedDate = ? "
    @" WHERE quoteNumber = ?";
    [self flagRecordWithDate:flagCmd forQuoteNumber:quoteNumber];
}


//mrv added 1/6/2014
+(void)flagRecordWithDate:(NSString *)command forQuoteNumber:(NSString *)quote
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"4: Failed to open database");
    }
    
    const char *updateChar = [command cStringUsingEncoding:[NSString defaultCStringEncoding]];
    
    sqlite3_stmt *commandStmt;
    
    if (sqlite3_prepare_v2(database, updateChar, -1, &commandStmt, nil) == SQLITE_OK)
    {
        
        sqlite3_bind_text(commandStmt, 1, [[formatter stringFromDate:[NSDate date]] UTF8String], -1, NULL);
        sqlite3_bind_text(commandStmt, 2, [quote UTF8String],-1, NULL);
        
        sqlite3_step(commandStmt);
    }
    sqlite3_close(database);
    
}


//mrv added 1/6/2014
+(void)deleteRecordByQuoteNum:(NSString*)quote
{
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"86: Failed to open database");
    }
    
    char *deleteChar = "DELETE FROM QuoteTable "
    "WHERE quoteNumber = ?";
    
    
    sqlite3_stmt *commandStmt;
    
    if (sqlite3_prepare_v2(database, deleteChar, -1, &commandStmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(commandStmt, 1, [quote UTF8String], -1, NULL);;
        sqlite3_step(commandStmt);
    }
    
    
    sqlite3_close(database);
    
}



@end
