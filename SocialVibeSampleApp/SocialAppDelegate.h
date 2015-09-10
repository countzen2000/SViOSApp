//
//  SocialAppDelegate.h
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SocialVibeMobileSDK/SocialVibeMobileSDK.h>
#import <CoreLocation/CoreLocation.h>


@class SVPublisherInstance;

@interface SocialAppDelegate : UIResponder <UIApplicationDelegate, SVEngagementViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) CLLocationManager* locationManager;

// accessors for Publisher Instances for the different demo types
- (SVPublisherInstance*)publisherInstanceForEngagements;
- (SVPublisherInstance*)publisherInstanceForVideo;

@end
