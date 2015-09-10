//
//  SocialArticleVC.h
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Reusable controller to demonstate content gates and interstitial. 
    For content gates, the article is only displayed after credit has been received for completing the engagement.
    For the interstitial demo, the interstitial ad is displayed each time the user tries to navigate to the next article, but completion is not required.
 */

#import <UIKit/UIKit.h>
#import <SocialVibeMobileSDK/SocialVibeMobileSDK.h>
#import "SocialTemplateViewController.h"

typedef enum {
    SocialArticleFirst,
    SocialArticleSecond
} SocialArticle;

@interface SocialArticleVC : SocialTemplateViewController <SVTriggerDelegate, SVEngagementViewDelegate>

@property (readonly, assign) SocialArticle article;

// initialize for use in the interstitial demo, or not
- (id)initWithArticle:(SocialArticle)article asInterstitial:(BOOL)interstitial;

// SVTriggerDelegate
- (void)trigger:(SVTrigger*)trigger didFetchEngagements:(NSArray*)engagements;
- (void)trigger:(SVTrigger*)trigger didEncounterError:(NSError *)error;

// SVEngagementViewDelegate
- (void)engagementViewReadyForDisplay:(SVEngagementView*)engagementView;
- (void)engagementViewShouldClose:(SVEngagementView*)engagementView;
- (void)engagementView:(SVEngagementView*)engagementView didReceiveCreditPayload:(NSString*)payload andSignature:(NSString*)signature;
- (void)engagementViewWillOpenExternalUrl:(SVEngagementView*)engagementView;
- (void)engagementView:(SVEngagementView*)engagementView didEncounterError:(NSError*)error;

@end
