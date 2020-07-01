//
//  FaceBookEngine.m
//  SpotWorld
//
//  Created by Abhinav Singh on 13/10/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "FaceBookEngine.h"
#import "Global.h"


@implementation FaceBookEngine
@synthesize delegate,dict_feedPost;
@synthesize facebookAPI = m_faceBookApi;

- (id) init {
	self = [super init];
	if (self != nil) {
		m_faceBookApi = [[FacebookAPI alloc] init];
		m_faceBookApi.delegate = self;
	}
	return self;
}

- (BOOL) isLoggedIn {
	
	return [m_faceBookApi.userInfo.facebook isSessionValid];
}

- (void) logOutCurrentUser {
	
	[m_faceBookApi logout];
}

- (void) login {
	
	[m_faceBookApi login];
}

- (void) postFeed : (NSMutableDictionary*) dictFeed {
	self.dict_feedPost = dictFeed;
	[m_faceBookApi publishToUserStream:dictFeed];
}

#pragma mark -
#pragma mark FacebookAPI Delegate methods

- (void) facebookDidLogin {
	
	if (authorizationFailedInternal) {
		authorizationFailedInternal = NO;
		[self postFeed:self.dict_feedPost];
	}
	
	if( [delegate respondsToSelector:@selector(loggedIn)]) {
		[delegate loggedIn];
	}
}

- (void) facebookDidLogout {
	
	if (authorizationFailedInternal) {
		[m_faceBookApi login];
		return;
	}
	
	if([delegate respondsToSelector:@selector(loggedOut)]) {
		[delegate loggedOut];
	}
}

- (void) facebookUserInfoDidLoad: (UserInfo*) userInfo {
	NSLog(@"User info %@", userInfo.uid);
	
	if( [delegate respondsToSelector:@selector(userInfoRecived:)]) {
		[delegate userInfoRecived:userInfo];
	}
}

- (void) facebook_dialogDidDismiss {
	
	if (authorizationFailedInternal) {
		authorizationFailedInternal = NO;
		self.dict_feedPost = nil;
		return;
	}
	
	if( [delegate respondsToSelector:@selector(dialogDismissed)]) {
		[delegate dialogDismissed];
	}
	
}

- (void)publishRequest:(FBRequest*)request didFailWithError:(NSError*)error {
	
	if ([[[error.userInfo objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"] && [request.url isEqualToString:@"https://graph.facebook.com/me/feed"]) {
		authorizationFailedInternal = YES;
		[m_faceBookApi logout];
	}
}

- (void) facebookFriendInfoDidload: (NSMutableArray*) friendsInfo {
	NSLog(@"fris info %@", friendsInfo);
	
	if( [delegate respondsToSelector:@selector(friendsInfoReceived:)]) {
		[delegate friendsInfoReceived:friendsInfo];
	}
}

- (void) facebookUserInfoFailedToLoad {
	NSLog(@"facebookUserInfoFailedToLoad");
}

- (void)publishRequestLoading:(FBRequest*)request {
	
	NSLog(@"publishRequestLoading");
}

- (void)publishRequest:(FBRequest*)request didLoad:(id)result {
	
	NSLog(@"Result %@", result);
	NSLog(@"publishRequest");
	self.dict_feedPost = nil;
}

- (void)facebook_dialogDidComplete:(FBDialog *)dialog {
	
	NSLog(@"facebook_dialogDidComplete");
}

- (void)facebook_dialogCompleteWithUrl:(NSURL *)url {
	
	NSLog(@"facebook_dialogCompleteWithUrl");
}

- (void)facebook_dialogDidNotCompleteWithUrl:(NSURL *)url {
	
	NSLog(@"facebook_dialogDidNotCompleteWithUrl");
}

- (void)facebook_dialogDidNotComplete:(FBDialog *)dialog  {
	NSLog(@"facebook_dialogDidNotComplete");
}

- (void)facebook_dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
	
	NSLog(@"didFailWithError");
}

- (BOOL)facebook_dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
	
	NSLog(@"shouldOpenURLInExternalBrowser");
	return YES;
}


- (void)dealloc {
	self.delegate = nil;
	[dict_feedPost release];
	[self.facebookAPI release];
    [super dealloc];
}


@end
