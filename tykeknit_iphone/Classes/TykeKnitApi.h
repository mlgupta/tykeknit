//
//  TykeKnitApi.h
//  TykeKnit
//
//  Created by Chetan Anarthe on 27/09/10.
//  Copyright 2010 Vercingetorix Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VXTURLRequest.h"
#import "TykeKnitAppDelegate.h"

enum RequestType {
	reqLoginAction,
	reqLogOut,
	reqUserRegister,
	reqForgotPassword,
	reqConfirmationURL,
	reqAddKid,
	reqGetKids,
	reqAddSecRR,
	reqRemoveSecRR,
	reqUploadContacts,
	reqUploadFBContacts,
	reqSetFBIdToken,
	reqInviteUsers,
	reqGetMap,
	reqMarkUserPos,
	reqGetWannaHangStatus,
	reqUpdateWannaHangStatus,
	reqGetChildProf,
	reqGetBuddies,
	reqPlaydateReq,
	reqGetUpcomingPlaydates,
	reqGetPlaydateDetails,
	reqPostWallMsg,
	reqDelWallMsg,
	reqGetMapDetails,
	reqGetUserProfile,
	reqGetUserSettings,
	reqUpdateChildProfile,
	reqUpdateUserProfile,
	reqUpdateSettings,
	reqDeleteAccount,
	joinKnitRequest,
	reqGetInvitations,
	reqGetMessages,
	reqSendMessage,
	reqGetFriends,
	reqGetMessageDetails,
	reqJoinKnitAccept,
	reqGetPlaydateParticipants,
	reqCancelPlaydate,
	reqPostRSVP,
	reqUpdateMessageStatus,
	reqDeleteMessages,
	ZipCodeLatLon,
	reqGetWallMessages,
	reqDeleteUserPic,
	reqDeleteChildPic,
    reqAddEvent,
    reqGetEvents,
    reqGetEventWallMessages,
    reqPostEventWallMessage,
    reqDeleteEventWallMessage
};


@protocol TykeKnitApiDelegate
- (void) noNetworkConnection;
- (void) failWithError : (NSError*) error;
- (void) requestCanceled;
@optional

- (void) dataRecived : (NSData*)data;
- (void) logInResponce : (NSData*)data;
- (void) logOutResponce : (NSData*)data;
- (void) userRegisterResponse : (NSData*)data;
- (void) confirmationURLResponse : (NSData *)data;
- (void) forgotPasswordResponse : (NSData *)data;
- (void) addKidResponse : (NSData*)data;
- (void) getKidsResponse : (NSData*)data;
- (void) addSecondaryRRResponse : (NSData*)data;
- (void) removeSecondaryRRResponse : (NSData*)data;
- (void) uploadContactsResponse : (NSData*)data;
- (void) uploadFBContactsResponse : (NSData*)data;
- (void) setFBIdTokenResponse : (NSData*)data;
- (void) inviteUsersResponse : (NSData*)data;
- (void) getMapResponse : (NSData*)data;
- (void) MarkUserPosResponse : (NSData*)data;
- (void) getChildProfDetailResp : (NSData*)data;
- (void) getBuddiesResp : (NSData*)data;
- (void) playDateRequestResp : (NSData*)data; 
- (void) getPlayDateDetailsResp : (NSData*)data;
- (void) postWallMsgResp : (NSData*)data;
- (void) delWallMsgResp : (NSData*)data;
- (void) getUserProfileResponse : (NSData *)data;
- (void) getUserSettingsResponse : (NSData *)data;
- (void) getWannaHangStatusResponse : (NSData *)data;
- (void) updateWannaHangStatusResponse : (NSData *)data;
- (void) updateUserProfileResponse:(NSData *)data;
- (void) updateChildProfileResponse:(NSData *)data;
- (void) updateSettingsResopnse : (NSData *)data;
- (void) deleteAccountResponse : (NSData *)data;
- (void) upcomingPlaydatesResponse : (NSData *)data;
- (void) joinKnitRequestResponse : (NSData *)data;
- (void) getMapDetailsResponse : (NSData *)data;
- (void) getInvitationsResponse : (NSData *)data;
- (void) getMessagesResponse : (NSData *)data;
- (void) getFriendsResponse : (NSData *)data;
- (void) getMessageDetailsResponse :(NSData *)data;
- (void) getJoinKnitAcceptResponse :(NSData *)data;
- (void) getPlaydateParticipantsResponse : (NSData *)data;
- (void) CancelPlaydateResponse : (NSData *)data;
- (void) sendMessageResponse : (NSData *)data;
- (void) postRSVPResponse : (NSData *)data;
- (void) updateMessageStatusResponse : (NSData *)data;
- (void) deleteMessagesResponse : (NSData *)data;
- (void) latLonRecivedFormZipCode: (NSData*) data;
- (void) getWallMessagesResponse : (NSData *)data;
- (void) deleteUserPicResponse : (NSData *)data; 
- (void) deleteChildPicResponse : (NSData *)data;
- (void) addEventResponse : (NSData *)data;
- (void) getEventsResponse : (NSData *)data;
- (void) getEventWallMessagesResponse : (NSData *)data;
- (void) postEventWallResponse : (NSData *)data;
- (void) deleteEventWallResponse : (NSData *)data;

@end


@interface TykeKnitApi : NSObject<VXTURLRequestDelegate> {

	VXTURLRequest *request;
	id delegate;
	int currentReq;
	BOOL reLoadingData;
	NSString *domain_URL;
    NSString *secure_domain_URL; 
	NSMutableDictionary *dict_currentRequest;
}

@property (nonatomic, retain) NSMutableDictionary *dict_currentRequest;
@property (nonatomic, retain) VXTURLRequest *request;
@property (nonatomic, retain) NSString *domain_URL;
@property (nonatomic, retain) NSString *secure_domain_URL; 
@property (nonatomic, assign) id delegate;

- (void) noNetwork;
- (void) cancelCurrentRequest;
- (void) removeKeyforCurrentRequest;
- (void) reloadCurrentRequest;
- (void) sendRequest : (NSMutableDictionary*) dict;


- (void) userLogin:(NSString*)txtUserID txtPassword:(NSString*)txtPassword txtDToken:(NSString*)txtDToken;
- (void) userLogOut:(NSString*)sessionID;
- (void) forgotPassword:(NSString *)userEmail;
- (void) resendConfirmationURL;
- (void) userRegistration:(NSString*)txtFirstName lastName:(NSString*)txtLastName email:(NSString*)txtEmail pass:(NSString*)txtPassword DOB:(NSString*)txtDOB spouseEmail:(NSString*)txtOPREmail dadMom:(NSString*)txtParentType photo:(NSString*)userPhoto ZIP:(NSString*)txtZIP;
- (void) addKid:(NSString*)txtFirstName lastName:(NSString*)txtLastName DOB:(NSString*)txtDOB photo:(NSString*)userPhoto gender:(NSString*)txtGender;
- (void) getKidList;
- (void) addSecondaryPR:(NSString*)txtEmail;
- (void) removeSecondaryPR:(NSString*)txtEmail;
- (void) uploadContacts:(NSString*)txtContacts isDryRun:(NSString *)dryRun;
- (void) uploadFBContacts:(NSString*)txtContacts;
- (void) setFBIdToken:(NSString*)txtFBId txtFBAuthToken:(NSString *)txtFBAuthToken;
- (void) inviteUsers:(NSString*)txtEmails;
- (void) getWannaHangStatus;
- (void) updateUserProfile : (NSString *)txtFirstName txtLastName:(NSString *)txtLastName txtPassword:(NSString *)txtPassword txtDOB:(NSString *)txtDOB imgFile :(NSString *)imgFile txtParentType:(NSString *)txtParentType txtZipCode : (NSString *)txtZipCode;
- (void) updateChildProfile : (NSString *)txtChildTblPk txtFirstName :(NSString *)txtFirstName txtLastName :(NSString *)txtLastName txtDOB:(NSString *)txtDOB txtGender:(NSString *)txtGender imgFile :(NSString *)imgFile;

- (void) updateWannaHangStatus:(NSString *)txtWannaHangStatus txtMessage:(NSString*)txtMessage;
- (void) getUpcomingPlaydates:(NSString *)noOfResults frowRow:(NSString *)fromRow wantPastPlaydates:(NSString *)wantPastPlaydates;

- (void) getMap:(NSString*)txtLat Longitude:(NSString*)txtLong Radius:(NSString*)txtRadius searchString:(NSString*)txtSearchString count:(NSString*)txtCount start:(NSString*)txtStart;
- (void) markUserPosition:(NSString*)txtLat Longitude:(NSString*)txtLong;
- (void) getChildProfileDetails:(NSString*)cid;
- (void) getBuddies:(NSString*)cid;

- (void) getMapDetails:(NSString *)txtLat Longitude:(NSString *)txtLang Radius:(NSString *)txtRadius;

- (void) playDateRequest:(NSString*)txtOrganiserCid playDateName:(NSString*)txtPlayDateName Location:(NSString *)txtLocation date:(NSString*)txtDate startTime:(NSString*)txtStartTime endTime:(NSString*)txtEndTime message:(NSString*)txtMessage txtInvitees:(NSString*)txtInvitees txtEndDate:(NSString *)txtEndDate; 
- (void) getPlayDateDetails:(NSString*)pid;
- (void) postWallMessage:(NSString*)pid Message:(NSString*)txtMessage;
- (void) deleteWallMessage:(NSString*)messageID;
- (void) deleteAccount;
- (void) deleteUserPic;
- (void) deleteChildPic : (NSString *) child_id;
- (void) addEvent :(NSString *)txtEventTitle txtEventDetail:(NSString *)txtEventDetail txtEventLocation:(NSString *)txtEventLocation;
- (void) getEvents :(NSString *)txtMyEventsFlag txtResultOffset:(NSString *)txtResultOffset txtResultLimit:(NSString *)txtResultLimit;
- (void) getEventWallMessages :(NSString *)txtEventTblPk;
- (void) postEventWallMessage :(NSString *)txtEventTblPk txtEventWallMessage:(NSString *)txtEventWallMessage;
- (void) deleteEventWallMessage :(NSString *)txtMessageId;

- (void) joinKnitRequest:(NSString *)txtToUserTblPk;

- (void) getUserProfile : (NSString *)userId;
- (void) getUserSettings;
- (void) updateSettings : (NSString *)txtUserProfileSetting 
		   whoCanContact:(NSString *)txtUserContactSetting 
	 memberNotifications:(NSString *)boolUserNotificationMembershipRequest 
   playDateNotifications:(NSString *)boolUserNotificationPlaydate 
playdateMessageNotifications:(NSString *)boolUserNotificationPlaydateMessageBoard
generalMessageNotifications:(NSString *)boolUserNotificationGeneralMessages
		locationSettings:(NSString *)boolUserLocationCurrentLocationSetting;
- (void) getLatLongFromZipCode : (NSString*) zipCode;


#pragma mark -
#pragma mark DASHBOARD API CALLS

- (void) getInvitations;
- (void) getMessages;
- (void) getPlaydateParticipants:(NSString *)PlaydateID;
- (void) sendMessage:(NSString *)toUserID txtMessageSubject:(NSString *)txtMessageSubject txtMsgBody:(NSString *)txtMsgBody;
- (void) getFriends;
- (void) getMessageDetails:(NSString *)txtMessageID txtMessageType:(NSString *)txtMessageType;
- (void) joinKnitAccept:(NSString *)invitationID responseCode:(NSString *)YESNOMAYBE;
- (void) cancelPlaydate:(NSString *)playdateID;
- (void) postRSVP:(NSString*)pid RSVPStatus:(NSString*)txtRSVP;
- (void) updateMessageStatus:(NSString *)MessageID txtReadStatus:(NSString *)txtReadStatus;
- (void) deleteMessages:(NSString *)MessageID;
- (void) getWallMessages:(NSString *)playdateID txTime:(NSString *)txtTime;
// get user info
//get notifications
@end
