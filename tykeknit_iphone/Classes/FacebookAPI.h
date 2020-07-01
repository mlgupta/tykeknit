//
//  FacebookAPI.h
//  SpotWorld
//
//  Created by Abhinit Tiwari on 12/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "Session.h"
#import "UserInfo.h" 

@protocol FacebookAPIDelegate <NSObject>

@optional
- (void) facebookDidLogin;
- (void) facebookDidLogout;
- (void) facebookUserInfoDidLoad: (UserInfo*) userInfo;
- (void) facebookFriendInfoDidload: (NSMutableArray*) userInfo;
- (void) facebookUserInfoFailedToLoad;
- (void)publishRequestLoading:(FBRequest*)request;

- (void)publishRequest:(FBRequest*)request didFailWithError:(NSError*)error;

- (void)publishRequest:(FBRequest*)request didLoad:(id)result;

- (void)facebook_dialogDidComplete:(FBDialog *)dialog;

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)facebook_dialogCompleteWithUrl:(NSURL *)url;

/**
 * Called when the dialog get canceled by the user.
 */
- (void)facebook_dialogDidNotCompleteWithUrl:(NSURL *)url;

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)facebook_dialogDidNotComplete:(FBDialog *)dialog ;

/**
 * Called when dialog failed to load due to an error.
 */
- (void)facebook_dialog:(FBDialog*)dialog didFailWithError:(NSError *)error;

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
- (BOOL)facebook_dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url;

- (void) facebook_dialogDidDismiss;

@end


@interface FacebookAPI : NSObject <FBSessionDelegate, UserInfoLoadDelegate, FBDialogDelegate, FBRequestDelegate> {
	Facebook *_facebook;
	Session *_session;
	NSArray *_permissions;
	UserInfo *_userInfo;
	id <FacebookAPIDelegate> _delegate;
}

@property (nonatomic, retain) id<FacebookAPIDelegate> delegate;
@property (nonatomic, retain) Session* session;
@property (nonatomic, retain) UserInfo* userInfo;

- (void) login;
- (void) logout;
- (void) publishToUserStream: (NSDictionary *) publishData;
- (BOOL) isSessionValid;
@end

