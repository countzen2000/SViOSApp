//
//  SocialArticleVC.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialArticleVC.h"
#import "SocialWatchOrEngageGatingView.h"
#import "SocialAppDelegate.h"


@interface SocialArticleVC () <SocialWatchOrEngageDelegate>
@property (strong) SVPublisherInstance* publisher;
@property (strong) SVEngagement* engagement;
@property (strong) UIView* loadingView;
@property (assign) BOOL interstitial;
@property (weak) IBOutlet UIImageView* backgroundView;
@property (weak) IBOutlet UIButton* nextArticleButton;
@property (weak) IBOutlet SocialWatchOrEngageGatingView* interstitialView;
- (IBAction)nextArticleButtonPressed:(id)sender;
@end


@implementation SocialArticleVC

- (id)initWithArticle:(SocialArticle)article asInterstitial:(BOOL)interstitial
{
    self = [super init];
    if (self)
    {
        _article = article;
        _interstitial = interstitial;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load a static image representing an article and set as a background
    if (_article == SocialArticleFirst)
    {
        _backgroundView.image = [UIImage imageNamed:@"first_article_screen"];
    }
    else
    {
        _backgroundView.image = [UIImage imageNamed:@"second_article_screen"];
    }
    
    // if we're not using this controller to demo interstitials between screens,
    // get rid of the button to push a new instance with a different article
    if (!_interstitial)
    {
        [_nextArticleButton removeFromSuperview];
        _nextArticleButton = nil;
    }
}

- (SocialAppDelegate*)appDelegate
{
    return (SocialAppDelegate*)[[UIApplication sharedApplication] delegate];
}

// display the error so that we know what went wrong;
// should handle the error appropriately in a real situation
- (void)displayError:(NSError*)error
{
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:[error localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
    [errorAlert show];
}

- (void)operationNotAvailable
{
    NSString* errorDomain = @"com.socialvibe.sampleapp";
    NSInteger errorCode = NSURLErrorFileDoesNotExist;
    NSDictionary* description = @{NSLocalizedDescriptionKey : @"This operation is currently not available."};
    NSError* error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:description];
    
    [self displayError:error];
}

#pragma mark - Button Actions

// trigger the interstitial ad when someone tries to navigate to the next article
- (IBAction)nextArticleButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _interstitialView.alpha = 1;
                     }];
}

- (void)watchVideoButtonPressed
{
    // use the publisher instance that returns videos
    _publisher = [[self appDelegate] publisherInstanceForVideo];
    [self prepareEngagement];
}

- (void)engageWithSponsorButtonPressed
{
    // use the publisher instance that returns interactive engagements
    _publisher = [[self appDelegate] publisherInstanceForEngagements];
    [self prepareEngagement];
}

#pragma mark - Pre- and Post- Engagement Display

// perform a fetch and display a loading view
- (void)prepareEngagement
{
    [self createLoadingView];
    [self displayLoadingView];
    [self fetchEngagements];
}

// create a black view that occupies the entire screen, with loading spinner in the center, to be displayed while an engagement is loading
- (void)createLoadingView
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    _loadingView = [[UIView alloc] initWithFrame:window.frame];
    _loadingView.backgroundColor = [UIColor blackColor];
    [window addSubview:_loadingView];
    
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect spinnerFrame = spinner.frame;
    spinnerFrame.origin.x = (window.frame.size.width - spinnerFrame.size.width) / 2;
    spinnerFrame.origin.y = (window.frame.size.height - spinnerFrame.size.height) / 2;
    spinner.frame = spinnerFrame;
    
    [spinner startAnimating];
    [_loadingView addSubview:spinner];
}

// fade in the loading view, and remove the interstitial view with the engagement options
- (void)displayLoadingView
{
    _loadingView.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         _loadingView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         _interstitialView.alpha = 0;
                     }];
}

- (void)removeLoadingView
{
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

// fade out and remove the engagement to reveal the article behind
- (void)dismissEngagementView:(SVEngagementView*)engagementView
{
    self.navigationController.navigationBarHidden = NO;
    
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         engagementView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [engagementView removeFromSuperview];
                     }];
}

#pragma mark - Engagements

// create a new engagement view, add it to the view hierarchy, and pass it an engagement to load
- (void)loadEngagement
{
    self.navigationController.navigationBarHidden = YES;
    
    
    SVEngagementView* engagementView = [SVEngagementView engagementViewWithDelegate:self];
    engagementView.alpha = 0;
    [self.view addSubview:engagementView];
    
    [engagementView loadEngagement:_engagement];
}

// fetch engagements with a maximum size matching the size of an iPhone 5 screen (in points)
- (void)fetchEngagements
{
    SVTrigger* trigger = [_publisher triggerForEngagementsOfWidth:320 height:548 maxResults:4 withDelegate:self];
    [trigger fetchEngagements];
}

- (SVEngagement*)findEngagementWithLargestRevenueAmount:(NSArray*)engagements
{
    CGFloat greatestRevenue = -1.f;
    SVEngagement* chosenEngagement = nil;
    
    for (SVEngagement* engagement in engagements)
    {
        if (engagement.revenue > greatestRevenue)
        {
            greatestRevenue = engagement.revenue;
            chosenEngagement = engagement;
        }
    }
    
    return chosenEngagement;
}

#pragma mark - SVTriggerDelegate

// pick the engagement that generates the greatest revenue and begin loading it
- (void)trigger:(SVTrigger*)trigger didFetchEngagements:(NSArray*)engagements
{
    if ([engagements count])
    {
        // if you wanted to display the ad with the largest revenue:
        _engagement = [self findEngagementWithLargestRevenueAmount:engagements];
        NSLog(@"bannerImageUrl: %@", _engagement.bannerImageUrl);
        [self loadEngagement];
    }
    else
    {
        [self operationNotAvailable];
        [self removeLoadingView];
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)trigger:(SVTrigger *)trigger didEncounterError:(NSError *)error
{
    [self displayError:error];
    [self removeLoadingView];
}

#pragma mark - SVEngagementViewDelegate

// unhide the engagement view, and discard the loading view
- (void)engagementViewReadyForDisplay:(SVEngagementView*)engagementView
{
    engagementView.alpha = 1;
    [self removeLoadingView];
}

// discard the engagement view and navigate to the next article
- (void)engagementViewShouldClose:(SVEngagementView*)engagementView
{
    [self dismissEngagementView:engagementView];
    
    SocialArticle nextArticle = (_article == SocialArticleFirst) ? SocialArticleSecond : SocialArticleFirst;
    
    SocialArticleVC* vc = [[SocialArticleVC alloc] initWithArticle:nextArticle asInterstitial:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

// do nothing, as we don't care about receiving credit for the interstitial
- (void)engagementView:(SVEngagementView*)engagementView didReceiveCreditPayload:(NSString*)payload andSignature:(NSString*)signature
{
    NSLog(@"engagementView:didReceiveCreditPayload:andSignature:");
}

// here is where you would save the current state of your app before being backgrounded
- (void)engagementViewWillOpenExternalUrl:(SVEngagementView*)engagementView
{
    NSLog(@"engagementViewWillOpenExternalUrl:");
}

- (void)engagementView:(SVEngagementView*)engagementView didEncounterError:(NSError*)error
{
    [self displayError:error];
    [self removeLoadingView];
    [self dismissEngagementView:engagementView];
}

@end
