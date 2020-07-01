//
//  FaceBookEngine.h
//  SpotWorld
//
//  Created by Abhinav Singh on 13/10/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookAPI.h"

@protocol FaceBookEngineDelegate <NSObject>
@optional
- (void) loggedIn;
- (void) loggedOut;
- (void) userInfoRecived:(UserInfo*)info;
- (void) friendsInfoReceived:(NSMutableArray*) friendsInfo;
- (void) dialogDismissed;
@end


@interface FaceBookEngine : NSObject <FacebookAPIDelegate>{
	
	FacebookAPI *m_faceBookApi;
	id <FaceBookEngineDelegate> delegate;
	BOOL authorizationFailedInternal;
	NSMutableDictionary *dict_feedPost;
}

@property(nonatomic, assign) id <FaceBookEngineDelegate> delegate;
@property(nonatomic, retain) NSMutableDictionary *dict_feedPost;
@property(nonatomic, retain) FacebookAPI* facebookAPI;

- (BOOL) isLoggedIn;
- (void) login;
- (void) logOutCurrentUser;
- (void) postFeed : (NSMutableDictionary*) dictFeed;

@end
