//
//  LoginViewController.m
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 10/18/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "LoginViewController.h"
#import "dbCatchAll.h"

NSString *kTestMode = @"NO";
NSMutableDictionary *logDict;
NSString *theGUID; // will need to be set during the autnenticate step
NSString *appID = @"3"; //to be used with enhanced security
NSString *theDevice;
NSString *verNum;

//mrv modified to use  QuotePresentation web service
//quotes permissions and group settings
NSString *quoteSecurityURL = @"http://customer.rainforrent.com/QuotePresentationPortalWCF/QuotePresentationPortal.svc/getQuoteSecurity";
NSString *prodAuthenticateURL = @"http://customer.rainforrent.com/QuotePresentationPortalWCF/QuotePresentationPortal.svc/Authenticate";
//mrv did away with the update URL.



@interface LoginViewController ()
//_objects done away with
@end

@implementation LoginViewController

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
    [super viewDidLoad];
    [self.spinner setHidden:TRUE];
	
    verNum =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //NSLog(@"Version num %@", verNum);
    
    _lblVersion.text = [NSString stringWithFormat:@"Version: %@", verNum];
    [self.lblLoading setHidden:TRUE];
    
    //theDevice  = [UIDevice currentDevice].identifierForVendor.UUIDString;
    //NSUUID *udid = [UIDevice currentDevice].identifierForVendor; does not return the same thing each time.
    //theDevice = [udid UUIDString];
    //NSDictionary *hey = [[NSBundle mainBundle] infoDictionary];
    //theDevice = [UIDevice currentDevice]
    //theDevice =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    theDevice = [[UIDevice currentDevice] name];
    
    //NSLog(@"TheDevice %@", theDevice);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"login.plist"];
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        // if not in documents, get property list from main bundle
        plistPath = [[NSBundle mainBundle] pathForResource:@"login" ofType:@"plist"];
    }
    logDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *UserID = [logDict objectForKey:@"UserID"];
    //NSString *BranchGroup = [logDict objectForKey:@"BranchGroup"];
    
    if ([UserID length] > 0)
    {
        
        [self performSegueWithIdentifier:@"showApproved" sender:nil];
        
    }
}

- (IBAction)loginPressed:(UIButton *)sender
{
    if ([self.userName.text length] > 0 && [self.passWord.text length] > 0)
    {
        [self.lblLoading setHidden:FALSE];
        [self.spinner startAnimating];
        [self performSelector:@selector(loginProcess)
                   withObject:nil
                   afterDelay:0];
        return;
    }
}







-(void)loginProcess
{
    NSString *strURL;
    BOOL bPass = YES;
    NSDictionary *json;
    //mrv 1/3/2014
    strURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@",
              prodAuthenticateURL,
              @"?guid=",
              @"121956",
              @"&usr=",
              self.userName.text,
              @"&password=",
              [LoginViewController encodeURL: self.passWord.text],
              @"&deviceid=",
              [LoginViewController encodeURL: theDevice],
              @"&appid=",
              appID,
              @"&appvsn=",
              verNum
              ];
    
    
    // NSLog(@"URL string= %@", strURL);
    NSURL *kQuotesApproveURL = [NSURL URLWithString:strURL];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:kQuotesApproveURL
                                         options:NSDataReadingUncached
                                           error:&error];
    if(error)
    {
        UIAlertView *cantConn = [[UIAlertView alloc]
                                 initWithTitle:@"Connection Problem"
                                 message:@"Cannot Connect, try again later."
                                 delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [cantConn show];
        self.userName.text = @"";
        self.passWord.text = @"";
        bPass = NO;
    }
    
    if (bPass)
    {
        json = [NSJSONSerialization
                JSONObjectWithData:data
                options:NSJSONReadingMutableContainers
                error:&error];
        if (error)
        {
            UIAlertView *otherError = [[UIAlertView alloc]
                                       initWithTitle:@"Connection Problem"
                                       message:error.description
                                       delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            [otherError show];
            self.userName.text = @"";
            self.passWord.text = @"";
            bPass = NO;
        }
    }
    
    if (bPass)
    {   //mrv 1/3/2014
        //NSString *logResult =  [json objectForKey:@"IsAuthenticatedResult"];
        NSString *logResult = [json objectForKey:@"passfail"];
        
        //NSLog(@"Return result: %@", logResult);
        
        //if ([logResult length] == 36)
        //    theGUID = logResult;
        //mrv 1/6/2014 the return has a passfail flag
        //if pass read the guid
        //if fail read errorMsg
        if ([logResult isEqualToString:@"pass"])
        {
            theGUID = [json objectForKey:@"guid"];
        }
        else
        {
            UIAlertView *messedUp = [[UIAlertView alloc]
                                     initWithTitle:@"Login Failed"
                                     message:[json objectForKey:@"errorMsg"]
                                     //message:@"Either user name or password was incorrect."
                                     delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [messedUp show];
            self.userName.text = @"";
            self.passWord.text = @"";
            bPass = NO;
        }
        
        if (bPass)
        {
            bPass = [self processValidUser]; //processValidUser has its own feedback
            if (bPass)
            {
                //NSString *BranchGroup = [logDict objectForKey:@"BranchGroup"];
                //if ([BranchGroup isEqualToString:@"True"])
                //[self performSegueWithIdentifier:@"showBranches" sender:nil];
                //else
                [self performSegueWithIdentifier:@"showApproved" sender:nil];
                
            }
        }
        else {
            ///mrv 1/6/2014
            //                UIAlertView *messedUp = [[UIAlertView alloc]
            //                                         initWithTitle:@"Invalid Login"
            //                                         message:@"Either user name or password was incorrect."
            //                                         delegate:self
            //                                         cancelButtonTitle:@"OK"
            //                                         otherButtonTitles:nil];
            //                [messedUp show];
            self.userName.text = @"";
            self.passWord.text = @"";
            //[self.spinner stopAnimating];
        }
        
    }
    
    [self.spinner stopAnimating];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.userName.text = @"";
    self.passWord.text = @"";
    [self clearLogin];
    [dbCatchAll configureDB];//mrv 12/19/2013
}


-(void)clearLogin {
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"login.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:plistPath error:NULL];
    }
}

//static method used for encoding user password
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

-(BOOL)processValidUser {
    NSString *BranchGroup;
    NSString *GroupID;
    NSString *securityLevel = @"1";
    NSString *strURL;
    
    strURL= [NSString
             stringWithFormat:@"%@%@%@%@%@",
             quoteSecurityURL,
             @"?guid=",
             theGUID,
             @"&UserID=",
             self.userName.text];
    
    //NSLog(@"URL string= %@", strURL);
    NSURL *kQuotesApproveURL = [NSURL URLWithString:strURL];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:kQuotesApproveURL
                                         options:NSDataReadingUncached
                                           error:&error];
    
    if (error)
    {
        UIAlertView *otherError = [[UIAlertView alloc]
                                   initWithTitle:@"something happended"
                                   message:error.description
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [otherError show];
        return NO;
        
    }
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    
    
    if (error)
    {
        UIAlertView *otherError = [[UIAlertView alloc]
                                   initWithTitle:@"Security Level issue"
                                   message:@"Insufficient privileges"
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [otherError show];
        return NO;
    }
    
    
    NSString *someString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    //NSLog(@"%@", someString );
    
    
    NSRange rangeValue = [someString rangeOfString:@"Invalid" options:NSCaseInsensitiveSearch];
    if (rangeValue.length > 0)
    {
        UIAlertView *otherError = [[UIAlertView alloc]
                                   initWithTitle:@"Security Level issue"
                                   message:@"Insufficient privileges"
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [otherError show];
        return NO;
    }
    
    NSMutableArray *array = [json objectForKey:@"QuoteSecurity"];
    NSDictionary *security = [array objectAtIndex:0];
    
    BranchGroup = [security objectForKey:@"BranchGroup"];
    GroupID = [security objectForKey:@"GroupID"];
    
    
    securityLevel = [security objectForKey:@"SecurityLevel"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *outPath = [documentsPath stringByAppendingPathComponent:@"login.plist"];
    NSString *deviceName = [[UIDevice currentDevice] name];
    
    //NSString *deviceModel = [[UIDevice currentDevice] model]; //model of device to be used with enhanced security
    
    // check to see if Data.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:outPath])
    {
        // if not in documents, get property list from main bundle
        NSString *plistPath;
        plistPath = [[NSBundle mainBundle] pathForResource:@"login" ofType:@"plist"];
        logDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    } else {
        logDict = [[NSMutableDictionary alloc] initWithContentsOfFile:outPath];
    }
    [logDict setObject:self.userName.text  forKey:@"UserID"];
    [logDict setObject:verNum forKey:@"version"];
    [logDict setObject:BranchGroup forKey:@"BranchGroup"];
    [logDict setObject:GroupID forKey:@"GroupID"];
    [logDict setObject:deviceName forKey:@"deviceName"];
    [logDict setObject:kTestMode forKey:@"inTestMode"];
    [logDict setObject:theGUID forKey:@"guid"];
    
    
    [logDict setObject:securityLevel forKey:@"SecurityLevel"];
    
    [logDict writeToFile:outPath atomically:YES];
    
    //set dataclass aside for now
    //DataClass *obj = [DataClass getInstance];
    
    //obj.userSettings = logDict;
    
    //    NSLog(@"name: %@", [[UIDevice currentDevice] name]);
    //    NSLog(@"model: %@", [[UIDevice currentDevice] model]);
    return YES;
}


//mrv no longer need to update divice info
//-(BOOL)updateDeviceData
//{
//    NSString *sessionURL;
//
//    sessionURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
//                  prodSessionUpdate,
//                  @"?guid=",
//                  theGUID,
//                  @"&appid=",
//                  appID,
//                  @"&usr=",
//                  self.userName.text,
//                  @"&appversion=",
//                  verNum];
//    //NSLog(@"%@", sessionURL);
//
//    NSError *error = nil;
//    NSURL *deviceURL = [NSURL URLWithString:sessionURL];
//    NSData *data = [NSData dataWithContentsOfURL:deviceURL
//                                         options:NSDataReadingUncached
//                                           error:&error];
//    if(error)
//    {
//        return NO;
//    }
//
//    NSDictionary *dictUpdate = [NSJSONSerialization
//                                JSONObjectWithData:data
//                                options:NSJSONReadingMutableContainers
//                                error:&error];
//
//    NSString *result = [dictUpdate objectForKey:@"UpdateDeviceInfoResult"];
//
//    if ([result isEqualToString:@"Update Successfull"])
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showApproved"]) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"login.plist"];
        // check to see if Data.plist exists in documents
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            // if not in documents, get property list from main bundle
            plistPath = [[NSBundle mainBundle] pathForResource:@"login" ofType:@"plist"];
        }
        logDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *UserID = [logDict objectForKey:@"UserID"];
        //NSString *UserID=@"rwhitten";
        
        [[segue destinationViewController]  setUserID:UserID];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
