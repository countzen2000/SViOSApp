//
//  SocialBlockingView.h
//  SocialVibeSampleApp
//
//  Created on 2012-11-07.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Blocking view that presents users the option of watching a video or completing an engagement.
 */

#import <UIKit/UIKit.h>


@protocol SocialWatchOrEngageDelegate;

@interface SocialWatchOrEngageGatingView : UIImageView
@property (weak) IBOutlet id delegate;

- (id)initWithDelegate:(id<SocialWatchOrEngageDelegate>)delegate;
@end


@protocol SocialWatchOrEngageDelegate <NSObject>
- (void)watchVideoButtonPressed;
- (void)engageWithSponsorButtonPressed;
@end