//
//  FacebookAPI.m
//  SpotWorld
//
//  Created by Abhinit Tiwari on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookAPI.h"

static NSString *faceBookAppID = @"191737580851914";
//static NSString *faceBookApiKey = @"617f8588ea1de65f90b4effe5c4bc9f0";
//static NSString *faceBookSecretKey = @"bfde2b414092a5d06accea137e3c466f";

@implementation FacebookAPI
@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;
@synthesize session = _session;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Private helper function for login / logout

- (void) login {
	[_facebook authorize:faceBookAppID permissions:_permissions delegate:self];
}

- (void) logout {
	[_session unsave];
	[_facebook logout:self]; 
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Public

- (BOOL) isSessionValid {
	return [_facebook isSessionValid];
}

- (id)init {
	if ((self = [super init])) {
		_permissions =  [[NSArray arrayWithObjects: 
						  @"publish_stream",@"read_stream", @"read_friendlists", @"offline_access", @"email", @"user_about_me", @"friends_about_me", nil] retain];
		
		_session = [[Session alloc] init];
		_facebook = [[_session restore] retain];
		if (_facebook == nil) {
			_facebook = [[Facebook alloc] init];
			_facebook.sessionDelegate = self;
		} else {
			[self fbDidLogin];
		}
	}
	return self;
}

/*
 The dictionary publishData must contain:
 message:	The message
 picture:	If available, a link to the picture included with this post
 link:	The link attached to this post
 name:	The name of the link
 caption:	The caption of the link (appears beneath the link name)
 description:	A description of the link (appears beneath the link caption)
 source:	If available, the source link attached to this post (for example, a flash or video file)
 
 All parameters are REQUIRED. If something is not available set it to nil.
 
 Eg: 
 
 NSDictionary *publishData = [NSDictionary dictionaryWithObjectsAndKeys:
 @"SpotWorld Update", @"message", 
 <image link here>, @"picture", 
 @"some link here", @"link",
 @"Name that will show in 'link' above'", @"name",
 @"Caption goes here", @"caption",
 @"This is a dummy description.", @"description",
 <image link here>, @"source",
 nil];
 */

- (void) publishToUserStream: (NSDictionary *) publishData {
	//message, picture, link, name, caption, description, source
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								   [publishData objectForKey:@"message"], @"message",
								   [publishData objectForKey:@"picture"], @"picture", 
								   [publishData objectForKey:@"link"], @"link",
								   [publishData objectForKey:@"name"], @"name",
								   [publishData objectForKey:@"caption"], @"caption",
								   [publishData objectForKey:@"description"], @"description",
								   [publishData objectForKey:@"source"], @"source",
								   nil];
	
	[_facebook requestWithGraphPath:@"me/feed"
						  andParams:params  
					  andHttpMethod:@"POST"
						andDelegate:self];
	
		
}

#pragma mark -
#pragma mark Delegates

/**
 * FBDialogDelegate :dialogCompleteWithUrl
 *
 */

- (void)dialogDidComplete:(FBDialog *)dialog {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebook_dialogDidComplete:)]) {
		[_delegate facebook_dialogDidComplete:dialog];
	}
}

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebook_dialogDidCompleteWithUrl:)]) {
		[_delegate facebook_dialogCompleteWithUrl:url];
	}
}

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebook_dialogDidNotCompleteWithUrl:)]) {
		[_delegate facebook_dialogDidNotCompleteWithUrl:url];
	}
	
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebook_dialogDidNotComplete:)]) {
		[_delegate facebook_dialogDidNotComplete:dialog];
	}
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebook_dialog:didFailWithError:)]) {
		[_delegate facebook_dialog:dialog didFailWithError:error];
	}
}

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser, 
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
	//Handle URL here
	
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebook_dialog:shouldOpenURLInExternalBrowser:)]) {
		return [_delegate facebook_dialog:dialog shouldOpenURLInExternalBrowser:url];
	} else {
		return YES;
	}
	
}


/**
 * FBSessionDelegate
 */ 
-(void) fbDidLogin {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebookDidLogin)]) {
		[_delegate facebookDidLogin];
	}
	
	_userInfo = [[[[UserInfo alloc] initializeWithFacebook:_facebook andDelegate: self] 
				  autorelease]
				 retain];
	[_userInfo requestAllInfo];
}

/**
 * FBSessionDelegate
 */ 
-(void) fbDidLogout {
	[_session unsave];
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebookDidLogout)]) {
		[_delegate facebookDidLogout];
	}
}

-(void) fbDidNotLogin:(BOOL) cancelled {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebook_dialogDidDismiss)] && cancelled) {
		[_delegate facebook_dialogDidDismiss];
	}
}

/*
 * UserInfoLoadDelegate
 */
- (void)userInfoDidLoad {
	[_session setSessionWithFacebook:_facebook andUid:_userInfo.uid];
	[_session save];
	
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebookUserInfoDidLoad:)]) {
		[_delegate facebookUserInfoDidLoad:_userInfo];
	}
	
}
- (void)friendInfoDidLoad: (NSMutableArray*) friendsInfo {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebookFriendInfoDidload:)]) {
		[_delegate facebookFriendInfoDidload:friendsInfo];
	}
}

- (void)userInfoFailToLoad {
	[self logout]; 
	if(_delegate != nil && [_delegate respondsToSelector:@selector(facebookUserInfoFailedToLoad)]) {
		[_delegate facebookUserInfoFailedToLoad];
	}
}

/*
 * FBRequestDelegates
 */

- (void)requestLoading:(FBRequest*)request {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(publishRequestLoading:)]) {
		[_delegate publishRequestLoading:request];
	}
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(publishRequest:didFailWithError:)]) {
		[_delegate publishRequest:request didFailWithError:error];
	}
}

- (void)request:(FBRequest*)request didLoad:(id)result {
	if(_delegate != nil && [_delegate respondsToSelector:@selector(publishRequest:didLoad:)]) {
		[_delegate publishRequest:request didLoad:result];
	}
}

- (void)friendInfoDidFailToLoad {
	
} 

- (void)dealloc {
	[_facebook release];
	[_permissions release];
	[_userInfo release];
	[super dealloc];
}

@end