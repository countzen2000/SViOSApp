//
//  SVConstants.h
//
//  Created on 2012-10-18.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import <Foundation/Foundation.h>

// section titles for user data parameters
extern NSString* const kUserDeviceParametersPlacement;
extern NSString* const kUserDeviceParametersApp;
extern NSString* const kUserDeviceParametersAdSpace;
extern NSString* const kUserDeviceParametersDevice;
extern NSString* const kUserDeviceParametersUser;
extern NSString* const kUserDeviceParametersAd;
extern NSString* const kUserDeviceParametersResponse;

// fetch engagement request properties
extern NSString* const kFetchEngagementsPlacementIdentifier;
//
extern NSString* const kFetchEngagementsAppName;
extern NSString* const kFetchEngagementsAppKeywords;
extern NSString* const kFetchEngagementsAppVersion;
//
extern NSString* const kFetchEngagementsWidth;
extern NSString* const kFetchEngagementsHeight;
//
extern NSString* const kFetchEngagementsDevicePlatformId;
extern NSString* const kFetchEngagementsDeviceCountry;
extern NSString* const kFetchEngagementsDeviceCarrier;
extern NSString* const kFetchEngagementsDeviceUserAgent;
extern NSString* const kFetchEngagementsDeviceManufacturer;
extern NSString* const kFetchEngagementsDeviceModel;
extern NSString* const kFetchEngagementsDeviceOS;
extern NSString* const kFetchEngagementsDeviceOSVersion;
extern NSString* const kFetchEngagementsDeviceGeoLocation;
//
extern NSString* const kFetchEngagementsUserIdentifier;
extern NSString* const kFetchEngagementsUserAge;
extern NSString* const kFetchEngagementsUserYearOfBirth;
extern NSString* const kFetchEngagementsUserGender;
extern NSString* const kFetchEngagementsUserZip;
extern NSString* const kFetchEngagementsUserCountry;
extern NSString* const kFetchEngagementsUserInterests;
extern NSString* const kFetchEngagementsUserExtraAttributes;
//
extern NSString* const kFetchEngagementsAdMraidEnabled;
extern NSString* const kFetchEngagementsAdRepresentation;
//
extern NSString* const kFetchEngagementsResponseCallback;
extern NSString* const kFetchEngagementsResponseMaxActivities;

// fetch engagement response properties
extern NSString* const kEngagementsResponseWidth;
extern NSString* const kEngagementsResponseHeight;
extern NSString* const kEngagementsResponseName;
extern NSString* const kEngagementsResponseDisplayText;
extern NSString* const kEngagementsResponseBaseUrl;
extern NSString* const kEngagementsResponseId;
extern NSString* const kEngagementsResponseImageUrl;
extern NSString* const kEngagementsResponseUrl;
extern NSString* const kEngagementsResponseRevenueAmount;
extern NSString* const kEngagementsResponseCurrencyAmount;
extern NSString* const kEngagementsResponseMarkup;

// engagement view property types
extern NSString* const kEngagementsViewPropertyPlacement;
extern NSString* const kEngagementsViewPropertyState;
extern NSString* const kEngagementsViewPropertySize;
extern NSString* const kEngagementsViewPropertyVisible;

// local notification parameter keys
extern NSString* const kLocalNotificationFireDate;
extern NSString* const kLocalNotificationPromptText;
extern NSString* const kLocalNotificationNotificationText;
extern NSString* const kLocalNotificationFollowUpUrl;
extern NSString* const kSocialVibeNotificationTag;
extern NSString* const kSocialVibeNotificationName;

// on credit parameter keys
extern NSString* const kEngagementCreditPayload;
extern NSString* const kEngagementCreditSignature;

// passbook parameter key
extern NSString* const kPassbookPassUrl;

// SDK error domain
extern NSString* const kSVErrorDomain;

// MRAID commands
extern NSString* const kMraidCommandOpen;
extern NSString* const kMraidCommandClose;
extern NSString* const kMraidCommandUseCustomClose;
extern NSString* const kMraidCommandExpand;
extern NSString* const kMraidCommandStart;
extern NSString* const kMraidCommandCredit;
extern NSString* const kMraidCommandFinish;
extern NSString* const kMraidCommandNotification;
extern NSString* const kMraidCommandPassbook;

extern NSString* const kMraidCommandUseCustomCloseKey;
extern NSString* const kMraidCommandOpenExternalUrlKey;
