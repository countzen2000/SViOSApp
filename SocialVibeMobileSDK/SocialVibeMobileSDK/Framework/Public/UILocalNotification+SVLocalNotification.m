//
//  UILocalNotification+SVLocalNotification.m
//
//  Created on 2012-11-19.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "UILocalNotification+SVLocalNotification.h"
#import "SVConstants.h"

@implementation UILocalNotification (SVLocalNotification)

// notifications to be displayed in an Engagement View have both an identifying tag, as well as a URL
- (BOOL)isSocialVibeFollowUpNotification
{
    BOOL hasSVTag = [self isSocialVibeNotification];
    
    NSString* followUpUrl = [self.userInfo objectForKey:kLocalNotificationFollowUpUrl];
    BOOL hasUrl = [followUpUrl length];
    
    return hasSVTag && hasUrl;
}

// all notifications scheduled by the SDK have an identifiying tag added to user info
- (BOOL)isSocialVibeNotification
{
    NSString* notificationTag = [self.userInfo objectForKey:kSocialVibeNotificationTag];
    BOOL hasSVTag = [notificationTag isEqualToString:kSocialVibeNotificationName];
    
    return hasSVTag;
}

@end
