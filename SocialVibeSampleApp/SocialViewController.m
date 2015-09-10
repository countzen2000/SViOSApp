//
//  SocialViewController.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialViewController.h"
#import "SocialNavigationController.h"
#import "SocialSectionLandingVC.h"


@interface SocialViewController ()
- (IBAction)loadContentGateFlow:(id)sender;
- (IBAction)loadInterstitialFlow:(id)sender;
- (IBAction)loadLocalNotificationFlow:(id)sender;
- (IBAction)loadPassbookFlow:(id)sender;
- (IBAction)loadExpandableBannerFlow:(id)sender;
- (void)presentSectionOfType:(SectionLandingType)type;
@end


@implementation SocialViewController

- (IBAction)loadContentGateFlow:(id)sender
{
    [self presentSectionOfType:SectionLandingTypeContentGate];
}

- (IBAction)loadInterstitialFlow:(id)sender
{
    [self presentSectionOfType:SectionLandingTypeInterstitial];
}

- (IBAction)loadLocalNotificationFlow:(id)sender
{
    [self presentSectionOfType:SectionLandingTypeNotification];
}

- (IBAction)loadPassbookFlow:(id)sender
{
    [self presentSectionOfType:SectionLandingTypePassbook];
}

- (IBAction)loadExpandableBannerFlow:(id)sender
{
    [self presentSectionOfType:SectionLandingTypeBanner];
}

- (void)presentSectionOfType:(SectionLandingType)type
{
    SocialSectionLandingVC* vc = [[SocialSectionLandingVC alloc] initWithType:type];
    UINavigationController* nav = [[SocialNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:NULL];
}

@end
