//
//  SVPublisherInstance.h
//  SocialVibeMobileSDK
//
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//


/*
 The SVPublisherInstance class provides a means to generate SVTrigger objects, which can be used to fetch engagements. A Publisher Instance only needs to be created once, and can be reused to produce new triggers. Only one instance is required per placement ID. If the Publisher Instance is initialized with the application secret (secret key) then it can be used to verify the authenticity of an engagement’s completion.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol SVTriggerDelegate;
@class SVTrigger;

NS_CLASS_AVAILABLE_IOS(6_0)
@interface SVPublisherInstance : NSObject

// Create and return a new Publisher Instance. 
+ (SVPublisherInstance*)publisherInstanceWithPlacementIdentifier:(NSString*)placementId userIdentifier:(NSString*)userId secretKey:(NSString*)secretKey;

// Create and return a trigger, used for fetching engagements.
- (SVTrigger*)triggerForEngagementsOfWidth:(NSUInteger)width height:(NSUInteger)height maxResults:(NSUInteger)maxResults withDelegate:(id<SVTriggerDelegate>)delegate;

// Verify the authenticity of an engagement’s completion.
- (BOOL)validateCreditPayload:(NSString*)payload withSignature:(NSString*)signature;

@end
