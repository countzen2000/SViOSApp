//
//  SocialNavigationController.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialNavigationController.h"

@implementation SocialNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // red tint
    self.navigationBar.tintColor = [UIColor redColor];
    
    // title logo
    UIImageView* navBarTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bar_icon"]];
    navBarTitle.frame = CGRectMake(95, 6, 131, 33);
    [self.navigationBar addSubview:navBarTitle];
}

@end
