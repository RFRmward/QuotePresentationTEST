//
//  ShowQuoteViewController.m
//  QuoteTabiPad
//
//  Created by Ralph Whitten on 6/22/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//
#define kDefaultPageHeight 916 //916
#define kDefaultPageWidth  720 //720
#define kMargin 0



#import "ShowQuoteViewController.h"
#import "dbCatchAll.h"
#import "CanGoThere.h"


NSDictionary *userSettings;


UIDocumentInteractionController *documentController;

@interface ShowQuoteViewController ()<UIWebViewDelegate>
{
    BOOL bDownloaded;
}

@end

@implementation ShowQuoteViewController
@synthesize webView;
@synthesize pdfPath;
@synthesize popover;
@synthesize pvc;

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

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
    userSettings = [CanGoThere getLogin];
    
    //NSString *message=@"Quote has not been downloaded!";
    //NSString *title=@"Quote ";
    //title = [title stringByAppendingString:_quoteItem];
    [super viewDidLoad];
    [self.lblLoading setHidden:TRUE];//RW 10/31/13
    [self.spinner setHidden:TRUE];//RW 10/31/13
    webView.delegate=self;//RW 10/31/13
    bDownloaded=FALSE;
    NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
    fileName = [fileName stringByAppendingString:@".pdf"];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* findFile = [documentsPath stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:findFile];
    if (fileExists == YES) {
        [self.lblLoading setHidden:FALSE];//RW 10/31/13
        [self.spinner setHidden:FALSE];//RW 10/31/13
        [self.spinner startAnimating];//RW 10/31/13
        NSURL *url = [NSURL fileURLWithPath:findFile];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[self webView] loadRequest:request];
        [self webView].scalesPageToFit=YES;
        [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.webView setHidden:FALSE];
        //docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        //[docController setDelegate:self];
        //[docController presentPreviewAnimated:YES];
        bDownloaded=TRUE;
        //[docController presentOpenInMenuFromRect:[button frame] inView:self.view animated:YES];
        pdfPath = findFile; //rw 01/5/2013
    }
    else
    {
        
        /*UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Display",@"Download and Display",nil];
        [alertview show];*/
        //Download all Quotes selected rw 11/23/13
        [dbCatchAll insertNewQuoteTableItemForQuote:_quoteItem
                                         withDetail:_detailLine
                                       withFileName:fileName
                                            forCust:_custName]; //rv 12/19/2013
        NSString *pdfLocation;  //mw 10-31-2013
        [self.spinner setHidden:FALSE];//RW 10/31/13
        [self.lblLoading setHidden:FALSE];//RW 10/31/13
        [self.spinner startAnimating];//RW 10/31/13
        if ([_IndAg  isEqual: @"Ind"])  //mw 10-31-2013
        {
            pdfLocation = [NSString stringWithFormat:@"%@%@%@%@%@",
                           QuotePDFDownload,
                           @"?guid=",
                           [userSettings objectForKey:@"guid"],
                           @"&Download=True&QuoteNum=",
                           _quoteItem
                           ];
            //[QuotePDFDownload stringByAppendingString:_quoteItem];mrv
        }
        else
        {
            pdfLocation = [NSString stringWithFormat:@"%@%@%@%@%@",
                           QuoteAgPDFDownload,
                           @"?guid=",
                           [userSettings objectForKey:@"guid"],
                           @"&Download=True&QuoteNum=",
                           _quoteItem
                           ];
            //[QuoteAgPDFDownload stringByAppendingString:_quoteItem];mrv
        }
        //NSLog(@"The PDF string is %@", pdfLocation);
        NSURL *kPDF = [NSURL URLWithString:pdfLocation];
        NSError *err1 = nil;
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:kPDF options:NSDataReadingUncached error:&err1];
        //NSLog(@"The data is %@", data);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        array = [json objectForKey:@"QuotePDF"];
        NSDictionary *dictURL = [array objectAtIndex:0];
        NSString *sURL = [dictURL objectForKey:@"URL"];
        NSLog(@"The URL is %@", sURL);
        
        NSData *pdfData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:sURL]];
        NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
        fileName = [fileName stringByAppendingString:@".pdf"];
        //NSLog(@"The fileName is %@", fileName);
        NSString *resourceDocPath = [[NSString alloc] initWithString:[[[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"]];
        //NSLog(@"The resourceDocPath is %@", resourceDocPath);
        NSString *filePath = [resourceDocPath stringByAppendingPathComponent:fileName];
        //NSLog(@"The filePath is %@", filePath);
        [pdfData writeToFile:filePath atomically:YES];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [[self webView] loadRequest:requestObj];
        webView.scalesPageToFit=YES;
        [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        bDownloaded=TRUE;
        pdfPath = filePath; //rw 12/3/2013
    }
}

- (IBAction)showMenu:(id)sender
{
    NSString *message=@"Quote Action";
    NSString *title=@"Quote ";
    title = [title stringByAppendingString:_quoteItem];
    
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign",@"Submit",@"Email",@"Print",nil];
    [alertview show];
    
    /*
    **Save to show Print, Mail, and AirCopy**
    *if (bDownloaded) {
        NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
        fileName = [fileName stringByAppendingString:@".pdf"];
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* filePath = [documentsPath stringByAppendingPathComponent:fileName];
        //NSLog(@"%@",filePath);
        NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
        NSArray* itemsToShare = [NSArray arrayWithObjects:pdfData,nil];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeMessage];
    
    
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertDisplay = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Options only available for Downloaded Quotes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertDisplay show];
                
    }*/
}

- (IBAction)sign:(id)sender {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:[@"Quote_" stringByAppendingString:_quoteItem] withExtension:@"pdf"];
    if (URL) {
        docController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        [docController setDelegate:self];
        [docController presentPreviewAnimated:YES];
        //[docController presentOpenInMenuFromRect:[button frame] inView:self.view animated:YES];
    }
    
    //NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
    //fileName = [fileName stringByAppendingString:@".pdf"];
    //NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString* filePath = [documentsPath stringByAppendingPathComponent:fileName];
    //NSLog(@"%@",filePath);
    //NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    //NSArray* itemsToShare = [NSArray arrayWithObjects:pdfData,nil];
    //UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    //activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeMail,UIActivityTypeMessage];
    
    
    //[self presentViewController:activityVC animated:YES completion:nil];
    
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

/*- (IBAction)email:(id)sender {
    //UIAlertView *alertPick = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Check" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Email", nil];
    //[alertPick show];
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Email from iPad"];
        //NSMutableData *pdfData = [NSMutableData data];
        NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
        fileName = [fileName stringByAppendingString:@".pdf"];
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* filePath = [documentsPath stringByAppendingPathComponent:fileName];
        NSLog(@"%@",filePath);
        NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
        [controller addAttachmentData:pdfData mimeType:@"application/pdf" fileName:fileName];
        [controller setMessageBody:@"RFR Quote Attached" isHTML:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        UIAlertView *alertFail = [[UIAlertView alloc] initWithTitle:@"Email Error" message:@"Your device doesn't send email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertFail show];
    }
    
}*/

/*- (void)printWebView:(id)sender {

    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
        if (!completed && error) NSLog(@"Print error: %@", error);
    };
    NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
    fileName = [fileName stringByAppendingString:@".pdf"];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSLog(@"%@",filePath);
    NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    printController.printingItem = pdfData;
    printController.showsPageRange = YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [printController presentFromBarButtonItem:sender animated:YES completionHandler:completionHandler];
    } else {
        [printController presentAnimated:YES completionHandler:completionHandler];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(result == MFMailComposeResultSent)
    {
        UIAlertView *alertSent = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Mail sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertSent show];
    }
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}*/

- (void)dismissPop:(NSString *)value {
    
    //NSString *sSearch;
    NSArray *arrReturn = [value componentsSeparatedByString:@","];
    int iMenuReturn = [[arrReturn objectAtIndex:0] intValue];
    switch (iMenuReturn) {
        case 1:
            [[popover popoverController] dismissPopoverAnimated:YES];
            
            break;
        case 2:
            [[popover popoverController] dismissPopoverAnimated:YES];
            break;
        case 3:
 
            break;
        case 4:
            
            break;
        case 5:
            
            break;
        default:
            break;
    }
    
    //[self performSegueWithIdentifier:@"showSignature" sender:nil];
}

-(void)toSignature:(id) sender {
    CGFloat contentHeight = self.webView.scrollView.contentSize.height;
    int height = (int)roundf(contentHeight);
    
    // Size of the view in the pdf page
    CGFloat maxHeight   = kDefaultPageHeight; // - 2*kMargin;
    CGFloat maxWidth    = kDefaultPageWidth; // - 2*kMargin;
    int pages = floor(height / maxHeight);
    //NSString *heightStr = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    //NSLog(@"Pages %d",pages);
    //NSLog(@"height %@",heightStr);
    [webView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
    //NSLog(@"Path%@",self.pdfPath);
    NSString *signedPDFPath = self.pdfPath;
    NSRange range = NSMakeRange(signedPDFPath.length-4, 4);
    NSString *newpdfPath = [signedPDFPath stringByReplacingCharactersInRange:range withString:@"_Signed.pdf"];
    NSLog(@"New Path%@",newpdfPath);
    //Create
    // Set up we the pdf we're going to be generating is
    UIGraphicsBeginPDFContextToFile(newpdfPath, CGRectZero, nil);
    int i = 0;
    
    for ( ; i < pages; i++)
    {
        if (i == 1) {
        if (maxHeight * (i+1) > height)
        { // Check to see if page draws more than the height of the UIWebView
            CGRect f = [webView frame];
            f.size.height -= (((i+1) * maxHeight) - height);
            [webView setFrame: f];
        }
        // Specify the size of the pdf page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        // Move the context for the margins
        CGContextTranslateCTM(currentContext, kMargin, kMargin);
        //CGContextTranslateCTM(currentContext, 0, -10);

        // offset the webview content so we're drawing the part of the webview for the current page
        [[[webView subviews] lastObject] setContentOffset:CGPointMake(0, maxHeight * i) animated:NO];
        // draw the layer to the pdf, ignore the "renderInContext not found" warning.
        [webView.layer renderInContext:currentContext];
        }
    }
    // all done with making the pdf
    UIGraphicsEndPDFContext();
    self.pdfPath = newpdfPath;
    [self performSegueWithIdentifier:@"showSignaturePage" sender:self];
    
    // Restore the webview and move it to the top.
    //[webView setFrame:origframe];
    //[[[webView subviews] lastObject] setContentOffset:CGPointMake(0, 0) animated:NO];
    
    //Save Display and Download of Quote**
    //[self.spinner setHidden:FALSE];//RW 10/31/13
    //[self.lblLoading setHidden:FALSE];//RW 10/31/13
    //[self.spinner startAnimating];//RW 10/31/13
     /*NSString *pdfLocation;  //mw 10-31-2013
    
     [self.spinner setHidden:FALSE];//RW 10/31/13
     [self.lblLoading setHidden:FALSE];//RW 10/31/13
     [self.spinner startAnimating];//RW 10/31/13
     //NSString *pdfLocation = [QuotePDFCreate stringByAppendingString:_quoteItem];
     if ([_IndAg  isEqual: @"Ind"])  //mw 10-31-2013
     {
     pdfLocation = [QuotePDFDownload stringByAppendingString:_quoteItem];
     }
     else
     {
     pdfLocation = [QuoteAgPDFDownload stringByAppendingString:_quoteItem];
     }
     //NSLog(@"The PDF string is %@", pdfLocation);
     NSURL *kPDF = [NSURL URLWithString:pdfLocation];
     NSError *err1 = nil;
     NSError *error = nil;
     NSData *data = [NSData dataWithContentsOfURL:kPDF options:NSDataReadingUncached error:&err1];
     //NSLog(@"The data is %@", data);
     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
     NSMutableArray *array = [[NSMutableArray alloc] init];
     array = [json objectForKey:@"QuotePDF"];
     NSDictionary *dictURL = [array objectAtIndex:0];
     NSString *sURL = [dictURL objectForKey:@"URL"];
     //NSLog(@"The URL is %@", sURL);
     NSURL *tempURL = [NSURL URLWithString:sURL];
     NSURLRequest *request = [NSURLRequest requestWithURL:tempURL];
     [[self webView] loadRequest:request];
     [self webView].scalesPageToFit=YES;
     [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     */

    //[self performSegueWithIdentifier:@"showSignaturePage" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //NSLog(@"User Pressed button 0");
        //[alertView dismissWithClickedButtonIndex:-1 animated:NO];
        //alertView = nil;
        [self toSignature:0];
        //[self performSegueWithIdentifier:@"showSignPopOver" sender:self];
    }
    
    if (buttonIndex == 2) {
        [self SubmitPDFs:@"_Signed.pdf"]; //mw
    }
}


//mw
-(void)SubmitPDFs:(NSString *)extension{
    
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *item;
    NSArray *contents = [fManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];
    
    // >>> find all files with the extension "_Signed.pdf".
    for (item in contents){
        if ([item rangeOfString:extension].location != NSNotFound) {
            // get the file path.
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:item];
            
            [self email:filePath :item];
            filePath=nil;
            //break;
        }
    }
}

//mw
- (void) email :(NSString *) filePath :(NSString *) fileName {
    
    //-(IBAction)email:(id)sender {
    //UIAlertView *alertPick = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Check" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Email", nil];
    //[alertPick show];
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        //controller.mailComposeDelegate = self;
        NSArray *toRecipents = [NSArray arrayWithObject:@"mward@rainforrent.com"];
        [controller setToRecipients:toRecipents];
        [controller setSubject:@"SIGNED PDF UPLOAD"];
        //NSMutableData *pdfData = [NSMutableData data];
        
        //NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
        //fileName = [fileName stringByAppendingString:@".pdf"];
        //NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSString* filePath = [documentsPath stringByAppendingPathComponent:fileName];
        
        NSLog(@"%@",filePath);
        NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
        [controller addAttachmentData:pdfData mimeType:@"application/pdf" fileName:fileName];
        [controller setMessageBody:@"RFR Signed Quote Attached" isHTML:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        UIAlertView *alertFail = [[UIAlertView alloc] initWithTitle:@"Email Error" message:@"Your device doesn't send email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertFail show];
    }
    
}








/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"User Pressed button 0");
        [alertView dismissWithClickedButtonIndex:-1 animated:NO];
        alertView = nil;
        //[self toSignature:nil];
        //[self performSegueWithIdentifier:@"showSignature" sender:nil];
    }
    
    //Save existing webView
    //CGRect origframe = webView.frame;
    CGFloat contentHeight = self.webView.scrollView.contentSize.height;
    int height = (int)roundf(contentHeight);
    //NSString *heightStr = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"]; // Get the height of our webView
    //int height = [heightStr intValue];
    
    // Size of the view in the pdf page
    CGFloat maxHeight   = kDefaultPageHeight; //- 2*kMargin;
    CGFloat maxWidth    = kDefaultPageWidth; //- 2*kMargin;
    int pages = floor(height / maxHeight);
    
    [webView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
    //NSLog(@"Path%@",self.pdfPath);
    NSString *signedPDFPath = self.pdfPath;
    NSRange range = NSMakeRange(signedPDFPath.length-4, 4);
    NSString *newpdfPath = [signedPDFPath stringByReplacingCharactersInRange:range withString:@"_signed.pdf"];
    //NSLog(@"New Path%@",newpdfPath);
    //Create
    // Set up we the pdf we're going to be generating is
    UIGraphicsBeginPDFContextToFile(newpdfPath, CGRectZero, nil);
    int i = 0;
    for ( ; i < pages; i++)
    {
        if (maxHeight * (i+1) > height)
        { // Check to see if page draws more than the height of the UIWebView
            CGRect f = [webView frame];
            f.size.height -= (((i+1) * maxHeight) - height);
            [webView setFrame: f];
        }
        // Specify the size of the pdf page
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        // Move the context for the margins
        CGContextTranslateCTM(currentContext, kMargin, kMargin);
        // offset the webview content so we're drawing the part of the webview for the current page
        [[[webView subviews] lastObject] setContentOffset:CGPointMake(0, maxHeight * i) animated:NO];
        // draw the layer to the pdf, ignore the "renderInContext not found" warning.
        [webView.layer renderInContext:currentContext];
    }
    // all done with making the pdf
    UIGraphicsEndPDFContext();
    // Restore the webview and move it to the top.
    //[webView setFrame:origframe];
    [[[webView subviews] lastObject] setContentOffset:CGPointMake(0, 0) animated:NO];
    */
    //**Save Display and Download of Quote**
    //[self.spinner setHidden:FALSE];//RW 10/31/13
    //[self.lblLoading setHidden:FALSE];//RW 10/31/13
    //[self.spinner startAnimating];//RW 10/31/13
    /*NSString *pdfLocation;  //mw 10-31-2013
    if (buttonIndex == 1) {
        [self.spinner setHidden:FALSE];//RW 10/31/13
        [self.lblLoading setHidden:FALSE];//RW 10/31/13
        [self.spinner startAnimating];//RW 10/31/13
        //NSString *pdfLocation = [QuotePDFCreate stringByAppendingString:_quoteItem];
        if ([_IndAg  isEqual: @"Ind"])  //mw 10-31-2013
        {
            pdfLocation = [QuotePDFDownload stringByAppendingString:_quoteItem];
        }
        else
        {
            pdfLocation = [QuoteAgPDFDownload stringByAppendingString:_quoteItem];
        }
        //NSLog(@"The PDF string is %@", pdfLocation);
        NSURL *kPDF = [NSURL URLWithString:pdfLocation];
        NSError *err1 = nil;
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:kPDF options:NSDataReadingUncached error:&err1];
        //NSLog(@"The data is %@", data);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        array = [json objectForKey:@"QuotePDF"];
        NSDictionary *dictURL = [array objectAtIndex:0];
        NSString *sURL = [dictURL objectForKey:@"URL"];
        //NSLog(@"The URL is %@", sURL);
        NSURL *tempURL = [NSURL URLWithString:sURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:tempURL];
        [[self webView] loadRequest:request];
        [self webView].scalesPageToFit=YES;
        [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    }
    if (buttonIndex == 2) {
        //NSString *pdfLocation = [QuotePDFDownload stringByAppendingString:_quoteItem];
        [self.spinner setHidden:FALSE];//RW 10/31/13
        [self.lblLoading setHidden:FALSE];//RW 10/31/13
        [self.spinner startAnimating];//RW 10/31/13
        if ([_IndAg  isEqual: @"Ind"])  //mw 10-31-2013
        {
            pdfLocation = [QuotePDFDownload stringByAppendingString:_quoteItem];
        }
        else
        {
            pdfLocation = [QuoteAgPDFDownload stringByAppendingString:_quoteItem];
        }
        //NSLog(@"The PDF string is %@", pdfLocation);
        NSURL *kPDF = [NSURL URLWithString:pdfLocation];
        NSError *err1 = nil;
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:kPDF options:NSDataReadingUncached error:&err1];
        //NSLog(@"The data is %@", data);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        array = [json objectForKey:@"QuotePDF"];
        NSDictionary *dictURL = [array objectAtIndex:0];
        NSString *sURL = [dictURL objectForKey:@"URL"];
        NSLog(@"The URL is %@", sURL);
        
        NSData *pdfData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:sURL]];
        NSString *fileName = [@"Quote_" stringByAppendingString:_quoteItem];
        fileName = [fileName stringByAppendingString:@".pdf"];
        //NSLog(@"The fileName is %@", fileName);
        NSString *resourceDocPath = [[NSString alloc] initWithString:[[[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"]];
        //NSLog(@"The resourceDocPath is %@", resourceDocPath);
        NSString *filePath = [resourceDocPath stringByAppendingPathComponent:fileName];
        //NSLog(@"The filePath is %@", filePath);
        [pdfData writeToFile:filePath atomically:YES];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [[self webView] loadRequest:requestObj];
        webView.scalesPageToFit=YES;
        [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        bDownloaded=TRUE;
    }
    
}*/

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner setHidden:TRUE];//RW 11/1/13
    [self.lblLoading setHidden:TRUE];//RW 10/31/13
    [self.spinner stopAnimating];//RW 10/31/13
    
    
    //CGFloat contentHeight = self.webView.scrollView.contentSize.height;
    //int height = (int)(contentHeight);
    //height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    //NSLog(@"%f",self.webView.scrollView.contentSize.height);
}

- (void)setQuoteItem:(id)newQuoteItem
{
    if (_quoteItem != newQuoteItem) {
        _quoteItem = newQuoteItem;
        
    }
}

- (void)setFileName:(id)newFileName
{
    if (_fileName != newFileName) {
        _fileName = newFileName;
        
    }
}

- (void)setIndAg:(id)newIndAg  //mw 10-31-2013
{
    if (_IndAg != newIndAg) {
        _IndAg = newIndAg;
        
    }
}

-(void)setDetailLine:(NSString *)newDetailLine
{
    if (_detailLine != newDetailLine)
        _detailLine = newDetailLine;
}

-(void)setCustName:(NSString *)newCustName
{
    if (_custName != newCustName)
        _custName = newCustName;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([[segue identifier] isEqualToString:@"showQuoteMenu"]) {
            popover = (UIStoryboardPopoverSegue *)segue;
            pvc = [segue destinationViewController];
            [pvc setDelegate:self];
    }*/
    NSString *quoteNum = _quoteItem;
    if ([[segue identifier] isEqualToString:@"showSignaturePage"]) {
        [[segue destinationViewController]  setQuoteItem:quoteNum];
        [[segue destinationViewController]  setFileName:self.pdfPath];
    }
}

@end
