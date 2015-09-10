//
//  UILocalNotification+SVLocalNotification.h
//
//  Created on 2012-11-19.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UILocalNotification (SVLocalNotification)

// Check if the local notification has an engagement follow-up that should be displayed in an SVEngagementView.
- (BOOL)isSocialVibeFollowUpNotification;

// Check if the local notification was scheduled by a SocialVibe ad.
- (BOOL)isSocialVibeNotification;

@end
