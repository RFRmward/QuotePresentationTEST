//
//  SignaturePopViewController.m
//  RFRSignature
//
//  Created by Ralph Whitten on 11/14/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "SignaturePopViewController.h"
#import "SignatureView.h"

///////////////xxxxxxx////////////

@interface SignaturePopViewController() {
@private
    __strong SignatureView *signatureView_;
    __strong UIImageView *signaturePanelBackgroundImageView_;
	__strong UIImage *landscapeBackgroundImage_;
	__strong UIButton *confirmButton_, *cancelButton_, *clearButton_;
	__weak id<SignaturePopViewControllerDelegate> delegate_;
    
}
// The view responsible for handling signature sketching
@property(nonatomic,strong) SignatureView *signatureView;

// The background image underneathe the sketch
@property(nonatomic,strong) UIImageView *signaturePanelBackgroundImageView;

// Private Methods
-(void)didTapConfirmButton;
-(void)didTapCancelButton;

@end

@implementation SignaturePopViewController

@synthesize
signaturePanelBackgroundImageView = signaturePanelBackgroundImageView_,
signatureView = signatureView_,
landscapeBackgroundImage = landscapeBackgroundImage_,
confirmButton = confirmButton_,
cancelButton = cancelButton_,
clearButton = clearButton_,
delegate = delegate_,
fileName = fileName_;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init {
	return [self initWithNibName:nil bundle:nil];
}

-(void)loadView {
	
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// Background images
	self.landscapeBackgroundImage = [UIImage imageNamed:@"bg-signature-landscape"];
	self.signaturePanelBackgroundImageView = [[UIImageView alloc] initWithImage:self.landscapeBackgroundImage];
	
	// Signature view
	self.signatureView = [[SignatureView alloc] init];
	
	// Cancel
	self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[self.cancelButton sizeToFit];
	[self.cancelButton setFrame:CGRectMake(400.0f,
        10.0f,
        self.cancelButton.frame.size.width,
        self.cancelButton.frame.size.height)];
	[self.cancelButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    // Clear
	self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
	[self.clearButton sizeToFit];
	[self.clearButton setFrame:CGRectMake(200.0f,
											10.0f,
											self.clearButton.frame.size.width,
											self.clearButton.frame.size.height)];
	[self.clearButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    
    // Confirm
	self.confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
	[self.confirmButton sizeToFit];
	[self.confirmButton setFrame:CGRectMake(10.0f,
											10.0f,
											self.confirmButton.frame.size.width,
											self.confirmButton.frame.size.height)];
	[self.confirmButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
	
	
}

- (void)viewDidLoad
{
    // Background Image
	[self.signaturePanelBackgroundImageView setFrame:self.view.bounds];
	[self.signaturePanelBackgroundImageView setContentMode:UIViewContentModeTopLeft];
	[self.view addSubview:self.signaturePanelBackgroundImageView];
	
	// Signature View
	[self.signatureView setFrame:self.view.bounds];
	[self.view addSubview:self.signatureView];
	
	// Buttons
    [self.view addSubview:self.confirmButton];
    [self.view addSubview:self.clearButton];
	[self.view addSubview:self.cancelButton];
	
	// Button actions
	[self.confirmButton addTarget:self action:@selector(didTapConfirmButton) forControlEvents:UIControlEventTouchUpInside];
	[self.cancelButton addTarget:self action:@selector(didTapCancelButton) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)didTapConfirmButton {
	
	//if (self.delegate && [self.delegate respondsToSelector:@selector(signatureConfirmed:signatureController:)]) {
		UIImage *signatureImage = [self.signatureView getSignatureImage];
		[self.delegate signatureConfirmed:signatureImage signatureController:self];
        //NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
        //[UIImagePNGRepresentation(signatureImage) writeToFile:pngPath atomically:YES];
    
    
    //[self imageAnnotation:pngPath];
    
    [self imageAnnotation:signatureImage];
    
	//}
	
}




//-(void)insertImage:(NSString *)thePath
//{
//    UIGraphicsBeginPDFContextToFile(fileName_, CGRectZero, nil);
//    
//    //UIGraphicsBeginPDFPageWithInfo(CGRectMake(0,0,612,792),nil);
//    UIImage *sig = [UIImage imageNamed:thePath];
//    CGRect frame = CGRectMake(50,100,378,141);
//    
//    CGContextRef ctr = UIGraphicsGetCurrentContext();
//    
//    [sig drawInRect:frame];
//    
//    
//    
//    UIGraphicsEndPDFContext();
//    
//
//}



-(NSString *)getPDFFileName {
    return fileName_ ;
}



-(NSString *)getTempPDFFileName {
    NSString *theFileName = [[fileName_ lastPathComponent] stringByDeletingPathExtension];
    NSString *thePath = [fileName_ stringByDeletingLastPathComponent];
    NSString *tempName = [NSString stringWithFormat:@"%@%@%@%@", thePath, @"/temp", theFileName, @".pdf"];
    return tempName;
}


//- (void) imageAnnotation:(NSString *)imagePath
-(void)imageAnnotation:(UIImage *)sig
{
    NSURL* url = [NSURL fileURLWithPath:[self getPDFFileName]];
    
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL ((CFURLRef) url);// 2
    size_t count = CGPDFDocumentGetNumberOfPages (document);// 3
    
    if (count == 0)
    {
        NSLog(@"PDF needs at least one page");
        return;
    }
    
    //CGRect paperSize = CGRectMake(0.0,0.0,595.28,841.89);
    
    CGRect paperSize = CGRectMake(0.0,0.0,612,792);
    
    UIGraphicsBeginPDFContextToFile([self getTempPDFFileName], CGRectZero,nil);//paperSize, nil);
    
    UIGraphicsBeginPDFPageWithInfo(paperSize, nil);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // flip context so page is right way up
    CGContextTranslateCTM(currentContext, 0, paperSize.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CGPDFPageRef page = CGPDFDocumentGetPage (document, 1); // grab page 1 of the PDF
    
    CGContextDrawPDFPage (currentContext, page); // draw page 1 into graphics context
    
    // flip context so annotations are right way up
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, -paperSize.size.height);
    
   //[@"Example annotation" drawInRect:CGRectMake(100.0, 300.0, 200.0, 40.0) withFont:[UIFont systemFontOfSize:18.0]];
    
    //NSLog(@"%@", imagePath);
    
    
    //UIImage *sig = [UIImage imageNamed:imagePath];
    //UIImage *sig = [UIImage imageWithContentsOfFile:imagePath];
    
    //image is 378 x 141
    //CGRect frame = CGRectMake(100,100, 378, 141);
    
    CGRect frame = CGRectMake(100,100, 189, 70);

    
    [sig drawInRect:frame]; // blendMode:kCGBlendModeOverlay alpha:0.5];

    
    
    UIGraphicsEndPDFContext();
    
    CGPDFDocumentRelease (document);
}


-(void)didTapCancelButton {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(signatureCancelled:)]) {
		[self.delegate signatureCancelled:self];
	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clearSignature {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(signatureCleared:signatureController:)]) {
		UIImage *signatureImage = [self.signatureView getSignatureImage];
		[self.delegate signatureCleared:signatureImage signatureController:self];
	}
	
	[self.signatureView clearSignature];
}

/*- (IBAction)btnConfirmClick:(id)sender {
    UIImage* imageToSave = [imgCanvas image];
    NSData *binaryImageData = UIImageJPEGRepresentation(imageToSave,0.0);
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"signature.png"];
    [binaryImageData writeToFile:filePath atomically:YES];
    
    //[binaryImageData writeToFile:[path stringByAppendingPathComponent:@"signature.png"] atomically:YES];
    
}

- (IBAction)btnCancelClick:(id)sender {
    UIImage *acro = [UIImage imageNamed:@"Acroread.png"];
    [self.imgCanvas setImage:acro];
}*/
@end
