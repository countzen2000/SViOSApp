//
//  SocialFreePassGatingView.h
//  SocialVibeSampleApp
//
//  Created on 2012-11-07.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Blocking view that prompts users to complete an engagement to gain access to content.
 */

#import <UIKit/UIKit.h>


@protocol SocialFreePassDelegate;

@interface SocialFreePassGatingView : UIImageView
@property (weak) IBOutlet id delegate;

- (id)initWithDelegate:(id<SocialFreePassDelegate>)delegate;
@end


@protocol SocialFreePassDelegate <NSObject>
- (void)watchVideoButtonPressed;
- (void)engageWithSponsorButtonPressed;
@end