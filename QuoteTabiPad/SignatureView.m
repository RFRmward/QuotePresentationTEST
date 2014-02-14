//
//  SignatureView.m
//  RFRSignature
//
//  Created by Ralph Whitten on 11/16/13.
//  Copyright (c) 2013 Ralph Whitten. All rights reserved.
//

#import "SignatureView.h"
#import <QuartzCore/QuartzCore.h>


@interface SignatureView() {
    
@private
	__strong NSMutableArray *handwritingCoords_;
	__weak UIImage *currentSignatureImage_;
	float lineWidth_;
	float signatureImageMargin_;
	BOOL shouldCropSignatureImage_;
	__strong UIColor *foreColor_;
	CGPoint lastTapPoint_;
}

@property(nonatomic,strong) NSMutableArray *handwritingCoords;

-(void)processPoint:(CGPoint)touchLocation;

@end

@implementation SignatureView

@synthesize
handwritingCoords = handwritingCoords_,
lineWidth = lineWidth_,
signatureImageMargin = signatureImageMargin_,
shouldCropSignatureImage = shouldCropSignatureImage_,
foreColor = foreColor_;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.handwritingCoords = [[NSMutableArray alloc] init];
		self.lineWidth = 5.0f;
		self.signatureImageMargin = 10.0f;
		self.shouldCropSignatureImage = YES;
		self.foreColor = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
		lastTapPoint_ = CGPointZero;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(context, self.lineWidth);
	CGContextSetStrokeColorWithColor(context, [self.foreColor CGColor]);
	CGContextSetLineCap(context, kCGLineCapButt);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextBeginPath(context);
	
	BOOL isFirstPoint = YES;
	
	
	for (NSString *touchString in self.handwritingCoords) {
		
		CGPoint tapLocation = CGPointFromString(touchString);
		
		
		if (CGPointEqualToPoint(tapLocation, CGPointZero)) {
			isFirstPoint = YES;
			continue;
		}
		
		if (isFirstPoint) {
			CGContextMoveToPoint(context, tapLocation.x, tapLocation.y);
			isFirstPoint = NO;
		} else {
			CGPoint startPoint = CGContextGetPathCurrentPoint(context);
			CGContextAddQuadCurveToPoint(context,
                                         startPoint.x,
                                         startPoint.y,
                                         tapLocation.x,
                                         tapLocation.y);
			CGContextAddLineToPoint(context,
                                    tapLocation.x,
                                    tapLocation.y);
		}
		
	}
	
	CGContextStrokePath(context);
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self];
	
	[self processPoint:touchLocation];
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.handwritingCoords addObject:NSStringFromCGPoint(CGPointZero)];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.handwritingCoords addObject:NSStringFromCGPoint(CGPointZero)];
}



-(void)processPoint:(CGPoint)touchLocation {
	
	// Only keep the point if it's > 5 points from the last
	if (CGPointEqualToPoint(CGPointZero, lastTapPoint_) ||
		fabs(touchLocation.x - lastTapPoint_.x) > 2.0f ||
		fabs(touchLocation.y - lastTapPoint_.y) > 2.0f) {
		
		[self.handwritingCoords addObject:NSStringFromCGPoint(touchLocation)];
		[self setNeedsDisplay];
		lastTapPoint_ = touchLocation;
		
	}
	
}


#pragma mark - *** Public Methods ***

/**
 * Returns a UIImage with the signature cropped and centered with the margin
 * specified in the signatureImageMargin property.
 * @author Jesse Bunch
 **/
-(UIImage *)getSignatureImage {
	
	// Grab the image
	UIGraphicsBeginImageContext(self.bounds.size);
	[self drawRect: self.bounds];
	UIImage *signatureImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Stop here if we're not supposed to crop
	if (!self.shouldCropSignatureImage) {
		return signatureImage;
	}
	
	// Crop bound floats
	// Give really high limits to min values so at least one tap
	// location will be set as the minimum...
	float minX = 99999999.0f, minY = 999999999.0f, maxX = 0.0f, maxY = 0.0f;
	
	// Loop through current coordinates to get the crop bounds
	for (NSString *touchString in self.handwritingCoords) {
		
		// Unserialize
		CGPoint tapLocation = CGPointFromString(touchString);
		
		// Ignore CGPointZero
		if (CGPointEqualToPoint(tapLocation, CGPointZero)) {
			continue;
		}
		
		// Set boundaries
		if (tapLocation.x < minX) minX = tapLocation.x;
		if (tapLocation.x > maxX) maxX = tapLocation.x;
		if (tapLocation.y < minY) minY = tapLocation.y;
		if (tapLocation.y > maxY) maxY = tapLocation.y;
		
	}
	
	// Crop to the bounds (include a margin)
	CGRect cropRect = CGRectMake(minX - lineWidth_ - self.signatureImageMargin,
								 minY - lineWidth_ - self.signatureImageMargin,
								 maxX - minX + (lineWidth_ * 2.0f) + (self.signatureImageMargin * 2.0f),
								 maxY - minY + (lineWidth_ * 2.0f) + (self.signatureImageMargin * 2.0f));
	CGImageRef imageRef = CGImageCreateWithImageInRect([signatureImage CGImage], cropRect);
	
	// Convert back to UIImage
	UIImage *signatureImageCropped = [UIImage imageWithCGImage:imageRef];
	
	// All done!
	CFRelease(imageRef);
	return signatureImageCropped;
	
}

/**
 * Clears any drawn signature from the screen
 * @author Jesse Bunch
 **/
-(void)clearSignature {
	
	[self.handwritingCoords removeAllObjects];
	[self setNeedsDisplay];
	
}

@end
