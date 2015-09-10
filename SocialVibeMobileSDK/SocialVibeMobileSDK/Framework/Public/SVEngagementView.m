//
//  SVEngagementView.m
//
//  Created on 2012-10-15.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVEngagementView.h"
#import "SVEngagement+SVEngagementPrivate.h"
#import "SVConfig+SVConfigPrivate.h"
#import "SVConstants.h"
#import "SVAlertView.h"
#import "SVFetchPKPassRequest.h"
#import "UILocalNotification+SVLocalNotification.h"


typedef enum {
    ViewContentTypeEngagement,
    ViewContentTypeNotification,
} ViewContentType;


@interface SVEngagementView () <UIWebViewDelegate, SVNetworkRequestDelegate>
@property (weak) id delegate;
@property (strong) SVEngagement* engagementObject;
@property (strong) UIWebView* webView;
@property (strong) NSMutableData* data;
@property (strong) UIButton* closeButton;
@property (assign) ViewContentType contentType;
@property (assign) BOOL loading;
@property (assign) BOOL ready;
@property (assign) BOOL usingMraidExtensions;
@property (assign) BOOL startCommandReceived;
@property (assign) BOOL observingAppState;

// MRAID properties
@property (copy) NSString* placementType;
@property (copy) NSString* state;
@property (assign) CGSize screenSize;
@property (assign) BOOL viewable;
@end


// constants for JS bridge injection and HTML wrapping
NSString* const kMraidScriptSource = @"<script src=\"mraid.js\"></script>";
NSString* const kMraidExtScriptSource = @"<script src=\"mraid_ext.js\"></script>";
NSString* const kHtmlWrapperTagsHead = @"<html><body style='margin:0;padding:0;'>";
NSString* const kHtmlWrapperTagsTail = @"</body></html>";

CGFloat const closeButtonWidth = 35;
CGFloat const closeButtonHeight = 35;


@implementation SVEngagementView

+ (SVEngagementView*)engagementViewWithDelegate:(id<SVEngagementViewDelegate>)delegate;
{
    return [[SVEngagementView alloc] initWithDelegate:delegate];
}

#pragma mark - Private Initializers

- (id)initWithDelegate:(id)delegate
{
    CGRect fullScreen = [[[UIApplication sharedApplication] keyWindow] frame];
    
    self = [self initWithFrame:fullScreen];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.hidden = YES;
        [self addSubview:_webView];
        
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Application State Monitoring

// while the Engagement View is open, we want to monitor application state so
// as to notify the current engagement in regards to changes in visibility
- (void)beginObservingApplicationStateNotifications
{
    if (!_observingAppState)
    {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [nc addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [nc addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        _observingAppState = YES;
    }
}

- (void)stopObservingApplicationStateNotifications
{
    if (_observingAppState)
    {
         [[NSNotificationCenter defaultCenter] removeObserver:self];
        _observingAppState = NO;
    }
}

- (void)applicationWillTerminate
{
    [self setStateToVisible:NO];
}

- (void)applicationDidEnterBackground
{
    [self setStateToVisible:NO];
}

- (void)applicationWillEnterForeground
{
    [self setStateToVisible:YES];
}

- (void)dealloc
{
    [self stopObservingApplicationStateNotifications];
    DLog(@"stopObservingApplicationStateNotifications");
}

#pragma mark - View Setup

- (BOOL)loadEngagement:(SVEngagement*)engagement
{
    [self assertSuperview];
    [_webView stopLoading];
    _webView.scrollView.scrollEnabled = NO;
    
    
    _contentType = ViewContentTypeEngagement;
    _engagementObject = engagement;
    _startCommandReceived = NO;
    
    
    [self setupViewForEngagement];

    return YES;
}

- (BOOL)loadNotification:(UILocalNotification*)notification
{
    [self assertSuperview];
    [_webView stopLoading];
    _webView.scrollView.scrollEnabled = YES;
    
    
    _contentType = ViewContentTypeNotification;
    
    
    if ([notification isSocialVibeFollowUpNotification])
    {
        NSString* urlString = [notification.userInfo objectForKey:kLocalNotificationFollowUpUrl];
        NSAssert(urlString, @"loadNotification: -- trying to create a URL from nil string");
        NSURL* url = [NSURL URLWithString:urlString];
        

        [self setupViewForFollowUpUrl:url];
        
        return YES;
    }

    return NO;
}

// the web view will not load content if it is not in the current view
// hierarchy, which breaks everything; therefore, we enforce it
- (void)assertSuperview
{
    if (!self.superview)
    {
        [NSException raise:@"SVEngagementView: missing superview" format:@"SVEngagementView must be placed in the view hierarchy before a load operation can be performed."];
    }
}

- (void)setupViewForEngagement
{
    [self setEngagementFrame];
    [self setCloseButton];
    
    NSString* html = [NSString stringWithFormat:@"%@%@%@", kHtmlWrapperTagsHead, _engagementObject.markup, kHtmlWrapperTagsTail];
    NSURL* baseUrl = [NSURL URLWithString:_engagementObject.baseUrl];
    [self loadHTMLString:html baseURL:baseUrl];
}

- (void)setupViewForFollowUpUrl:(NSURL*)url
{
    [self setWebViewWithURL:url];
    [self setCloseButton];
}

- (void)setEngagementFrame
{
    // get engagement size
    CGFloat width = _engagementObject.width;
    CGFloat height = _engagementObject.height;
    
    
    // if the engagement is too large, scale it down so that it fits the screen
    CGFloat horizontalScaleFactor = width / self.frame.size.width;
    CGFloat verticalScaleFactor = height / self.frame.size.height;
    
    CGFloat scaleFactor = MAX(horizontalScaleFactor, verticalScaleFactor);
    if (scaleFactor > 1.f)
    {
        width /= scaleFactor;
        height /= scaleFactor;
    }
    
    
    // centre the webview on the screen
    CGFloat horizontalInset = (self.frame.size.width - width) / 2;
    CGFloat verticalInset = (self.frame.size.height - height) / 2;
    
    _webView.frame = CGRectMake(horizontalInset, verticalInset, width, height);
}

- (void)setWebViewWithURL:(NSURL*)url
{
    // for follow-up URLs we set the webview to be full-screen
    _webView.frame = self.frame;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    [_webView loadRequest:request];
}

// the default close button is 35x35 points, and appears centered over the top right corner of the
// webview, unless the webview goes to the edge of the screen, in which case the button moves inward
- (void)setCloseButton
{
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton addTarget:self action:@selector(closeCommand) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage* buttonImage = [UIImage imageNamed:@"close_button"];
    [_closeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    

    CGPoint webViewTopRightCorner = CGPointMake(_webView.frame.origin.x + _webView.frame.size.width, _webView.frame.origin.y);
    
    // centered on the right edge of the 
    CGFloat horizontal = roundf(MIN(self.frame.size.width - closeButtonWidth, webViewTopRightCorner.x - (closeButtonWidth / 2)));
    CGFloat vertical = roundf(MAX(0, webViewTopRightCorner.y - (closeButtonHeight / 2)));
    
    _closeButton.frame = CGRectMake(horizontal, vertical, closeButtonWidth, closeButtonHeight);
    [self addSubview:_closeButton];
    [self bringSubviewToFront:_closeButton];
}

#pragma mark MRAID Bridge Injection - 

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    // add the JavaScript bridge to the HTML before loading in the webview
    NSString* html = [self injectMraidScripts:string];
    [_webView loadHTMLString:html baseURL:baseURL];
}

- (NSString*)injectMraidScripts:(NSString*)markup
{
    markup = [self addMraidExtensionToMarkup:markup];
    markup = [self addMraidToMarkup:markup];
    
    return markup;
}

- (NSString*)addMraidExtensionToMarkup:(NSString*)markup
{
    // if the supplied markup makes reference to MRAID_EXT.JS,
    // then remove that, but set a flag noting its inclusion
    if ([markup rangeOfString:kMraidExtScriptSource].location != NSNotFound)
    {
        markup = [markup stringByReplacingOccurrencesOfString:kMraidExtScriptSource withString:@""];
        
        // this flag is used so that we know whether or not to wait for a
        // "start" command from the bridge (start is an extension call)
        _usingMraidExtensions = YES;
    }
    else
    {
        _usingMraidExtensions = NO;
    }
    
    return markup;
}

- (NSString*)addMraidToMarkup:(NSString*)markup
{
    // if the supplied markup makes reference to MRAID.JS,
    // then replace that with the actual MRAID script
    if ([markup rangeOfString:kMraidScriptSource].location != NSNotFound)
    {
        // insert path to local MRAID.JS file
        NSString* mraidBundlePath = [[NSBundle mainBundle] pathForResource:@"MRAID" ofType:@"bundle"];
        NSBundle* mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
        NSString* mraidPath = [mraidBundle pathForResource:@"mraid" ofType:@"js"];
        
        if (!mraidPath.length)
        {
            [NSException raise:@"SVEngagementView: missing MRAID bundle" format:@"The MRAID scripts bundled with the SDK could not be found."];
        }
        
        NSURL* mraidUrl = [NSURL fileURLWithPath:mraidPath];
        NSString* mraid = [NSString stringWithContentsOfURL:mraidUrl encoding:NSUTF8StringEncoding error:NULL];
        
        NSString* mraidScript = [NSString stringWithFormat:@"<script type='text/javascript'>%@</script>", mraid];
        markup = [markup stringByReplacingOccurrencesOfString:kMraidScriptSource withString:mraidScript];
    }

    return markup;
}

#pragma mark - SVNetworkRequestDelegate

// this only gets called when downloading a Passbook pass
- (void)networkRequest:(SVNetworkRequest*)request didFinishWithError:(NSError*)error
{
    if ([request isKindOfClass:[SVFetchPKPassRequest class]] && error == nil)
    {
        id pkPass = [(SVFetchPKPassRequest*)request fetchedPKPass];
        
        if ([_delegate respondsToSelector:@selector(engagementView:didReceivePassbookPass:)])
        {
            [_delegate engagementView:self didReceivePassbookPass:pkPass];
        }
    }
    
    else if (error)
    {
        [self reportError:error];
    }
}

#pragma mark - JavaScript-ObjC Command Processing

// break the URL passed by the bridge into the command portion (before question mark) and parameter portion (after question mark)
- (void)interpretCommandString:(NSString*)commandString
{
    NSArray* commandAndParams = [commandString componentsSeparatedByString:@"?"];
    
    
    NSString* command = [[commandAndParams objectAtIndex:0] lowercaseString];
    NSDictionary* parameters = nil;
    
    if ([commandAndParams count] == 2)
    {
        NSString* parameterString = [commandAndParams objectAtIndex:1];

        // don't want to remove the percent escapes for the credit command
        if (![command isEqualToString:kMraidCommandCredit])
        {
            parameterString = [parameterString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        
        if ([command isEqualToString:kMraidCommandOpen])
        {
            parameters = [self urlParametersFromString:parameterString];
        }
        else
        {
            parameters = [self parametersFromString:parameterString];
        }
    }
    
    [self executeCommand:command withParameters:parameters];
}

// break each of the parameters in the parameter string into separate KV-pairs in a dictionary
- (NSDictionary*)parametersFromString:(NSString*)parameterString
{
    // parameters are separated by the ampersand
    NSArray* arrayOfParameters = [parameterString componentsSeparatedByString:@"&"];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:[arrayOfParameters count]];
    
    for (NSString* keyValuePair in arrayOfParameters)
    {
        [self addKeyValuePairFromString:keyValuePair toDictionary:parameters];
    }
    
    return parameters;
}

// separate the parameter string into the URL key and value pair; this method is used as opposed to
// parametersFromString: as we don't want to break a URL apart if it contains an ampersands within
- (NSDictionary*)urlParametersFromString:(NSString*)parameterString
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [self addKeyValuePairFromString:parameterString toDictionary:parameters];
    
    return parameters;
}

// break a string into key-value pairs, separated by the '=' sign
- (void)addKeyValuePairFromString:(NSString*)parameterString toDictionary:(NSMutableDictionary*)parameters
{
    // each parameter has a key indicating the parameter type, and its value
    NSUInteger keyValueSeparator = [parameterString rangeOfString:@"="].location;
    if (keyValueSeparator != NSNotFound)
    {
        NSString* key = [parameterString substringToIndex:keyValueSeparator];
        NSString* value = [parameterString substringFromIndex:(keyValueSeparator+1)];
        
        [parameters setObject:value forKey:key];
    }
}

- (void)executeCommand:(NSString *)command withParameters:(NSDictionary *)parameters
{
    DLog(@"\nreceived command: %@ \nparameters: %@", command, parameters);

    
    // MRAID 1.0 COMMANDS
    if ([command isEqualToString:kMraidCommandOpen])
    {
        [self openCommand:parameters];
    }
    else if ([command isEqualToString:kMraidCommandClose])
    {
        [self closeCommand];
    }
    else if ([command isEqualToString:kMraidCommandUseCustomClose])
    {
        [self useCustomCloseCommand:parameters];
    }
    else if ([command isEqualToString:kMraidCommandExpand])
    {
        [self expandCommand:parameters];
    }
    
    // MRAID EXT COMMANDS
    else if ([command isEqualToString:kMraidCommandStart])
    {
        // some ads send multiple "start" commands in a row; we only want
        // to tell our delegate that we're ready to be displayed one time
        if (!_startCommandReceived)
        {
            _startCommandReceived = YES;
            [self startCommand];
        }
    }
    else if ([command isEqualToString:kMraidCommandCredit])
    {
        [self creditCommand:parameters];
    }
    else if ([command isEqualToString:kMraidCommandFinish])
    {
        [self finishCommand];
    }
    
    // iOS COMMANDS
    else if ([command isEqualToString:kMraidCommandNotification] && [[SVConfig sharedInstance] localNotificationsEnabled])
    {
        [self notificationCommand:parameters];
    }
    else if ([command isEqualToString:kMraidCommandPassbook] && [[SVConfig sharedInstance] passbookPassesEnabled])
    {
        [self passbookCommand:parameters];
    }

    [self fireNativeCommandCompleteEvent:command];
}

// open the URL in the external browser
- (void)openCommand:(NSDictionary*)parameters
{
    if ([_delegate respondsToSelector:@selector(engagementViewWillOpenExternalUrl:)])
    {
        [_delegate engagementViewWillOpenExternalUrl:self];
    }
    else
    {
        [NSException raise:@"SVEngagementViewDelegate: missing protocol method" format:@"SVEngagementView's delegate must implement engagementViewWillOpenExternalUrl:."];
    }
    
    NSString* urlString = [parameters valueForKey:kMraidCommandOpenExternalUrlKey];
    NSURL* url = [NSURL URLWithString:urlString];
    [self openExternalUrlAfterDelay:url];
}

// prep for engagement shutdown and notify delegate that engagement view should be discarded
- (void)closeCommand
{
    [self setStateToVisible:NO];
    
    if ([_delegate respondsToSelector:@selector(engagementViewShouldClose:)])
    {
        [_delegate engagementViewShouldClose:self];
    }
    else
    {
        [NSException raise:@"SVEngagementViewDelegate: missing protocol method" format:@"SVEngagementView's delegate must implement engagementViewShouldClose:."];
    }
}

// remove the default close button
- (void)useCustomCloseCommand:(NSDictionary*)parameters
{
    BOOL shouldUseCustomClose = [[parameters valueForKey:kMraidCommandUseCustomCloseKey] boolValue];
    
    if (shouldUseCustomClose)
    {
        [_closeButton removeFromSuperview];
        _closeButton = nil;
    }
}

// do nothing for v1.0
- (void)expandCommand:(NSDictionary*)parameters
{
    // expand not supported in this version
    // all engagements are full-screen
}

// notify the delegate that the engagement has finished loading and is ready to be displayed
- (void)startCommand
{
    if ([_delegate respondsToSelector:@selector(engagementViewReadyForDisplay:)])
    {
        [_delegate engagementViewReadyForDisplay:self];
    }
    else
    {
        [NSException raise:@"SVEngagementViewDelegate: missing protocol method" format:@"SVEngagementView's delegate must implement engagementViewReadyForDisplay:."];
    }
}

// forward the credit payload and signature to the delegate
- (void)creditCommand:(NSDictionary*)parameters
{
    if ([_delegate respondsToSelector:@selector(engagementView:didReceiveCreditPayload:andSignature:)])
    {
        NSString* payload = [[parameters valueForKey:kEngagementCreditPayload] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* signature = [parameters valueForKey:kEngagementCreditSignature];
        [_delegate engagementView:self didReceiveCreditPayload:payload andSignature:signature];
    }
    else
    {
        [NSException raise:@"SVEngagementViewDelegate: missing protocol method" format:@"SVEngagementView's delegate must implement engagementView:didReceiveCreditPayload:andSignature:."];
    }
}

// notify the delegate the the engagement flow has finished
- (void)finishCommand
{
    if ([_delegate respondsToSelector:@selector(engagementViewDidFinish:)])
    {
        [_delegate engagementViewDidFinish:self];
    }
}

// download the passbook pass; when the download completes, the request
// callback will return the PKPass to be forwarded to the delegate
- (void)passbookCommand:(NSDictionary*)parameters
{
    SVFetchPKPassRequest* request = [SVFetchPKPassRequest requestWithDelegate:self];
    [request performRequestWithParameters:parameters];
}

// display an UIAlertView asking if the user would like to schedule a notification
- (void)notificationCommand:(NSDictionary*)parameters
{
    [self promptUserToSetNotificationWithParameters:parameters];
}

#pragma mark - Local Notification Scheduling

- (void)promptUserToSetNotificationWithParameters:(NSDictionary*)parameters
{
    NSString* fireDate = [parameters valueForKey:kLocalNotificationFireDate];
    NSString* promptText = [parameters valueForKey:kLocalNotificationPromptText];
    NSString* notificationText = [parameters valueForKey:kLocalNotificationNotificationText];
    NSString* followUpUrl = [parameters valueForKey:kLocalNotificationFollowUpUrl];
    
    
    SVAlertView* prompt = [[SVAlertView alloc] initWithTitle:@"Set Notification"
                                                     message:promptText
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Continue", nil];
    
    prompt.fireDate = fireDate;
    prompt.notificationText = notificationText;
    prompt.followUpUrl = followUpUrl;
    
    [prompt show];
}

- (void)alertView:(SVAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if the user has chosen to schedule a local notification:
    if (buttonIndex == 1)
    {
        [self scheduleLocalNotificationFromPrompt:alertView];
    }
}

- (void)scheduleLocalNotificationFromPrompt:(SVAlertView*)prompt
{
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [self dateFromString:[prompt fireDate]];
    notification.alertBody = [prompt notificationText];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    
    // used by the UILocalNotification category methods for
    // determining if the notification was scheduled by the SDK
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:kSocialVibeNotificationName forKey:kSocialVibeNotificationTag];
    
    
    // follow-up URL is optional
    NSString* followUpUrl = [prompt followUpUrl];
    if ([[followUpUrl lowercaseString] rangeOfString:@"http://"].location != NSNotFound)
    {
        [userInfo setValue:followUpUrl forKey:kLocalNotificationFollowUpUrl];
    }
    
    notification.userInfo = userInfo;

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (NSDate*)dateFromString:(NSString*)dateString
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
    NSDate* date = [dateFormatter dateFromString: dateString];
    
    return date;
}

#pragma mark - ObjC-Javascript Communication

// MRAID callbacks setting initial ad state, sent once per engagement after the webview has finished loading
- (void)setPropertiesAndReady
{
    _placementType = @"interstitial";
    _screenSize = [[UIApplication sharedApplication] keyWindow].frame.size;
    
    [self fireChangeEventForProperty:kEngagementsViewPropertyPlacement];
    [self fireChangeEventForProperty:kEngagementsViewPropertySize];
    [self setStateToVisible:YES];
    [self fireReadyEvent];
    
    
    // with the engagement loaded, begin monitoring the application
    // state so that visibility properties can be updated accordingly
    [self beginObservingApplicationStateNotifications];
    
    
    // if the current engagement doesn't use MRAID extensions, we don't need to wait to receive a start command;
    // if loading a notification URL, don't need to wait for MRAID callbacks as there are none
    if (!_usingMraidExtensions || _contentType == ViewContentTypeNotification)
    {
        if (!_startCommandReceived)
        {
            _startCommandReceived = YES;
            [self startCommand];
        }
    }
    
    _ready = YES;
}

// hide/unhide the engagement, and send MRAID callbacks notifying of state change
- (void)setStateToVisible:(BOOL)visible
{
    _webView.hidden = !visible;
    _state = visible ? @"default" : @"hidden";
    _viewable = visible;
    
    [self fireChangeEventForProperty:kEngagementsViewPropertyState];
    [self fireChangeEventForProperty:kEngagementsViewPropertyVisible];
}

// convenience method for formatting properties to be sent as JSON
- (NSString*)propertyValueForKey:(NSString*)key
{
    NSString* formattedProperty = nil;
    
    if ([key isEqualToString:kEngagementsViewPropertyPlacement])
    {
        formattedProperty = [NSString stringWithFormat:@"%@: '%@'", key, _placementType];
    }
    else if ([key isEqualToString:kEngagementsViewPropertyState])
    {
        formattedProperty = [NSString stringWithFormat:@"%@: '%@'", key, _state];
    }
    else if ([key isEqualToString:kEngagementsViewPropertySize])
    {
        formattedProperty = [NSString stringWithFormat:@"%@: {width: %f, height: %f}", key, _screenSize.width, _screenSize.height];
    }
    else if ([key isEqualToString:kEngagementsViewPropertyVisible])
    {
        formattedProperty = [NSString stringWithFormat:@"%@: '%@'", key, (_viewable ? @"true" : @"false")];
    }
    
    return formattedProperty;
}

// notify MRAID bridge of property state change
- (void)fireChangeEventForProperty:(NSString*)propertyKey
{
    NSString* property = [self propertyValueForKey:propertyKey];
    DLog(@"Sending property change event: {%@}", property);
    
    NSString* javaScript = [NSString stringWithFormat:@"window.mraidbridge.fireChangeEvent({%@});", property];
    [self runJavaScriptString:javaScript];
}

// notify MRAID bridge once everything is done loading
- (void)fireReadyEvent
{
    DLog(@"Sending ready event");
    [self runJavaScriptString:@"window.mraidbridge.fireReadyEvent();"];
}

// sent after each received command has been acted upon
// (if not sent, no further communication will be possible)
- (void)fireNativeCommandCompleteEvent:(NSString *)command
{
    NSString* javaScript = [NSString stringWithFormat:@"window.mraidbridge.nativeCallComplete('%@');", command];
    [self runJavaScriptString:javaScript];
}

// execute the JavaScript string in the webview
- (NSString*)runJavaScriptString:(NSString*)javascript
{
    return [_webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = NO;
    
    
    if (_contentType == ViewContentTypeEngagement)
    {
        shouldLoad = [self engagementShouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    else if (_contentType == ViewContentTypeNotification)
    {
        shouldLoad = [self notificationShouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    
    return shouldLoad;
}

// determine what to do with the URL passed from the loaded engagement
- (BOOL)engagementShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = NO;

    
    NSURL* url = [request URL];
    NSString* scheme = [url scheme];

    
    // process MRAID commands locally
    if ([scheme isEqualToString:@"mraid"])
    {
        NSString* requestUrl = [url absoluteString];
        NSString* commandString = [requestUrl stringByReplacingOccurrencesOfString:@"mraid://" withString:@""];
        [self interpretCommandString:commandString];
    }
    
    // ignore logging, as it's for debugging
    else if ([scheme isEqualToString:@"ios-log"])
    {
        // ignore logging
        DLog(@"%@", url);
    }
    
    // load links clicked in the ads in the native browser
    else if (!_loading && navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if ([self validURL:url])
        {
            [self openExternalUrlAfterDelay:url];
        }
    }
    
    // load standard URL's
    else
    {
        if ([self validURL:url])
        {
            shouldLoad = YES;
        }
    }
    
    return shouldLoad;
}

// validate URL as proper HTTP or HTTPS link
- (BOOL)validURL:(NSURL*)url
{
    BOOL validUrl = NO;
    
    NSString* scheme = [url scheme];
    if ([scheme rangeOfString:@"http"].location != NSNotFound)
    {
        NSString* urlString = [url absoluteString];
        if (![[urlString substringFromIndex:(urlString.length - 1)] isEqualToString:@"#"])
        {
            validUrl = YES;
        }
    }
    
    return validUrl;
}

// when loading a follow-up URL from a notification, load the initial page in the engagement view;
// load subsequent link clicks in the external browser
- (BOOL)notificationShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = YES;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        shouldLoad = NO;
        
        NSURL* url = [request URL];
        [self openExternalUrlAfterDelay:url];
    }
    
    return shouldLoad;
}

// open the url in the native brower, after a delay, so that the
// current run loop can finish and appropriate callbacks are made
- (void)openExternalUrlAfterDelay:(NSURL*)url
{
    [self performSelector:@selector(openUrlInNativeBrowser:) withObject:url afterDelay:0];
}

- (void)openUrlInNativeBrowser:(NSURL*)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DLog(@"webViewDidStartLoad:");
    _loading = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog(@"webViewDidFinishLoad:");
    _loading = NO;
    
    
    if (!_ready)
    {
        if (_webView.loading)
        {
            // once in a blue moon the webview will make the webViewDidFinishLoad: callback before actually
            // changing the state of its loading variable; in this case we add a delay (non-zero because
            // we can't guarantee that the change will happen on the next cycle through the run loop)
            [self performSelector:@selector(setPropertiesAndReady) withObject:nil afterDelay:1];
        }
        else
        {
            [self setPropertiesAndReady];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"webView: didFailLoadWithError: %@", error);
    _loading = NO;
    
    
    // unless the loading request was cancelled, pass the error along
    if (!([error code] == NSURLErrorCancelled))
    {
        [self reportError:error];
    }
}

#pragma mark

// notify the delegate of errors that occur, allowing it to decide on the follow-up action
- (void)reportError:(NSError*)error
{
    if ([_delegate respondsToSelector:@selector(engagementView:didEncounterError:)])
    {
        [_delegate engagementView:self didEncounterError:error];
    }
    else
    {
        [NSException raise:@"SVEngagementViewDelegate: missing protocol method" format:@"SVEngagementView's delegate must implement engagementView:didEncounterError:."];
    }
}

@end
