
#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "UserRequestResult.h"
#import "FriendsRequestResult.h"

@protocol UserInfoLoadDelegate;

@interface UserInfo : NSObject<UserRequestDelegate, FriendsRequestDelegate> {
	NSString *_uid;
	NSMutableArray * _friendsList;
	NSMutableArray *_friendsInfo;
	Facebook *_facebook;
	id<UserInfoLoadDelegate> _userInfoDelegate; 
	FBRequest *_reqUid;
	FBRequest *_reqFriendList;
	FBRequest *_reqFriendInfo;
	
	NSDictionary *_detailedInfo;
}

@property(nonatomic, retain) id<UserInfoLoadDelegate> userInfoDelegate;
@property(retain, nonatomic) NSString *uid;
@property(retain, nonatomic) NSMutableArray *friendsList;
@property(retain, nonatomic) NSMutableArray *friendsInfo;
@property(retain, nonatomic) NSDictionary *detailedInfo;
@property(retain, nonatomic) Facebook *facebook;

- (void) requestUid;
- (void) requestFriendsDetail;
- (id) initializeWithFacebook:(Facebook *)facebook andDelegate:(id<UserInfoLoadDelegate>)delegate;
- (void) requestAllInfo;

@end

@protocol UserInfoLoadDelegate <NSObject>

- (void)userInfoDidLoad;
- (void)userInfoFailToLoad;
- (void)friendInfoDidLoad: (NSMutableArray *) friendsInfo;
- (void)friendInfoDidFailToLoad;
@end
