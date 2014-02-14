//
//  SignaturePopViewController.h
//  RFRSignature
//
//  Created by Ralph Whitten on 11/14/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignaturePopViewControllerDelegate;

@interface SignaturePopViewController : UIViewController

@property(nonatomic,strong) UIImage *landscapeBackgroundImage;

@property(nonatomic,strong) UIButton *confirmButton, *cancelButton, *clearButton;


@property(nonatomic,weak) id<SignaturePopViewControllerDelegate> delegate;

@property (retain, nonatomic) NSString *fileName;


-(void)clearSignature;


@end

// Delegate Protocol
@protocol SignaturePopViewControllerDelegate <NSObject>

@required

// Called when the user clicks the confirm button
-(void)signatureConfirmed:(UIImage *)signatureImage signatureController:(SignaturePopViewController *)sender;

@optional

// Called when the user clicks the cancel button
-(void)signatureCancelled:(SignaturePopViewController *)sender;

// Called when the user clears their signature or when clearSignature is called.
-(void)signatureCleared:(UIImage *)clearedSignatureImage signatureController:(SignaturePopViewController *)sender;

@end