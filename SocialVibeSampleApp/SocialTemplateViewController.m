//
//  SocialTemplateViewController.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-07.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialTemplateViewController.h"


@implementation SocialTemplateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem* homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(returnToHomeScreen)];
    self.navigationItem.leftBarButtonItem = homeButton;
}

- (void)returnToHomeScreen
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
