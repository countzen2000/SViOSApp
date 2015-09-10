//
//  SocialAppDelegate.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialAppDelegate.h"
#import "SocialViewController.h"
#import <AdSupport/ASIdentifierManager.h>


@implementation SocialAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarHidden = YES;

    
    // set the default behaviour of the SocialVibe SDK before using ads in your app
    [self initializeSocialVibeConfigInstance];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[SocialViewController alloc] initWithNibName:@"SocialViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    
    
    UILocalNotification* localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification)
    {
        [self displayLocalNotificationDetails:localNotification];
    }
    
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self displayLocalNotificationDetails:notification];
}

- (void)displayLocalNotificationDetails:(UILocalNotification*)notification
{
    // check if the notification was scheduled by SocialVibe
    if ([notification isSocialVibeNotification])
    {
        // if the notification has an engagement follow-up, then load it in an engagement view;
        // otherwise, ignore it
        if ([notification isSocialVibeFollowUpNotification])
        {
            SVEngagementView* engagementView = [SVEngagementView engagementViewWithDelegate:self];
            engagementView.alpha = 0;
            [self.window addSubview:engagementView];
            
            
            BOOL notificationLoaded = [engagementView loadNotification:notification];
            
            // if the notification could not be loaded, discard the engagement view
            if (notificationLoaded == NO)
            {
                [engagementView removeFromSuperview];
            }
        }
    }
    else
    {
        // otherwise, handle the non-SocialVibe-scheduled notification in an app-specific way
    }
}

- (void)initializeSocialVibeConfigInstance
{
    SVConfig* config = [SVConfig sharedInstance];
    
    // production ads; set to YES to test using a QA server (default is NO)
    [config useTestServer:YES];
    
    // set to YES to enable certain engagements presented by the SDK to schedule local notifications on your
    // device as reminders to engage with sponsors after a certain period of time has elapsed (default is NO)
    [config enableLocalNotifications:YES];
    
    // set to YES to enable certain engagements presented by the SDK to present Passbook passes as rewards
    // for completing activities (default is NO)
    [config enablePassbookPasses:YES];
    
    
    // supply additional optional information about your app, the current device, and the current user
    [config setAppName:@"SocialVibeSampleApp"
              keywords:@[@"Mobile Ads", @"Demo App", @"SDK"]
               version:@"1.0"];

    // optional device ID; using IFA as UUID is no longer accepted
    NSString* ifa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [config setDeviceId:ifa];

    // optional user information, which could be obtained through an optional form
    [config setUserAge:@52
                gender:@"m"
                   zip:@"12345"
               country:@"USA"
              keywords:nil
  additionalAttributes:nil];
    
    
    // get the current geo-location (will present an alert to the user asking for permissions)
//    [self beginUpdatingLocation];
}

#pragma mark - CLLocationManager Delegate

/*
    Sample code for using the CoreLocation library to obtain a device's coordinates.
 */

//- (void)beginUpdatingLocation
//{
//    // initialize a Location Manager instance to get the current geo-location
//    _locationManager = [[CLLocationManager alloc] init];
//    _locationManager.delegate = self;
//    [_locationManager startUpdatingLocation];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    // if a location is returned, use the first one and stop tracking location (battery drain)
//    if ([locations count])
//    {
//        CLLocation* location = [locations objectAtIndex:0];
//        [self stopUpdatingLocation];
//        
//        // update the SDK's Config instance with the current geo-location
//        [[SVConfig sharedInstance] setCurrentLocation:location];
//    }
//}
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    [self stopUpdatingLocation];
//}
//
//- (void)stopUpdatingLocation
//{
//    [_locationManager stopUpdatingLocation];
//    _locationManager = nil;
//}

#pragma mark - SVEngagementViewDelegate

// display the engagement view that displays notification follow-ups
- (void)engagementViewReadyForDisplay:(SVEngagementView*)engagementView
{
    engagementView.alpha = 1;
}

// remove the engagement view that displays notification follow-ups
- (void)engagementViewShouldClose:(SVEngagementView*)engagementView
{
    [engagementView removeFromSuperview];
}

// remove the engagement view that had an error loading the notification
- (void)engagementView:(SVEngagementView*)engagementView didEncounterError:(NSError*)error
{
    [engagementView removeFromSuperview];
}

/*
    We know that in this case we will only be using an Engagement View in the AppDelegate for 
    displaying notification follow-ups, so we don't need to handle the following cases:
 */
- (void)engagementView:(SVEngagementView*)engagementView didReceiveCreditPayload:(NSString*)payload andSignature:(NSString*)signature
{
}
- (void)engagementViewWillOpenExternalUrl:(SVEngagementView*)engagementView
{
}

#pragma mark - 

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Unique Publisher Instances

/*
    Different Publisher Instances are used by this sample app to pull specific ads to demonstrate different functionality.
 */
- (SVPublisherInstance*)publisherInstanceForEngagements
{
    static SVPublisherInstance* publisher = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publisher = [self publisherWithPlacementId:@"239d5535714d812b2a56d4fa14ba31c0805f72d2"
                                         secretKey:@"0d1f90042168148818b0830d9e280de023891a7da3"];
    });
    
    return publisher;
}

- (SVPublisherInstance*)publisherInstanceForVideo
{
    static SVPublisherInstance* publisher = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publisher = [self publisherWithPlacementId:@"eb843cc22eb1cb4274d675671697abfcbf8e9fc2"
                                         secretKey:@"b849728c751c91348b34ae7f8440e5f6cd25e8c862"];
    });
    
    return publisher;
}

- (SVPublisherInstance*)publisherInstanceForPassbook
{
    static SVPublisherInstance* publisher = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publisher = [self publisherWithPlacementId:@"7dca0baf4555afbbfea0c045c8f78c5fcf73652b"
                                         secretKey:@"8a32ae7a3112a13cdc88bec9462c2e828e097d2ee0"];
    });
    
    return publisher;
}

- (SVPublisherInstance*)publisherInstanceForNotifications
{
    static SVPublisherInstance* publisher = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publisher = [self publisherWithPlacementId:@"e24273fd23521b696b8aa146dd2fc0cdefe12e03"
                                         secretKey:@"eeed37dfad2cf728a899bf623687f17c8d8354246d"];
    });
    
    return publisher;
}

- (SVPublisherInstance*)publisherWithPlacementId:(NSString*)placementId secretKey:(NSString*)secretKey
{
    NSString* userId = [self generateUserId];
    
    // set up the Publisher Instance for ads
    SVPublisherInstance* publisher = [SVPublisherInstance publisherInstanceWithPlacementIdentifier:placementId
                                                                                    userIdentifier:userId
                                                                                         secretKey:secretKey];
    return publisher;
}

// a user ID could be generated as follows, and then persisted
- (NSString*)generateUserId
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    return [NSString stringWithString:(__bridge NSString*)uuidStringRef];
}

@end
