//
//  SocialBlockingView.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-07.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialWatchOrEngageGatingView.h"

@interface SocialWatchOrEngageGatingView ()
@property (strong) UIButton* watchVideoButton;
@property (strong) UIButton* engageWithSponsorButton;
@end

@implementation SocialWatchOrEngageGatingView

- (id)initWithDelegate:(id<SocialWatchOrEngageDelegate>)delegate
{
    CGRect frame = CGRectMake(0, 0, 320, 524);
    self = [super initWithFrame:frame];
    if (self)
    {
        _delegate = delegate;
        [self performSelector:@selector(setupView) withObject:nil afterDelay:0];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupView];
}

- (void)setupView
{
    self.userInteractionEnabled = YES;
    [self setImage:[UIImage imageNamed:@"watch_or_engage_view"]];
    
    
    _watchVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_watchVideoButton setImage:[UIImage imageNamed:@"watch_video_button"] forState:UIControlStateNormal];
    [_watchVideoButton setFrame:CGRectMake(18, 176, 284, 58)];
    [_watchVideoButton addTarget:self action:@selector(watchVideoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_watchVideoButton];
    
    
    _engageWithSponsorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_engageWithSponsorButton setImage:[UIImage imageNamed:@"engage_with_sponsor_button"] forState:UIControlStateNormal];
    [_engageWithSponsorButton setFrame:CGRectMake(18, 258, 284, 58)];
    [_engageWithSponsorButton addTarget:self action:@selector(engageWithSponsorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_engageWithSponsorButton];
}

- (void)watchVideoButtonPressed
{
    [_delegate watchVideoButtonPressed];
}

- (void)engageWithSponsorButtonPressed
{
    [_delegate engageWithSponsorButtonPressed];
}

@end
