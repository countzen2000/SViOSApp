//
//  SVTrigger.h
//  SocialVibeMobileSDK
//
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//


/*
 The SVTrigger class is used to download engagements. Engagements of a particular size and the maximum number of results to return are specified when creating the trigger. Triggers must have a delegate, and the delegate must implement the SVTriggerDelegate protocol.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_CLASS_AVAILABLE_IOS(6_0)
@interface SVTrigger : NSObject

// Begin performing a fetch for engagements.
- (void)fetchEngagements;

// Returns the trigger's fetched engagements if there are any.
- (NSArray*)availableEngagements;

@end


@protocol SVTriggerDelegate <NSObject>

// The trigger has completed a fetch for engagements.
- (void)trigger:(SVTrigger*)trigger didFetchEngagements:(NSArray*)engagements;

// The trigger failed to fetch engagements.
- (void)trigger:(SVTrigger*)trigger didEncounterError:(NSError*)error;

@end
