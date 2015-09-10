//
//  SocialSectionLandingVC.m
//  SocialVibeSampleApp
//
//  Created on 2012-11-02.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SocialSectionLandingVC.h"
#import "SocialAppDelegate.h"
#import "SocialArticleVC.h"
#import "SocialWatchOrEngageGatingView.h"
#import "SocialFreePassGatingView.h"
#import <PassKit/PassKit.h>

@interface SocialSectionLandingVC () <SocialWatchOrEngageDelegate, SocialFreePassDelegate, PKAddPassesViewControllerDelegate>
@property (assign) SectionLandingType sectionType;
@property (strong) SVPublisherInstance* publisher;
@property (strong) SVEngagement* engagement;
@property (strong) UIView* gatingView;
@property (strong) UIView* loadingView;
@property (strong) NSMutableData* imageData;
@property (assign) BOOL didReceiveCredit;
@property (assign) BOOL triggerDisabled;
@end

@implementation SocialSectionLandingVC

- (id)initWithType:(SectionLandingType)type
{
    self = [super init];
    if (self)
    {
        _sectionType = type;
    }
    return self;
}

- (SocialAppDelegate*)appDelegate
{
    return (SocialAppDelegate*)[[UIApplication sharedApplication] delegate];
}

// setup the view depending on which selection was made on the main page
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    if (_sectionType == SectionLandingTypeContentGate)
    {
        [self setupViewForContentGate];
    }
    else if (_sectionType == SectionLandingTypeInterstitial)
    {
        [self setupViewForInterstitial];
    }
    else if (_sectionType == SectionLandingTypePassbook)
    {
        [self setupViewForPassbook];
    }
    else if (_sectionType == SectionLandingTypeBanner)
    {
        [self setupViewForExpandableBanner];
    }
    else if (_sectionType == SectionLandingTypeNotification)
    {
        [self setupViewForLocalNotification];
    }
}

- (void)navigateToNextScreen
{
    // ignore subsequent ad-launching gestures while the current activity is underway
    if (!_triggerDisabled)
    {
        _triggerDisabled = YES;
        
        switch (_sectionType)
        {
            case SectionLandingTypeContentGate:
            {
                [self presentContentGate];
                break;
            }
            case SectionLandingTypeInterstitial:
            {
                [self loadFirstArticle];
                break;
            }
            case SectionLandingTypeNotification:
            {
                break;
            }
            case SectionLandingTypePassbook:
            {
                [self presentExpandedEngagement];
                break;
            }
            case SectionLandingTypeBanner:
            {
                [self presentExpandedEngagement];
                break;
            }
        }
    }
}

#pragma mark - Loading

// create a black view that occupies the entire screen, with loading spinner in the center, to be displayed while an engagement is loading
- (void)createLoadingView
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    _loadingView = [[UIView alloc] initWithFrame:window.frame];
    _loadingView.backgroundColor = [UIColor blackColor];
    [window addSubview:_loadingView];
    
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect spinnerFrame = spinner.frame;
    
    // center the activity indicator in the loading view
    spinnerFrame.origin.x = (window.frame.size.width - spinnerFrame.size.width) / 2;
    spinnerFrame.origin.y = (window.frame.size.height - spinnerFrame.size.height) / 2;
    spinner.frame = spinnerFrame;
    
    [spinner startAnimating];
    [_loadingView addSubview:spinner];
}

- (void)fadeInLoadingView
{
    _loadingView.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         _loadingView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                             self.navigationController.navigationBarHidden = YES;
                     }];
}

- (void)removeLoadingView
{
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

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

#pragma mark - Engagements

// fetch engagements with a maximum size matching the size of an iPhone 5 screen (in points)
- (void)fetchEngagements
{    
    SVTrigger* trigger = [_publisher triggerForEngagementsOfWidth:320 height:548 maxResults:4 withDelegate:self];
    [trigger fetchEngagements];
}

// create a new engagement view, add it to the view hierarchy, and pass it an engagement to load
- (void)loadEngagement
{
    SVEngagementView* engagementView = [SVEngagementView engagementViewWithDelegate:self];
    engagementView.alpha = 0;
    [self.view addSubview:engagementView];
    
    [engagementView loadEngagement:_engagement];
}

- (void)dismissEngagementView:(SVEngagementView*)engagementView
{
    self.navigationController.navigationBarHidden = NO;
    
    
    // flip transition for dismissing the content gate engagement view
    if (_sectionType == SectionLandingTypeContentGate)
    {
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:engagementView];
        
        [UIView transitionWithView:engagementView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            engagementView.alpha = 0;
                        }
                        completion:^(BOOL finished) {
                             [engagementView removeFromSuperview];
                             _triggerDisabled = NO;
                        }];
    }
    // fade-out transition for dismissing local notification engagement view
    else if (_sectionType == SectionLandingTypeNotification)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             engagementView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [engagementView removeFromSuperview];
                         }];
    }
    // slide transition for dismissing banner and passbook engagement views
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect frame = engagementView.frame;
                             frame.origin.y = frame.size.height;
                             engagementView.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [engagementView removeFromSuperview];
                             _triggerDisabled = NO;
                         }];
    }
}

#pragma mark - SVTriggerDelegate

- (void)trigger:(SVTrigger*)trigger didFetchEngagements:(NSArray*)engagements
{
    // display an engagement (generating largest revenue) if there is one available
    if ([engagements count])
    {
        _engagement = [engagements objectAtIndex:0];
        
        
        // use the bannerImageUrl on the selected SVEngagement object to create a banner
        if (_sectionType == SectionLandingTypePassbook || _sectionType == SectionLandingTypeBanner)
        {
            [self fetchBannerImage];
        }
        // or display the engagement itself
        else if (_sectionType == SectionLandingTypeContentGate)
        {
            [self loadEngagement];
            self.navigationController.navigationBarHidden = YES;
        }
    }
    else
    {
        [self operationNotAvailable];
        [self removeLoadingView];
        self.navigationController.navigationBarHidden = NO;
        _triggerDisabled = NO;
    }
}

// if we can't fetch an engagement, here we display the error, remove the loading view, and reset the state of the current screen
- (void)trigger:(SVTrigger *)trigger didEncounterError:(NSError *)error
{
    [self displayError:error];
    [self removeLoadingView];
    
    self.navigationController.navigationBarHidden = NO;
    _triggerDisabled = NO;
}

#pragma mark - SVEngagementViewDelegate

// unhide the engagement view, and discard the loading view
- (void)engagementViewReadyForDisplay:(SVEngagementView*)engagementView
{
    engagementView.alpha = 1;
    [self removeLoadingView];
}

// hide and discard the engagement view;
// if credit has been received for completion, present the reward (Content Gate and Local Notifications only)
- (void)engagementViewShouldClose:(SVEngagementView*)engagementView
{
    [self dismissEngagementView:engagementView];
    
    if (_didReceiveCredit)
    {
        if (_sectionType == SectionLandingTypeContentGate)
        {
            SocialArticleVC* vc = [[SocialArticleVC alloc] initWithArticle:SocialArticleFirst asInterstitial:NO];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        else if (_sectionType == SectionLandingTypeNotification)
        {
            [_gatingView removeFromSuperview];
            _gatingView = nil;
        }
    }
}

// use the SVPublisherInstance (the same one used to produce the engagement, as the secret keys are unique for each placement ID) to validate completion
- (void)engagementView:(SVEngagementView*)engagementView didReceiveCreditPayload:(NSString*)payload andSignature:(NSString*)signature
{
    _didReceiveCredit = [_publisher validateCreditPayload:payload withSignature:signature];
}

// present the PKPass object to the user to be added to their Passbook, or discarded
- (void)engagementView:(SVEngagementView*)engagementView didReceivePassbookPass:(PKPass*)pass
{
    PKAddPassesViewController* passbookController = [[PKAddPassesViewController alloc] initWithPass:pass];
    passbookController.delegate = self;
    [self.navigationController presentViewController:passbookController animated:NO completion:NULL];
    
    [self dismissEngagementView:engagementView];
}

// for purposes of the demo only, we display an error indicating that the engagement
// could not be loaded, so that the user knows that the demo cannot progress
- (void)engagementView:(SVEngagementView*)engagementView didEncounterError:(NSError*)error
{
    [self displayError:error];
    [self removeLoadingView];
    [self dismissEngagementView:engagementView];
}

- (void)engagementViewDidFinish:(SVEngagementView*)engagementView
{
    // here is where you could display a UIAlertView indicating successful completion of an engagement
    NSLog(@"engagementViewDidFinish:");
}

- (void)engagementViewWillOpenExternalUrl:(SVEngagementView*)engagementView
{
    // here is where you would save the current state of your app before being backgrounded
    NSLog(@"engagementViewWillOpenExternalUrl:");
}

#pragma mark - NSURLConnectionDelegate
/*
 These methods are used to download an image for an expandable banner from and SVEngagement object's bannerImageUrl.
 */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.imageData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection:didFailWithError: %@", error);
    
    // for the purposes of this demo, if the image could not be constructed, use a placeholder instead
    UIImage* image = [UIImage imageNamed:@"banner_placeholder"];
    [self createBannerWithImage:image];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage* image = [[UIImage alloc] initWithData:_imageData];
    self.imageData = nil;
    
    // for the purposes of this demo, if the image could not be constructed, use a placeholder instead
    if (!image)
    {
        image = [UIImage imageNamed:@"banner_placeholder"];
    }

    [self createBannerWithImage:image];
}

#pragma mark
#pragma mark Demo Sections

#pragma mark - Content Gate

// for the purposes of this demo, when a user taps anywhere in the view, the content gate will appear
- (void)setupViewForContentGate
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToNextScreen)];
    [self.view addGestureRecognizer:tap];
}

// fade in the blocking content gate
- (void)presentContentGate
{
    _gatingView = [[SocialWatchOrEngageGatingView alloc] initWithDelegate:self];
    _gatingView.alpha = 0;
    [self.view addSubview:_gatingView];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _gatingView.alpha = 1;
                     }];
}

- (void)watchVideoButtonPressed
{
    // use the publisher instance that returns videos
    _publisher = [[self appDelegate] publisherInstanceForVideo];
    [self displayContentGateEngagement];
}

- (void)engageWithSponsorButtonPressed
{
    // use the publisher instance that returns interactive engagements
    _publisher = [[self appDelegate] publisherInstanceForEngagements];
    [self displayContentGateEngagement];
}

// display the loading view before the engagement has loaded, and discard the blocking content gate view
- (void)displayContentGateEngagement
{
    [self fetchEngagements];
    [self createLoadingView];

    // flip transition
    [UIView transitionWithView:self.view
                      duration:0.6
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.view addSubview:_loadingView];
                        self.navigationController.navigationBarHidden = YES;
                    }
                    completion:^(BOOL finished) {
                        [_gatingView removeFromSuperview];
                        _gatingView = nil;
                    }];
}

#pragma mark - Interstitial

// tap anywhere in the view to navigate to an article
- (void)setupViewForInterstitial
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToNextScreen)];
    [self.view addGestureRecognizer:tap];
}

// the interstitial demo continues in SocialArticleVC
- (void)loadFirstArticle
{
    SocialArticleVC* vc = [[SocialArticleVC alloc] initWithArticle:SocialArticleFirst asInterstitial:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Local Notification

- (void)setupViewForLocalNotification
{
    // use the publisher instance that returns the engagement that demonstrates local notifications
    _publisher = [[self appDelegate] publisherInstanceForNotifications];
    [self fetchEngagements];
    
    // display a gating view that prompts the user to engage
    _gatingView = [[SocialFreePassGatingView alloc] initWithDelegate:self];
    [self.view addSubview:_gatingView];
}

- (void)freePassButtonPressed
{
    if (_engagement)
    {
        [self createLoadingView];
        [self fadeInLoadingView];
        [self loadEngagement];
    }
    else
    {
        [self operationNotAvailable];
    }
}

#pragma mark - Passbook

- (void)setupViewForPassbook
{
    // use the publisher instance that returns the engagement that demonstrates Passbook
    _publisher = [[self appDelegate] publisherInstanceForPassbook];
    [self fetchEngagements];
}

// PKAddPassesViewController delegate method
- (void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Expandable Banner

- (void)setupViewForExpandableBanner
{
    _publisher = [[self appDelegate] publisherInstanceForEngagements];
    [self fetchEngagements];
}

- (void)presentExpandedEngagement
{
    [self createLoadingView];
    [self loadEngagement];
    
    
    // move the loading view to below the screen, and animate it sliding up
    CGRect loadingViewFrame = _loadingView.frame;
    loadingViewFrame.origin.y = loadingViewFrame.size.height;
    _loadingView.frame = loadingViewFrame;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect loadingViewFrame = _loadingView.frame;
                         loadingViewFrame.origin.y = 0;
                         _loadingView.frame = loadingViewFrame;
                     }
                     completion:^(BOOL finished) {
                         self.navigationController.navigationBarHidden = YES;
                     }];
}

- (void)fetchBannerImage
{
    NSURL* url = [NSURL URLWithString:_engagement.bannerImageUrl];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection)
    {
        self.imageData = [NSMutableData data];
    }
}

// create a tappable banner, which is a button with the banner image
- (void)createBannerWithImage:(UIImage*)bannerImage
{
    // banner centered at the bottom of the screen
    CGFloat bannerWidth = bannerImage.size.width;
    CGFloat bannerHeight = bannerImage.size.height;
    CGFloat leftInset = (self.view.frame.size.width - bannerWidth) / 2;
    CGFloat topInset = self.view.frame.size.height - bannerHeight;
    CGRect bannerFrame = CGRectMake(leftInset, topInset, bannerWidth, bannerHeight);
    

    UIButton* expandableBanner = [UIButton buttonWithType:UIButtonTypeCustom];
    [expandableBanner setImage:bannerImage forState:UIControlStateNormal];
    [expandableBanner addTarget:self action:@selector(navigateToNextScreen) forControlEvents:UIControlEventTouchUpInside];
    expandableBanner.frame = bannerFrame;
    [self.view addSubview:expandableBanner];
}

@end
