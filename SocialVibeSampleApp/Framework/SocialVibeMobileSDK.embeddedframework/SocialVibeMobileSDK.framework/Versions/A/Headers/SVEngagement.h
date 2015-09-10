//
//  SVEngagement.h
//  SocialVibeMobileSDK
//
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//


/*
 The SVEngagement class represents a single engagement that can be displayed to a user via an instance of SVEngagementView. An SVEngagement object is immutable, and does not need to be retained once it has been passed to an engagement view. The bannerImageUrl property holds a URL string pointing to the location of a static image that could be used to create a banner for the engagement.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_CLASS_AVAILABLE_IOS(6_0)
@interface SVEngagement : NSObject

@property (readonly, copy) NSString*                name;           // The activity name.
@property (readonly, copy) NSString*                displayText;    // The promotional text for the activity.
@property (readonly, copy) NSString*                engagementId;   // The unique identifier for the activity.
@property (readonly, copy) NSString*                bannerImageUrl; // The URL of the activity’s promotional image.
@property (readonly, assign) NSUInteger             width;          // The width of the activity.
@property (readonly, assign) NSUInteger             height;         // The height of the activity.
@property (readonly, assign) CGFloat                revenue;        // The revenue to be earned by the partner per engagement.
@property (readonly, assign) CGFloat                currency;       // The amount of partner currency that the user will earn for completing the engagement.

@end
