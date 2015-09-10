//
//  SocialFreePassGatingView.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-07.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialFreePassGatingView.h"

@interface SocialFreePassGatingView ()
@property (strong) UIButton* freePassButton;
@end

@implementation SocialFreePassGatingView

- (id)initWithDelegate:(id<SocialFreePassDelegate>)delegate
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
    [self setImage:[UIImage imageNamed:@"free_pass_view"]];
    
    
    _freePassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_freePassButton setImage:[UIImage imageNamed:@"free_pass_button"] forState:UIControlStateNormal];
    [_freePassButton setImage:[UIImage imageNamed:@"free_pass_button_down"] forState:UIControlStateHighlighted];
    [_freePassButton setFrame:CGRectMake(59, 353, 214, 39)];
    [_freePassButton addTarget:self action:@selector(freePassButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_freePassButton];
}

- (void)freePassButtonPressed
{
    [_delegate freePassButtonPressed];
}

@end
