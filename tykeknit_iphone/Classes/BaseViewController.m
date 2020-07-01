    //
//  BaseViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 30/11/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "BaseViewController.h"
#import "Global.h"

@implementation BaseViewController
@synthesize vi_main, prevContImage,vi_rootViewController;

- (void) BringFrontSubViews {
	[self.vi_main bringSubviewToFront:vi_rings];
}

- (UIImage*) captureScreen {
	
	UIGraphicsBeginImageContext(self.vi_main.frame.size);
	[self.vi_main.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return viewImage;
}

/*
- (void) popWannaHang {
	[UIView beginAnimations:@"popViewCont" context:NULL];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[DELEGATE topNavigationController].view cache:NO];
	[UIView setAnimationDuration:PAGE_FLIP_DURATION];
	[UIView setAnimationDelegate:self];
	[[DELEGATE topNavigationController] popViewControllerAnimated:NO];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView commitAnimations];
}
- (void) pushWannaHang {
	[UIView beginAnimations:@"pushingViewCont" context:NULL];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[DELEGATE topNavigationController].view cache:NO];
	[UIView setAnimationDuration:PAGE_FLIP_DURATION];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView commitAnimations];
}
*/

- (void) pushingViewController : (UIImage*)imag{

	UIView *viMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	viMain.tag = 3344;
	viMain.backgroundColor = [UIColor clearColor];
	[[DELEGATE window] addSubview:viMain];
	[viMain release];
	
	UIView *vi_shadow = [[UIView alloc] initWithFrame:CGRectMake(-17, 64, 297, 416)];
	vi_shadow.layer.cornerRadius = 17.0f;
	vi_shadow.backgroundColor = [UIColor blackColor];
	vi_shadow.alpha = 0.5f;
	[viMain addSubview:vi_shadow];
	[vi_shadow release];
	
	UIImageView *viImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, imag.size.width, 416)];
	viImage.backgroundColor = [UIColor clearColor];
	viImage.layer.cornerRadius = 12.0f;
	viImage.image = imag;
	[viMain addSubview:viImage];
	[viImage release];
	
	CALayer *aniLayer = viImage.layer;
	CGRect rectOrig = viImage.frame;
	aniLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	viImage.frame = rectOrig;
	
	CABasicAnimation *topAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	topAnim.removedOnCompletion = YES;
	topAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 0)];
	topAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	topAnim.duration = PAGE_FLIP_DURATION;
	
	topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(degreesToRadians(-100), 0, 0.1, 0)];
	[aniLayer addAnimation:topAnim forKey:@"animatePush"];
	aniLayer.transform = CATransform3DMakeRotation(degreesToRadians(-100), 0, 0.1, 0);
	
	[UIView beginAnimations:@"pushingViewCont" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:PAGE_FLIP_DURATION+0.2];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[vi_shadow setFrame:CGRectMake(-17, 64, 17, 416)];
	[UIView commitAnimations];
}

- (void) popToViewController : (UIViewController *) viewController {
	
	UIImage *img;
	int index =0;
	if (viewController==nil) {
		img = [[[self.navigationController viewControllers] objectAtIndex:1] prevContImage];
		self.vi_rootViewController = [[self.navigationController viewControllers] objectAtIndex:0];
	}
	else {
		index = [[self.navigationController viewControllers] indexOfObject:viewController];
		img = [[[self.navigationController viewControllers]objectAtIndex:index+1] prevContImage];
		self.vi_rootViewController = [[self.navigationController viewControllers]objectAtIndex:index];
	}
	
	UIView *viMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	viMain.tag = 3344;
	viMain.backgroundColor = [UIColor clearColor];
	
	UIView *vi_shadow = [[UIView alloc] initWithFrame:CGRectMake(-17, 64, 17, 416)];
	vi_shadow.layer.cornerRadius = 17.0f;
	vi_shadow.alpha = 0.5f;
	vi_shadow.backgroundColor = [UIColor blackColor];
	[viMain addSubview:vi_shadow];
	[vi_shadow release];
	UIImageView *viImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 280, 416)];
	viImage.layer.cornerRadius = 12.0f;
	viImage.image = img;
	[viMain addSubview:viImage];
	[viImage release];
	
	[[DELEGATE window] addSubview:viMain];
	[viMain release];
	
	//Animation to the image view
	CALayer *aniLayer = viImage.layer;
	CGRect rectOrig = viImage.frame;
	aniLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	viImage.frame = rectOrig;
	aniLayer.transform = CATransform3DMakeRotation(degreesToRadians(-100), 0, 0.1, 0);
	
	CABasicAnimation *topAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	topAnim.removedOnCompletion = YES;
	topAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(degreesToRadians(-100), 0, 0.1, 0)];
	topAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	topAnim.duration = PAGE_FLIP_DURATION;
	
	topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 0)];
	[aniLayer addAnimation:topAnim forKey:@"animate"];
	aniLayer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 0);
	
	//Animation to the shadow view
	[UIView beginAnimations:@"popToViewCont" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:PAGE_FLIP_DURATION-0.2];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[vi_shadow setFrame:CGRectMake(-17, 64, 297, 416)];
	[UIView commitAnimations];
	
	//TODO: Animate the right and left bar button if they are
}

- (void) popViewController {
	
	UIView *viMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	viMain.tag = 3344;
	viMain.backgroundColor = [UIColor clearColor];
	
	UIView *vi_shadow = [[UIView alloc] initWithFrame:CGRectMake(-17, 64, 17, 416)];
	vi_shadow.layer.cornerRadius = 17.0f;
	vi_shadow.alpha = 0.5f;
	vi_shadow.backgroundColor = [UIColor blackColor];
	[viMain addSubview:vi_shadow];
	[vi_shadow release];
	
	UIImageView *viImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 280, 416)];
	viImage.layer.cornerRadius = 12.0f;
	viImage.image = self.prevContImage;
	[viMain addSubview:viImage];
	[viImage release];
	
	[[DELEGATE window] addSubview:viMain];
	[viMain release];
	
	//Animation to the image view
	CALayer *aniLayer = viImage.layer;
	CGRect rectOrig = viImage.frame;
	aniLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	viImage.frame = rectOrig;
	aniLayer.transform = CATransform3DMakeRotation(degreesToRadians(-100), 0, 0.1, 0);
	
	CABasicAnimation *topAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	topAnim.removedOnCompletion = YES;
	topAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(degreesToRadians(-100), 0, 0.1, 0)];
	topAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	topAnim.duration = PAGE_FLIP_DURATION;
	
	topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 0)];
	[aniLayer addAnimation:topAnim forKey:@"animate"];
	aniLayer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 0);
	
	//Animation to the shadow view
	[UIView beginAnimations:@"popViewCont" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:PAGE_FLIP_DURATION-0.2];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[vi_shadow setFrame:CGRectMake(-17, 64, 297, 416)];
	[UIView commitAnimations];
	
	//TODO: Animate the right and left bar button if they are
}

- (void) animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
	
	if ([animationID isEqualToString:@"pushingViewCont"]) {
		[[[DELEGATE window] viewWithTag:3344] removeFromSuperview];
	}else if([animationID isEqualToString:@"popViewCont"]) {
		[[[DELEGATE window] viewWithTag:3344] removeFromSuperview];
		[self.navigationController popViewControllerAnimated:NO];
	}else if ([animationID isEqualToString:@"popToViewCont"]) {
		[[[DELEGATE window] viewWithTag:3344] removeFromSuperview];
		[self.navigationController popToViewController:self.vi_rootViewController animated:NO];
	}
}

- (void) viewDidLoad {
	showingHangView = NO;
	
	[self.view addSubview:self.vi_main];
	[self.view setBackgroundColor:[UIColor darkTextColor]];
	
	vi_rings = [[UIImageView alloc] initWithFrame:CGRectMake(-2, 89, 26, 235)];
//	vi_rings.backgroundColor = [UIColor redColor];
	vi_rings.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"binder_rings")];
	vi_rings.contentMode = UIViewContentModeScaleToFill;
	[self.vi_main addSubview:vi_rings];
	[vi_rings release];
	
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
	
	[self BringFrontSubViews];
	[super viewWillAppear:animated];
}

#pragma mark -
#pragma mark LeavesViewDataSource

- (void)dealloc {
    [super dealloc];
}

@end
