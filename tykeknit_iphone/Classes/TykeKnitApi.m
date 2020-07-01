//
//  TykeKnitApi.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 27/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TykeKnitApi.h"
#import "Global.h"
#import "VXTURLRequestQueue.h"
#import "VXTURLResponse.h"
#import "VXTURLRequest.h"
#import "Messages.h"
#import "BaseViewController.h"
#import "NSDataAdditions.h"
#import "NSString+SBJSON.h"

@implementation TykeKnitApi
@synthesize delegate, request, dict_currentRequest,domain_URL,secure_domain_URL;

- (id) init {
	if (self == [super init]) {
	NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
        if ([bundleIdentifier isEqualToString:@"com.tykeknit.tykeknit.beta"]) {
            self.domain_URL = @"http://dev.tykeknit.com/api";
            self.secure_domain_URL = @"http://dev.tykeknit.com/api";
        } else if ([bundleIdentifier isEqualToString:@"com.tykeknit.tykeknit"]) {
            self.domain_URL = @"http://api.tykeknit.com/api";
            self.secure_domain_URL = @"http://api.tykeknit.com/api";        
        } else {
            self.domain_URL = @"http://api.tykeknit.com/api";
            self.secure_domain_URL = @"http://api.tykeknit.com/api";        
        }
		delegate = nil;
	}
	return self;
}

- (void) cancelCurrentRequest {
	currentReq = -1;	
	[[VXTURLRequestQueue mainQueue] cancelRequest:self.request];
}

- (void) removeKeyforCurrentRequest {
	[[VXTCache sharedCache] removeKey:[self.request cacheKey]];
}

- (void) reloadCurrentRequest {
	
	[self removeKeyforCurrentRequest];
	[self sendRequest:self.dict_currentRequest];
}

- (void) sendRequest : (NSMutableDictionary*) dict {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (self.dict_currentRequest && ![self.dict_currentRequest isEqual:dict]) {
		[self.dict_currentRequest release];
		self.dict_currentRequest = nil;
	}
	self.dict_currentRequest = [dict retain];
	
	currentReq = [[dict objectForKey:@"CurrentRequest"] intValue];
	
	if([DELEGATE hasNetworkConnection]) {
		VXTNetworkRequestStarted();
		self.request = [[[VXTURLRequest alloc] initWithURL:[dict objectForKey:@"URL"] delegate:self] autorelease];
		
		if (currentReq != 100) {
			[[VXTURLRequestQueue mainQueue] cancelAllRequests];
		}

		if (reLoadingData) {
			self.request.cachePolicy = VXTURLRequestCachePolicyNone;
		}else {
			self.request.cachePolicy = [[dict objectForKey:@"CachePolicy"] intValue];
			if (self.request.cachePolicy == VXTURLRequestCachePolicyDisk) {
				self.request.cacheExpirationAge = Cache_Default_Time;
			}
		}
		
		self.request.response = [[[VXTURLDataResponse alloc] init] autorelease];
		self.request.httpMethod = [dict objectForKey:@"Method"];
		
		NSDictionary *dictParam = [dict objectForKey:@"Parameters"];
		if (dictParam) {
			for (NSString *paramKey in [dictParam allKeys]) {
				if ([paramKey isEqualToString:@"sessionID"]) {
					if ([[DELEGATE dict_userInfo] objectForKey:@"sessionID"]) {
						[self.request.parameters setObject:[[DELEGATE dict_userInfo] objectForKey:@"sessionID"] forKey:@"sessionID"];
					}
				}else {
					[self.request.parameters setObject:[dictParam objectForKey:paramKey] forKey:paramKey];
				}
			}
		}
		self.request.shouldHandleCookies = YES;
		[self.request send];
		
	}else {
		[self noNetwork];
	}
	
	[pool release];
}

#pragma mark -
#pragma mark Tested Api

- (void) userRegistration:(NSString*)txtFirstName lastName:(NSString*)txtLastName email:(NSString*)txtEmail pass:(NSString*)txtPassword DOB:(NSString*)txtDOB spouseEmail:(NSString*)txtOPREmail dadMom:(NSString*)txtParentType photo:(NSString*)userPhoto ZIP:(NSString*)txtZIP{
	
	NSString *URL = [NSString stringWithFormat:@"%@/register.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUserRegister] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtFirstName forKey:@"txtFirstName"];
	[param setObject:txtLastName forKey:@"txtLastName"];
	[param setObject:txtEmail forKey:@"txtEmail"];
	[param setObject:txtPassword forKey:@"txtPassword"];

	if (txtDOB) {
        [param setObject:txtDOB forKey:@"txtDOB"];
    }
//	[param setObject:txtParentType forKey:@"txtParentType"];
	
	if (txtOPREmail) {
		[param setObject:txtOPREmail forKey:@"txtOPREmail"];
	}
	
	if (userPhoto) {
		
		UIImage *imgFile = [UIImage imageWithContentsOfFile:userPhoto];
		if (imgFile) {
			[param setObject:imgFile forKey:@"imgFile"];
		}
//		NSData *imgData = UIImageJPEGRepresentation(imgFile, 0.4);
//		NSLog(@"Image Data %d", [imgData length]);
		
	}
	
	if (txtZIP) {
		[param setObject:txtZIP forKey:@"txtZip"];
	}
	
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) userLogin:(NSString*)txtUserID txtPassword:(NSString*)txtPassword txtDToken:(NSString *)txtDToken{
	
	NSString *URL = [NSString stringWithFormat:@"%@/LoginAction.do", self.secure_domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqLoginAction] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtUserID forKey:@"txtUserId"];
	[param setObject:txtPassword forKey:@"txtPassword"];
    if (txtDToken) {
        [param setObject:txtDToken forKey:@"txtDToken"];
    }
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) forgotPassword:(NSString *)userEmail {
	NSString *URL = [NSString stringWithFormat:@"%@/sendForgottenPassword.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqForgotPassword] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:userEmail forKey:@"txtUserId"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) resendConfirmationURL {
	NSString *URL = [NSString stringWithFormat:@"%@/resendConfirmationURL.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqConfirmationURL] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) addKid:(NSString*)txtFirstName lastName:(NSString*)txtLastName DOB:(NSString*)txtDOB 
		  photo:(NSString*)userPhoto gender:(NSString*)txtGender {
	
	NSString *URL = [NSString stringWithFormat:@"%@/addKid.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqAddKid] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];

	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtFirstName forKey:@"txtFirstName"];
	[param setObject:txtLastName forKey:@"txtLastName"];
	[param setObject:txtDOB forKey:@"txtDOB"];
	[param setObject:txtGender forKey:@"txtGender"];
	
	if (userPhoto) {
		UIImage *imgData = [UIImage imageWithContentsOfFile:userPhoto];
		if (imgData) {
			[param setObject:imgData forKey:@"binPhoto"];
		}
	}
	
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getUpcomingPlaydates:(NSString *)noOfResults frowRow:(NSString *)fromRow wantPastPlaydates:(NSString *)wantPastPlaydates {
    
	NSString *URL = [NSString stringWithFormat:@"%@/getDBActivities.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetUpcomingPlaydates] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:noOfResults forKey:@"txtResultLimit"];
	[param setObject:fromRow forKey:@"txtResultOffset"];
	[param setObject:wantPastPlaydates forKey:@"txtPastActivitiesFlag"];
	
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getKidList {
	
	NSString *URL = [NSString stringWithFormat:@"%@/listKids.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetKids] forKey:@"CurrentRequest"];
	[dict setObject:@"GET" forKey:@"Method"];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getUserProfile : (NSString *)userId {

	NSString *URL = [NSString stringWithFormat:@"%@/getUserProfile.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetUserProfile] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:userId forKey:@"txtUserTblPk"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getUserSettings {
	
	NSString *URL = [NSString stringWithFormat:@"%@/getUserSettings.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetUserSettings] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) updateChildProfile : (NSString *)txtChildTblPk txtFirstName :(NSString *)txtFirstName txtLastName :(NSString *)txtLastName txtDOB:(NSString *)txtDOB txtGender:(NSString *)txtGender imgFile :(NSString *)imgFile {

	NSString *URL = [NSString stringWithFormat:@"%@/updateKid.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUpdateChildProfile] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtChildTblPk forKey:@"txtChildTblPk"];
	[param setObject:txtFirstName forKey:@"txtFirstName"];
	[param setObject:txtLastName forKey:@"txtLastName"];
	[param setObject:txtDOB forKey:@"txtDOB"];
	[param setObject:txtGender forKey:@"txtGender"];
	if (imgFile) {
		UIImage *img = [UIImage imageWithContentsOfFile:imgFile];
		if (img) {
			[param setObject:img forKey:@"imgFile"];
		}
	}
	
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) updateUserProfile : (NSString *)txtFirstName txtLastName:(NSString *)txtLastName txtPassword:(NSString *)txtPassword txtDOB:(NSString *)txtDOB imgFile :(NSString *)imgFile txtParentType:(NSString *)txtParentType txtZipCode : (NSString *)txtZipCode {
	NSString *URL = [NSString stringWithFormat:@"%@/updateUser.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUpdateUserProfile] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtFirstName forKey:@"txtFirstName"];
	[param setObject:txtLastName forKey:@"txtLastName"];
	[param setObject:txtDOB forKey:@"txtDOB"];
	[param setObject:txtParentType forKey:@"txtParentType"];
	[param setObject:txtZipCode forKey:@"txtZip"];

	if ([txtPassword length]) {
		[param setObject:txtPassword forKey:@"txtPassword"];
	}else {
		[param setObject:@"" forKey:@"txtPassword"];
	}

	if (imgFile) {
		
		UIImage *img = [UIImage imageWithContentsOfFile:imgFile];
//		NSLog(@"Image %@", imgFile);
		if (img) {
///		NSData *imgData = UIImageJPEGRepresentation(img, 0.4);
		//		NSLog(@"Image Data %d", [imgData length]);
			[param setObject:img forKey:@"imgFile"];
		}
	}

	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) addSecondaryPR:(NSString*)txtEmail {
	
	NSString *URL = [NSString stringWithFormat:@"%@/addSecondaryPR.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqAddSecRR] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtEmail forKey:@"txtEmail"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) removeSecondaryPR:(NSString*)txtEmail {
	
	NSString *URL = [NSString stringWithFormat:@"%@/removeSecondaryPR.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqRemoveSecRR] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:@"" forKey:@"sessionID"];
	[param setObject:txtEmail forKey:@"txtEmail"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) uploadContacts:(NSString*)txtContacts isDryRun:(NSString *)dryRun {
	
	NSString *URL = [NSString stringWithFormat:@"%@/uploadContacts.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUploadContacts] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtContacts forKey:@"txtContacts"];
	[param setObject:dryRun forKey:@"txtDryRunFlag"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) uploadFBContacts:(NSString*)txtContacts {
	
	NSString *URL = [NSString stringWithFormat:@"%@/uploadFBContacts.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUploadFBContacts] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtContacts forKey:@"txtContacts"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) setFBIdToken:(NSString*)txtFBId txtFBAuthToken:(NSString *)txtFBAuthToken {
	
	NSString *URL = [NSString stringWithFormat:@"%@/setFBIdToken.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqSetFBIdToken] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtFBId forKey:@"txtFBId"];
	[param setObject:txtFBAuthToken forKey:@"txtFBAuthToken"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}


- (void) inviteUsers:(NSString*)txtEmails {
	
	NSString *URL = [NSString stringWithFormat:@"%@/inviteUsers.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqInviteUsers] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtEmails forKey:@"txtEmails"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) updateWannaHangStatus:(NSString *)txtWannaHangStatus txtMessage:(NSString*)txtMessage{
	NSString *URL = [NSString stringWithFormat:@"%@/setDBWannaHang.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUpdateWannaHangStatus] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtWannaHangStatus forKey:@"txtDBWannaHangStatus"];
    if (!txtMessage || [txtMessage isEqualToString:@"(null)"]) {
    }
    else {
      [param setObject:txtMessage forKey:@"txtMessage"];
    }
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) getWannaHangStatus {
	NSString *URL = [NSString stringWithFormat:@"%@/getDBWannaHang.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetWannaHangStatus] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) getMapDetails:(NSString *)txtLat Longitude:(NSString *)txtLong Radius:(NSString *)txtRadius {

	NSString *URL = [NSString stringWithFormat:@"%@/getMap.do",self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetMapDetails] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtLat forKey:@"txtLat"];
	[param setObject:txtLong forKey:@"txtLong"];
	[param setObject:txtRadius forKey:@"txtRadius"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getMap:(NSString*)txtLat Longitude:(NSString*)txtLong Radius:(NSString*)txtRadius searchString:(NSString*)txtSearchString count:(NSString*)txtCount start:(NSString*)txtStart {
	
	
	NSString *genderCode = nil;
	NSString *ageCode = nil;
	NSString *degreeCode = nil;
	
	NSMutableArray *arrGender = [NSMutableArray arrayWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultGenderArray.plist"]];
	if (!arrGender) {
		arrGender = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultGenderArray" ofType:@"plist"]];
	}
	
	for (NSDictionary *dictGen in arrGender) {
		if ([[dictGen objectForKey:@"selected"] intValue]) {
			genderCode = [dictGen objectForKey:@"selectionCode"];
			break;
		}
	}
	
	NSMutableArray *arrAge = [NSMutableArray arrayWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultAgeArray.plist"]];
	if (!arrAge) {
		arrAge = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultAgeArray" ofType:@"plist"]];
	}
	
	for (NSDictionary *dictAge in arrAge) {
		if ([[dictAge objectForKey:@"selected"] intValue]) {
			ageCode = [dictAge objectForKey:@"selectionCode"];
			break;
		}
	}
	
	NSMutableArray *arrDegree = [NSMutableArray arrayWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultDegreeArray.plist"]];
	if (!arrDegree) {
		arrDegree = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultDegreeArray" ofType:@"plist"]];
	}
	
	for (NSDictionary *dictdeg in arrDegree) {
		if ([[dictdeg objectForKey:@"selected"] intValue]) {
			degreeCode = [dictdeg objectForKey:@"selectionCode"];
			break;
		}
	}
	
	NSString *URL = [NSString stringWithFormat:@"%@/getMap.do",self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetMap] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtLat forKey:@"txtLat"];
	[param setObject:txtLong forKey:@"txtLong"];
	[param setObject:txtRadius forKey:@"txtRadius"];

	if (![degreeCode isEqualToString:@"5"]) 
		[param setObject:degreeCode forKey:@"txtDegreeCode"];
	
	if (![genderCode isEqualToString:@"2"]) 
		[param setObject:genderCode forKey:@"txtGenderCode"];
	
	if (![ageCode isEqualToString:@"6"]) 
		[param setObject:ageCode forKey:@"txtAgeCode"];
	
	if ([txtSearchString length]) {
		[param setObject:txtSearchString forKey:@"txtSearchString"];
	}
	
	if (txtCount) {
		[param setObject:txtCount forKey:@"txtCount"];
	}
	
	if (txtStart) {
		[param setObject:txtStart forKey:@"txtStart"];
	}
	
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getChildProfileDetails:(NSString*)cid {
	
	NSString *URL = [NSString stringWithFormat:@"%@/getChildProfileDetails.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetChildProf] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:cid forKey:@"txtCid"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getBuddies:(NSString*)cid {
	
	NSString *URL = [NSString stringWithFormat:@"%@/getBuddies.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetBuddies] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:cid forKey:@"txtCid"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getPlayDateDetails:(NSString*)pid {
	
	NSString *URL = [NSString stringWithFormat:@"%@/playdateDetails.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetPlaydateDetails] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:pid forKey:@"txtPid"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) postWallMessage:(NSString*)pid Message:(NSString*)txtMessage{
	
	NSString *URL = [NSString stringWithFormat:@"%@/postWallMessage.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqPostWallMsg] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:pid forKey:@"txtPid"];
	[param setObject:txtMessage forKey:@"txtMessage"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}


- (void) getWallMessages:(NSString *)playdateID txTime:(NSString *)txtTime {
	NSString *URL = [NSString stringWithFormat:@"%@/getWallMessages.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetWallMessages] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:playdateID forKey:@"txtPid"];
	[param setObject:txtTime forKey:@"txTime"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}
#pragma mark -

- (void) markUserPosition:(NSString*)txtLat Longitude:(NSString*)txtLong{
	
	NSString *URL = [NSString stringWithFormat:@"%@/markUserPosition.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqMarkUserPos] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtLat forKey:@"txtLat"];
	[param setObject:txtLong forKey:@"txtLong"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) playDateRequest:(NSString*)txtOrganiserCid playDateName:(NSString*)txtPlayDateName Location:(NSString *)txtLocation date:(NSString*)txtDate startTime:(NSString*)txtStartTime endTime:(NSString*)txtEndTime message:(NSString*)txtMessage txtInvitees:(NSString*)txtInvitees txtEndDate:(NSString *)txtEndDate {

	NSString *URL = [NSString stringWithFormat:@"%@/playdateRequest.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqPlaydateReq] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtOrganiserCid forKey:@"txtOrganiserCid"];
	[param setObject:txtPlayDateName forKey:@"txtPlaydateName"];
	[param setObject:txtLocation forKey:@"txtLocation"];
    [param setObject:txtDate forKey:@"txtDate"];
	[param setObject:txtEndDate forKey:@"txtEndDate"];
    [param setObject:txtStartTime forKey:@"txtStartTime"];
    [param setObject:txtEndTime forKey:@"txtEndTime"];
	
	if (txtMessage) 
		[param setObject:txtMessage forKey:@"txtMessage"];
	if (txtInvitees) 
		[param setObject:txtInvitees forKey:@"txtInvitees"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) joinKnitRequest:(NSString *)txtToUserTblPk {
	NSString *URL = [NSString stringWithFormat:@"%@/joinKnitRequest.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", joinKnitRequest] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtToUserTblPk forKey:@"txtToUserTblPk"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) deleteWallMessage:(NSString*)messageID{
	
	NSString *URL = [NSString stringWithFormat:@"%@/deleteWallMessage.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqDelWallMsg] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:messageID forKey:@"txtMessageId"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) postRSVP:(NSString*)pid RSVPStatus:(NSString*)txtRSVP{
	
	NSString *URL = [NSString stringWithFormat:@"%@/postRSVP.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqPostRSVP] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:pid forKey:@"txtPid"];
	[param setObject:txtRSVP forKey:@"txtRSVP"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}
- (void) updateMessageStatus:(NSString *)MessageID txtReadStatus:(NSString *)txtReadStatus {

	NSString *URL = [NSString stringWithFormat:@"%@/updateMessageReadStatus.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUpdateMessageStatus] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:MessageID forKey:@"txtMessageId"];
	[param setObject:txtReadStatus forKey:@"txtReadStatus"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}
- (void) userLogOut:(NSString*)sessionID {
	
	NSString *URL = [NSString stringWithFormat:@"%@/logout.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqLogOut] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}
- (void) deleteMessages:(NSString *)MessageID {

	NSString *URL = [NSString stringWithFormat:@"%@/deleteDBMessage.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqDeleteMessages] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	
	[param setObject:MessageID forKey:@"txtMessageId"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}
- (void) deleteAccount {
	NSString *URL = [NSString stringWithFormat:@"%@/deleteAccount.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqDeleteAccount] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) deleteUserPic {
	NSString *URL = [NSString stringWithFormat:@"%@/deleteUserPic.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqDeleteUserPic] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) deleteChildPic : (NSString *) child_id{
	NSString *URL = [NSString stringWithFormat:@"%@/deleteChildPic.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqDeleteChildPic] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:child_id forKey:@"txtChildTblPk"];
	[param setObject:@"" forKey:@"sessionID"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) addEvent :(NSString *)txtEventTitle txtEventDetail:(NSString *)txtEventDetail txtEventLocation:(NSString *)txtEventLocation {
	NSString *URL = [NSString stringWithFormat:@"%@/addEvent.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqAddEvent] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtEventTitle forKey:@"txtEventTitle"];
	[param setObject:txtEventDetail forKey:@"txtEventDetail"];
    if (!txtEventLocation || [txtEventLocation isEqualToString:@"(null)"]) {
    }
    else {
        [param setObject:txtEventLocation forKey:@"txtEventLocation"];
    }

	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getEvents :(NSString *)txtMyEventsFlag txtResultOffset:(NSString *)txtResultOffset txtResultLimit:(NSString *)txtResultLimit {
	NSString *URL = [NSString stringWithFormat:@"%@/getEvents.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetEvents] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtMyEventsFlag forKey:@"txtMyEventsFlag"];
	[param setObject:txtResultOffset forKey:@"txtResultOffset"];
	[param setObject:txtResultLimit forKey:@"txtResultLimit"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
    
}

- (void) deleteEventWallMessage :(NSString *)txtMessageId {
	NSString *URL = [NSString stringWithFormat:@"%@/deleteEventWallMessage.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqDeleteEventWallMessage] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtMessageId forKey:@"txtMessageId"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
    
}

- (void) getEventWallMessages :(NSString *)txtEventTblPk {
	NSString *URL = [NSString stringWithFormat:@"%@/getEventWallMessages.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetEventWallMessages] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtEventTblPk forKey:@"txtEventTblPk"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
    
}

- (void) postEventWallMessage :(NSString *)txtEventTblPk txtEventWallMessage:(NSString *)txtEventWallMessage {
	NSString *URL = [NSString stringWithFormat:@"%@/postEventWallMessage.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqPostEventWallMessage] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtEventTblPk forKey:@"txtEventTblPk"];
	[param setObject:txtEventWallMessage forKey:@"txtEventWallMessage"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
    
}

#pragma mark -
#pragma mark Settings 

- (void) updateSettings : (NSString *)txtUserProfileSetting 
		   whoCanContact:(NSString *)txtUserContactSetting 
	 memberNotifications:(NSString *)boolUserNotificationMembershipRequest 
   playDateNotifications:(NSString *)boolUserNotificationPlaydate 
playdateMessageNotifications:(NSString *)boolUserNotificationPlaydateMessageBoard
generalMessageNotifications:(NSString *)boolUserNotificationGeneralMessages
		locationSettings:(NSString *)boolUserLocationCurrentLocationSetting {

	NSString *URL = [NSString stringWithFormat:@"%@/updateSettings.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqUpdateSettings] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtUserProfileSetting forKey:@"txtUserProfileSetting"];
	[param setObject:txtUserContactSetting forKey:@"txtUserContactSetting"];
	[param setObject:boolUserNotificationMembershipRequest forKey:@"boolUserNotificationMembershipRequest"];
	[param setObject:boolUserNotificationPlaydate forKey:@"boolUserNotificationPlaydate"];
	[param setObject:boolUserNotificationPlaydateMessageBoard forKey:@"boolUserNotificationPlaydateMessageBoard"];
	[param setObject:boolUserNotificationGeneralMessages forKey:@"boolUserNotificationGeneralMessages"];
	[param setObject:boolUserLocationCurrentLocationSetting forKey:@"boolUserLocationCurrentLocationSetting"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

#pragma mark -
#pragma mark DASHBOARD API CALLS

- (void) getInvitations {
	NSString *URL = [NSString stringWithFormat:@"%@/getDBInvitations.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetInvitations] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:@"10" forKey:@"txtResultLimit"];
	[param setObject:@"0" forKey:@"txtResultOffset"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getMessages {
	NSString *URL = [NSString stringWithFormat:@"%@/getDBInviteMessages.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetMessages] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:@"50" forKey:@"txtResultLimit"];
	[param setObject:@"0" forKey:@"txtResultOffset"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) getPlaydateParticipants:(NSString *)PlaydateID {
	NSString *URL = [NSString stringWithFormat:@"%@/getPlaydateParticipants.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetPlaydateParticipants] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:PlaydateID forKey:@"txtPid"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) sendMessage:(NSString *)toUserID txtMessageSubject:(NSString *)txtMessageSubject txtMsgBody:(NSString *)txtMsgBody {
	NSString *URL = [NSString stringWithFormat:@"%@/sendDBMessage.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqSendMessage] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];

	[param setObject:toUserID forKey:@"txtToUserTblPk"];
	[param setObject:txtMessageSubject forKey:@"txtMsgSubject"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	if (txtMsgBody) {
		[param setObject:txtMsgBody forKey:@"txtMsgBody"];
	}

	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) cancelPlaydate:(NSString *)playdateID {
	NSString *URL = [NSString stringWithFormat:@"%@/cancelPlaydate.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqCancelPlaydate] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:playdateID forKey:@"txtPid"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) getFriends {

	NSString *URL = [NSString stringWithFormat:@"%@/getDBFriends.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetFriends] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:@"100" forKey:@"txtResultLimit"];
	[param setObject:@"0" forKey:@"txtResultOffset"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) getMessageDetails:(NSString *)txtMessageID txtMessageType:(NSString *)txtMessageType {
	
	NSString *URL = [NSString stringWithFormat:@"%@/getDBMessageDetails.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqGetMessageDetails] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:txtMessageID forKey:@"txtMsgId"];
	[param setObject:txtMessageType forKey:@"txtMsgType"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

- (void) joinKnitAccept:(NSString *)invitationID responseCode:(NSString *)YESNOMAYBE {

	NSString *URL = [NSString stringWithFormat:@"%@/joinKnitAccept.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", reqJoinKnitAccept] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:invitationID forKey:@"txtKnitInviteTblPk"];
	[param setObject:YESNOMAYBE forKey:@"txtResponseCode"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
	
}

- (void) getLatLongFromZipCode : (NSString*) zipCode {
	
	NSString *URL = [NSString stringWithFormat:@"%@/zipToGeoloc.do", self.domain_URL];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	[dict setObject:URL forKey:@"URL"];
	[dict setObject:[NSString stringWithFormat:@"%d", ZipCodeLatLon] forKey:@"CurrentRequest"];
	[dict setObject:@"POST" forKey:@"Method"];
	
	NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
	[param setObject:zipCode forKey:@"txtZip"];
	[dict setObject:param forKey:@"Parameters"];
	[param release];
	
	[dict setObject:[NSString stringWithFormat:@"%d", VXTURLRequestCachePolicyNone] forKey:@"CachePolicy"];
	[self performSelectorInBackground:@selector(sendRequest:) withObject:dict];
}

#pragma mark -
#pragma mark FINISHLOAD

- (BOOL) isUserLoggedIN : (NSData*)data{
	
	BOOL ret = YES;
	NSDictionary *dict = [[data stringValue] JSONValue];
	if (dict) {
		NSString *status = [[dict objectForKey:@"reason"] objectForKey:@"reasonStr"];
		if (status) {
			if( [status rangeOfString:@"Invalid Session"].location != NSNotFound) {
				ret = NO;
			}
		}
	}
	return ret;
}

- (void) showAlertWithMessage : (NSString *) message {

	if (!message) {
		message = @"Unexpected Response";
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed!" message:message 
												   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) checkForError : (NSData*) data {
	
	NSDictionary *dict = [[data stringValue] JSONValue];
	if (dict) {
		if( [[dict objectForKey:@"responseStatus"] isEqualToString:@"failure"] ) {
			
			/* [self performSelectorOnMainThread:@selector(showAlertWithMessage:) 
								   withObject:[[dict objectForKey:@"response"] objectForKey:@"reasonStr"]
								waitUntilDone:NO]; */
		}
	}else {
		[self performSelectorOnMainThread:@selector(showAlertWithMessage:) 
							   withObject:@"No or Invalid Json received from the server"
							waitUntilDone:NO];
	}

}

- (void) requestDidFinishLoad:(VXTURLRequest*)com_request {
	
	VXTURLDataResponse *response = com_request.response;
//	logResponseData(response.data);
	
	if ([self isUserLoggedIN:response.data]) {
		
		[self checkForError:response.data];
		switch (currentReq) {
			case reqUserRegister:{
				if ([self.delegate respondsToSelector:@selector(userRegisterResponse:)]) {
					[self.delegate performSelectorOnMainThread:@selector(userRegisterResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				
				break;
			case reqLoginAction:{
				if ([delegate respondsToSelector:@selector(logInResponce:)]) {
					[self.delegate performSelectorOnMainThread:@selector(logInResponce:) withObject:response.data waitUntilDone:NO];
					
				}
			}
				
				break;
			case reqForgotPassword:{
				if ([delegate respondsToSelector:@selector(forgotPasswordResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(forgotPasswordResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqConfirmationURL:{
				if ([delegate respondsToSelector:@selector(confirmationURLResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(confirmationURLResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetUpcomingPlaydates:{
				if ([delegate respondsToSelector:@selector(upcomingPlaydatesResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(upcomingPlaydatesResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqLogOut:{
				if ([delegate respondsToSelector:@selector(logOutResponce:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(logOutResponce:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqUpdateUserProfile:{
				if ([delegate respondsToSelector:@selector(updateUserProfileResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(updateUserProfileResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqUpdateChildProfile:{
				if ([delegate respondsToSelector:@selector(updateChildProfileResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(updateChildProfileResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqAddKid:{
				if ([delegate respondsToSelector:@selector(addKidResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(addKidResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetInvitations:{
				if ([delegate respondsToSelector:@selector(getInvitationsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getInvitationsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetMessages:{
				if ([delegate respondsToSelector:@selector(getMessagesResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getMessagesResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqSendMessage:{
				if ([delegate respondsToSelector:@selector(sendMessageResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(sendMessageResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetMessageDetails:{
				if ([delegate respondsToSelector:@selector(getMessageDetailsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getMessageDetailsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetFriends:{
				if ([delegate respondsToSelector:@selector(getFriendsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getFriendsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqCancelPlaydate:{
				if ([delegate respondsToSelector:@selector(CancelPlaydateResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(CancelPlaydateResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetKids:{
				if ([delegate respondsToSelector:@selector(getKidsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getKidsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetPlaydateParticipants:{
				if ([delegate respondsToSelector:@selector(getPlaydateParticipantsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getPlaydateParticipantsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case joinKnitRequest:{
				if ([delegate respondsToSelector:@selector(joinKnitRequestResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(joinKnitRequestResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqJoinKnitAccept:{
				if ([delegate respondsToSelector:@selector(getJoinKnitAcceptResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getJoinKnitAcceptResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetUserProfile:{
				if ([delegate respondsToSelector:@selector(getUserProfileResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getUserProfileResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetUserSettings:{
				if ([delegate respondsToSelector:@selector(getUserSettingsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getUserSettingsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqUpdateMessageStatus:{
				if ([delegate respondsToSelector:@selector(updateMessageStatusResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(updateMessageStatusResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqAddSecRR:{
				if ([delegate respondsToSelector:@selector(addSecondaryRRResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(addSecondaryRRResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqRemoveSecRR:{
				if ([delegate respondsToSelector:@selector(removeSecondaryRRResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(removeSecondaryRRResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqUploadContacts:{
				if ([delegate respondsToSelector:@selector(uploadContactsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(uploadContactsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqUploadFBContacts:{
				if ([delegate respondsToSelector:@selector(uploadFBContactsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(uploadFBContactsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
            case reqSetFBIdToken:{
				if ([delegate respondsToSelector:@selector(setFBIdTokenResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(setFBIdTokenResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
            case reqInviteUsers:{
				if ([delegate respondsToSelector:@selector(inviteUsersResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(inviteUsersResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqUpdateWannaHangStatus:{
				if ([delegate respondsToSelector:@selector(updateWannaHangStatusResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(updateWannaHangStatusResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetWannaHangStatus:{
				if ([delegate respondsToSelector:@selector(getWannaHangStatusResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getWannaHangStatusResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetMap:{
				if ([delegate respondsToSelector:@selector(getMapDetailsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getMapDetailsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetMapDetails:{
				if ([delegate respondsToSelector:@selector(getMapDetailsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getMapDetailsResponse:) withObject:response.data waitUntilDone:NO];
				} else {
				}
			}
				break;
			case reqGetWallMessages:{
				if ([delegate respondsToSelector:@selector(getWallMessagesResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getWallMessagesResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;	
			case reqMarkUserPos:{
				if ([delegate respondsToSelector:@selector(MarkUserPosResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(MarkUserPosResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetChildProf:{
				if ([delegate respondsToSelector:@selector(getChildProfDetailResp:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getChildProfDetailResp:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetBuddies:{
				if ([delegate respondsToSelector:@selector(getBuddiesResp:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getBuddiesResp:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqPlaydateReq:{
				if ([delegate respondsToSelector:@selector(playDateRequestResp:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(playDateRequestResp:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqGetPlaydateDetails:{
				if ([delegate respondsToSelector:@selector(getPlayDateDetailsResp:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getPlayDateDetailsResp:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqPostWallMsg:{
				if ([delegate respondsToSelector:@selector(postWallMsgResp:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(postWallMsgResp:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqPostRSVP:{
				if ([delegate respondsToSelector:@selector(postRSVPResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(postRSVPResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqDelWallMsg:{
				if ([delegate respondsToSelector:@selector(delWallMsgResp:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(delWallMsgResp:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqUpdateSettings:{
				if ([delegate respondsToSelector:@selector(updateSettingsResopnse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(updateSettingsResopnse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqDeleteMessages:{
				if ([delegate respondsToSelector:@selector(deleteMessagesResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(deleteMessagesResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;	
			case reqDeleteUserPic:{
				if ([delegate respondsToSelector:@selector(deleteUserPicResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(deleteUserPicResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case reqDeleteChildPic:{
				if ([delegate respondsToSelector:@selector(deleteChildPicResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(deleteChildPicResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
			break;
			case reqAddEvent:{
				if ([delegate respondsToSelector:@selector(addEventResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(addEventResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
            break;
			case reqGetEvents:{
				if ([delegate respondsToSelector:@selector(getEventsResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getEventsResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
            break;
			case reqDeleteEventWallMessage:{
				if ([delegate respondsToSelector:@selector(deleteEventWallMessage:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(deleteEventWallMessage:) withObject:response.data waitUntilDone:NO];
				}
			}
                break;
			case reqGetEventWallMessages:{
				if ([delegate respondsToSelector:@selector(getEventWallMessagesResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(getEventWallMessagesResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
                break;
			case reqPostEventWallMessage:{
				if ([delegate respondsToSelector:@selector(postEventWallResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(postEventWallResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
                break;
			case reqDeleteAccount:{
				if ([delegate respondsToSelector:@selector(deleteAccountResponse:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(deleteAccountResponse:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
			case ZipCodeLatLon:{
				if ([delegate respondsToSelector:@selector(latLonRecivedFormZipCode:)]) {
					
					[self.delegate performSelectorOnMainThread:@selector(latLonRecivedFormZipCode:) withObject:response.data waitUntilDone:NO];
				}
			}
			break;
			default:{
				if ([delegate respondsToSelector:@selector(dataRecived:)]){
					
					[self.delegate performSelectorOnMainThread:@selector(dataRecived:) withObject:response.data waitUntilDone:NO];
				}
			}
				break;
		}
	}
	else {
		BOOL success = NO;
		BaseViewController *contDelegate = nil;
		if (!reLoadingData) {
			
			NSDictionary *dictUserInfo = [NSDictionary dictionaryWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"]];
			
			NSString *userName = [dictUserInfo objectForKey:@"user_name"];
			NSString *password = [dictUserInfo objectForKey:@"password"];
			
			if ([userName length] && [password length]) {
				
				if ([self.delegate isKindOfClass:[BaseViewController class]]) {
					contDelegate = self.delegate;
				}
				
				if (contDelegate) {
					[DELEGATE performSelectorOnMainThread:@selector(removeLoadingView:) withObject:contDelegate.vi_main waitUntilDone:NO];
				}
				
				[DELEGATE performSelectorOnMainThread:@selector(addLoadingView:) withObject:[DELEGATE window] waitUntilDone:NO];
				
				NSString *URL = [NSString stringWithFormat:@"%@/LoginAction.do", self.secure_domain_URL];
				NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
																		  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
																	  timeoutInterval:10.0];
				[theRequest setHTTPShouldHandleCookies:YES];
				[theRequest setHTTPMethod:@"POST"];
				
				NSString *param = [NSString stringWithFormat:@"txtUserId=%@&txtPassword=%@", userName , password];
				[theRequest setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
				NSURLResponse *theResponse = NULL;
				NSError *theError = NULL;
				NSData *theResponseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
				
				NSDictionary *response = [[theResponseData stringValue] JSONValue];
				if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
					
					[DELEGATE.dict_userInfo setObject:[[response objectForKey:@"response"] objectForKey:@"sessionID"] forKey:@"sessionID"];
					[DELEGATE.dict_userInfo setObject:[response objectForKey:@"response"] forKey:@"response"];
					
					[DELEGATE.dict_userInfo writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
					
					success = YES;
				}
			}
			
			if (!success) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Your session has timed out. Please login again." 
															   delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
				[alert release];
				
				[DELEGATE performSelectorOnMainThread:@selector(removeApplicationUI) withObject:nil waitUntilDone:NO];
			}else {
				if (contDelegate) {
					[DELEGATE performSelectorOnMainThread:@selector(addLoadingView:) withObject:contDelegate.vi_main waitUntilDone:NO];
				}
				reLoadingData = YES;
				[self sendRequest:self.dict_currentRequest];
			}
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Your session has timed out. Please login again." 
														   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			[DELEGATE performSelectorOnMainThread:@selector(removeApplicationUI) withObject:nil waitUntilDone:NO];
		}
		
		[DELEGATE performSelectorOnMainThread:@selector(removeLoadingView:) withObject:[DELEGATE window] waitUntilDone:NO];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) noNetwork{
	
	NSLog(@"noNetwork");
	if (reLoadingData) {
		reLoadingData = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Your session has timed out. Please login again." 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[DELEGATE removeLoadingView:[DELEGATE window]];
		[DELEGATE performSelectorOnMainThread:@selector(removeApplicationUI) withObject:nil waitUntilDone:NO];
	}else {
		[delegate noNetworkConnection];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connectivity" message:MSG_ERROR_VALID_CONNECTION
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) requestDidCancelLoad:(VXTURLRequest*)request1 {
	
	if (reLoadingData) {
		reLoadingData = NO;
	}
	if ([delegate respondsToSelector:@selector(requestCanceled)])
		[delegate requestCanceled];
}

- (void) request:(VXTURLRequest*)requestRef didFailLoadWithError:(NSError*)error {
	
	if (reLoadingData) {
		reLoadingData = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Your session has timed out. Please login again." 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[DELEGATE performSelectorOnMainThread:@selector(removeApplicationUI) withObject:nil waitUntilDone:NO];
	}else {
		if([delegate respondsToSelector:@selector(failWithError:)])
			[delegate failWithError:error];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:MSG_ERROR_VALID_REQUEST
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark -
- (void) dealloc {
    [secure_domain_URL release];
	[[VXTURLRequestQueue mainQueue] cancelRequest:self.request];
	[self.request release];
	[self.dict_currentRequest release];
	[super dealloc];
}

@end