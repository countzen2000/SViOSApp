//
//  SVConstants.m
//
//  Created on 2012-10-18.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVConstants.h"

// section titles user data parameters
NSString* const kUserDeviceParametersPlacement = @"placement";
NSString* const kUserDeviceParametersApp = @"app";
NSString* const kUserDeviceParametersAdSpace = @"adspace";
NSString* const kUserDeviceParametersDevice = @"device";
NSString* const kUserDeviceParametersUser = @"user";
NSString* const kUserDeviceParametersAd = @"ad";
NSString* const kUserDeviceParametersResponse = @"response";

// fetch engagement request properties
NSString* const kFetchEngagementsPlacementIdentifier = @"key";

NSString* const kFetchEngagementsAppName = @"name";
NSString* const kFetchEngagementsAppKeywords = @"keywords";
NSString* const kFetchEngagementsAppVersion = @"version";

NSString* const kFetchEngagementsWidth = @"width";
NSString* const kFetchEngagementsHeight = @"height";

NSString* const kFetchEngagementsDevicePlatformId = @"dpid";
NSString* const kFetchEngagementsDeviceCountry = @"country";
NSString* const kFetchEngagementsDeviceCarrier = @"carrier";
NSString* const kFetchEngagementsDeviceUserAgent = @"ua";
NSString* const kFetchEngagementsDeviceManufacturer = @"make";
NSString* const kFetchEngagementsDeviceModel = @"model";
NSString* const kFetchEngagementsDeviceOS = @"os";
NSString* const kFetchEngagementsDeviceOSVersion = @"osv";
NSString* const kFetchEngagementsDeviceGeoLocation = @"loc";

NSString* const kFetchEngagementsUserIdentifier = @"uid";

NSString* const kFetchEngagementsUserAge = @"age";
NSString* const kFetchEngagementsUserYearOfBirth = @"yob";
NSString* const kFetchEngagementsUserGender = @"gender";
NSString* const kFetchEngagementsUserZip = @"zip";
NSString* const kFetchEngagementsUserCountry = @"country";
NSString* const kFetchEngagementsUserInterests = @"keywords";
NSString* const kFetchEngagementsUserExtraAttributes = @"attributes";

NSString* const kFetchEngagementsAdMraidEnabled = @"mraid";
NSString* const kFetchEngagementsAdRepresentation = @"representation";

NSString* const kFetchEngagementsResponseCallback = @"callback";
NSString* const kFetchEngagementsResponseMaxActivities = @"max_activities";

// fetch engagement response properties
NSString* const kEngagementsResponseWidth = @"window_width";
NSString* const kEngagementsResponseHeight = @"window_height";
NSString* const kEngagementsResponseName = @"name";
NSString* const kEngagementsResponseDisplayText = @"display_text";
NSString* const kEngagementsResponseBaseUrl = @"base_url";
NSString* const kEngagementsResponseId = @"id";
NSString* const kEngagementsResponseImageUrl = @"image_url";
NSString* const kEngagementsResponseUrl = @"window_url";
NSString* const kEngagementsResponseRevenueAmount = @"revenue_amount";
NSString* const kEngagementsResponseCurrencyAmount = @"currency_amount";
NSString* const kEngagementsResponseMarkup = @"markup";

// engagement view property types
NSString* const kEngagementsViewPropertyPlacement = @"placementType";
NSString* const kEngagementsViewPropertyState = @"state";
NSString* const kEngagementsViewPropertySize = @"screenSize";
NSString* const kEngagementsViewPropertyVisible = @"viewable";

// local notification parameter keys
NSString* const kLocalNotificationFireDate = @"fireDate";
NSString* const kLocalNotificationPromptText = @"promptText";
NSString* const kLocalNotificationNotificationText = @"notificationText";
NSString* const kLocalNotificationFollowUpUrl = @"url";
NSString* const kSocialVibeNotificationTag = @"SocialVibeNotificationTag";
NSString* const kSocialVibeNotificationName = @"SocialVibeNotification";

// on credit parameter keys
NSString* const kEngagementCreditPayload = @"payload";
NSString* const kEngagementCreditSignature = @"signature";

// passbook parameter key
NSString* const kPassbookPassUrl = @"url";

// SDK error domain
NSString* const kSVErrorDomain = @"com.socialvibe.mobilesdk";

// MRAID commands
NSString* const kMraidCommandOpen = @"open";
NSString* const kMraidCommandClose = @"close";
NSString* const kMraidCommandUseCustomClose = @"usecustomclose";
NSString* const kMraidCommandExpand = @"expand";
NSString* const kMraidCommandStart = @"start";
NSString* const kMraidCommandCredit = @"credit";
NSString* const kMraidCommandFinish = @"finish";
NSString* const kMraidCommandNotification = @"localnotification";
NSString* const kMraidCommandPassbook = @"passbook";

NSString* const kMraidCommandUseCustomCloseKey = @"shouldUseCustomClose";
NSString* const kMraidCommandOpenExternalUrlKey = @"url";

