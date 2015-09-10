//
//  SocialSectionLandingVC.h
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Reusable controller for demonstrating five different use cases of the SDK.
 */

#import <UIKit/UIKit.h>
#import <SocialVibeMobileSDK/SocialVibeMobileSDK.h>
#import "SocialTemplateViewController.h"

@class PKPass;

typedef enum {
    SectionLandingTypeContentGate,
    SectionLandingTypeInterstitial,
    SectionLandingTypeNotification,
    SectionLandingTypePassbook,
    SectionLandingTypeBanner,
} SectionLandingType;

@interface SocialSectionLandingVC : SocialTemplateViewController <SVTriggerDelegate, SVEngagementViewDelegate>

- (id)initWithType:(SectionLandingType)type;

// SVTriggerDelegate
- (void)trigger:(SVTrigger*)trigger didFetchEngagements:(NSArray*)engagements;
- (void)trigger:(SVTrigger*)trigger didEncounterError:(NSError *)error;

// SVEngagementViewDelegate
- (void)engagementViewReadyForDisplay:(SVEngagementView*)engagementView;
- (void)engagementViewShouldClose:(SVEngagementView*)engagementView;
- (void)engagementView:(SVEngagementView*)engagementView didReceiveCreditPayload:(NSString*)payload andSignature:(NSString*)signature;
- (void)engagementView:(SVEngagementView*)engagementView didReceivePassbookPass:(PKPass*)pass;;
- (void)engagementViewDidFinish:(SVEngagementView*)engagementView;
- (void)engagementViewWillOpenExternalUrl:(SVEngagementView*)engagementView;
- (void)engagementView:(SVEngagementView*)engagementView didEncounterError:(NSError*)error;

@end
