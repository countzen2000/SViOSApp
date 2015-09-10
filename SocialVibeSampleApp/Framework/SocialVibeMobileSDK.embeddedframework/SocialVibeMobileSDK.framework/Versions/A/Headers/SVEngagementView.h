//
//  SVEngagementView.h
//  SocialVibeMobileSDK
//
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//


/*
 The SVEngagementView class is a fullscreen container view that loads and displays an engagement from an SVEngagement object. Local notifications that have been created from engagements can also be loaded in an engagement view, after firing, to display an engagement follow-up. An SVEngagementView must have a delegate that implements the required methods in the SVEngagementViewDelegate protocol.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol SVEngagementViewDelegate;
@class SVEngagement;
@class PKPass;

NS_CLASS_AVAILABLE_IOS(6_0)
@interface SVEngagementView : UIView

// Create and return a new Engagement View instance.
+ (SVEngagementView*)engagementViewWithDelegate:(id<SVEngagementViewDelegate>)delegate;

// Load and display an SVEngagement object.
- (BOOL)loadEngagement:(SVEngagement*)engagement;

// Load an engagement follow-up from a local notification scheduled by an ad.
- (BOOL)loadNotification:(UILocalNotification*)notification;

@end


@protocol SVEngagementViewDelegate <NSObject>

// The engagement has finished loading, and the engagement view should be unhidden.
- (void)engagementViewReadyForDisplay:(SVEngagementView*)engagementView;

// The engagement will terminate and the Engagement View should be removed from its view hierarchy.
- (void)engagementViewShouldClose:(SVEngagementView*)engagementView;

// Credit has been awarded for completion of an engagement.
- (void)engagementView:(SVEngagementView*)engagementView didReceiveCreditPayload:(NSString*)payload andSignature:(NSString*)signature;

// The engagement view will load a URL in the native browser, and the app will be suspended.
- (void)engagementViewWillOpenExternalUrl:(SVEngagementView*)engagementView;

// The engagement view failed to load an engagement.
- (void)engagementView:(SVEngagementView*)engagementView didEncounterError:(NSError*)error;

@optional

// The engagement has reached the end of its flow, and a completion message should be displayed.
- (void)engagementViewDidFinish:(SVEngagementView*)engagementView;

// A Passbook pass has been awarded by an ad.
- (void)engagementView:(SVEngagementView*)engagementView didReceivePassbookPass:(PKPass*)pass;

@end
