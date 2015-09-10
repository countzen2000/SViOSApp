//
//  SVConfig.h
//  SocialVibeMobileSDK
//
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//


/*
 The SVConfig class is a singleton object that allows optional configuration of the SDK, including sending optional user and device data for better ad-targetting. The SocialVibe test server can be set for serving engagements using the useTestServer: method. By default, local notifications and Passbook passes are disabled; to enable them, use enableLocalNotifications: and enablePassbookPasses:. 
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class CLLocation;

NS_CLASS_AVAILABLE_IOS(6_0)
@interface SVConfig : NSObject

// Returns the singleton SVConfig instance.
+ (SVConfig*)sharedInstance;

// Optionally use the SocialVibe test server instead of the production server for serving ads. Default value is NO.
- (void)useTestServer:(BOOL)test;

// Allow ads to schedule local notifications (reminders). Default value is NO.
- (void)enableLocalNotifications:(BOOL)enable;

// Allow ads to grant Passbook passes for completing engagements. Default value is NO.
- (void)enablePassbookPasses:(BOOL)enable;

// Set information about your app for ad targeting. All parameters are optional.
- (void)setAppName:(NSString*)name keywords:(NSArray*)keywords version:(NSString*)version;

// Set the device's current geo-location for ad targeting. Optional.
- (void)setCurrentLocation:(CLLocation*)location;

// Set the current device's IFA or equivalent identifier for ad targeting. Optional.
- (void)setDeviceId:(NSString*)deviceId;

// Set information about the user for ad targeting. All parameters are optional.
- (void)setUserAge:(NSNumber*)age gender:(NSString*)gender zip:(NSString*)zip country:(NSString*)country keywords:(NSArray*)keywords additionalAttributes:(NSDictionary*)additional;

@end
