//
//  SignatureView.h
//  RFRSignature
//
//  Created by Ralph Whitten on 11/16/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureView : UIView
// Sets the stroke width
@property(nonatomic) float lineWidth;

// The stroke color
@property(nonatomic,strong) UIColor *foreColor;

// When you get the signature UIIMage, this var
// lets you wrap a point margin around the image.
@property(nonatomic) float signatureImageMargin;

// If YES, the control will crop and center the signature
@property(nonatomic) BOOL shouldCropSignatureImage;



// Returns the signature as a UIImage
-(UIImage *)getSignatureImage;

// Clears the signature from the screen
-(void)clearSignature;

@end
