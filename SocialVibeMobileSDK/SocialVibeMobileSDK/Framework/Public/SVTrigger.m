//
//  SVTrigger.m
//
//  Created on 2012-10-15.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVTrigger.h"
#import "SVConfig+SVConfigPrivate.h"
#import "SVFetchEngagementsRequest.h"
#import "SVNetworkRequestManager.h"
#import "SVNetworkRequest.h"
#import "SVConstants.h"


@interface SVTrigger () <SVNetworkRequestDelegate>
@property (weak) id delegate;
@property (assign) NSUInteger width;
@property (assign) NSUInteger height;
@property (assign) NSUInteger maxActivities;
@property (strong) NSMutableDictionary* fetchEngagementParameters;
@property (strong) NSArray* engagements;
@end


@implementation SVTrigger

#pragma mark - Private Initialization

+ (SVTrigger*)triggerForEngagementsOfWidth:(NSUInteger)width height:(NSUInteger)height maxResults:(NSUInteger)maxResults withDelegate:(id)delegate
{
    return [[SVTrigger alloc] initForEngagementsOfMaxWidth:width maxHeight:height maxResults:maxResults withDelegate:delegate];
}

- (id)initForEngagementsOfMaxWidth:(NSUInteger)width maxHeight:(NSUInteger)height maxResults:(NSUInteger)maxResults withDelegate:(id)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        _width = width;
        _height = height;
        _maxActivities = maxResults;
    }
    return self;
}

#pragma mark - Engagement Fetching

- (void)fetchEngagements
{
    NSMutableDictionary* parameters = _fetchEngagementParameters;
    
    // add to the fetch engagement parameters
    NSMutableDictionary* responseParams = [NSMutableDictionary dictionaryWithCapacity:1];
    [responseParams setValue:[NSNumber numberWithUnsignedInteger:_maxActivities] forKey:kFetchEngagementsResponseMaxActivities];
    [parameters setValue:responseParams forKey:kUserDeviceParametersResponse];
    
    NSMutableDictionary* adSpaceParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [adSpaceParams setValue:[NSNumber numberWithUnsignedInteger:_width] forKey:kFetchEngagementsWidth];
    [adSpaceParams setValue:[NSNumber numberWithUnsignedInteger:_height] forKey:kFetchEngagementsHeight];
    [parameters setValue:adSpaceParams forKey:kUserDeviceParametersAdSpace];
    
    
    // if some optional dictionaries have not been filled out, remove them from the master dictionary
    for (NSString* key in [_fetchEngagementParameters allKeys])
    {
        if ([parameters valueForKey:key] == [NSNull null])
        {
            [parameters removeObjectForKey:key];
        }
    }

    
    SVFetchEngagementsRequest* request = [SVFetchEngagementsRequest requestWithDelegate:self];
    [request performRequestWithParameters:parameters];
}

- (NSArray*)availableEngagements
{
    return _engagements;
}

#pragma mark -

- (void)networkRequest:(SVNetworkRequest*)request didFinishWithError:(NSError*)error
{
    if (error != nil)
    {
        if (![[SVConfig sharedInstance] internetAvailable])
        {
            NSString* errorDomain = kSVErrorDomain;
            NSInteger errorCode = NSURLErrorNotConnectedToInternet;
            NSDictionary* description = @{NSLocalizedDescriptionKey : @"The Internet is currently unavailable."};
            error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:description];
        }
        
        [self reportError:error];
    }
    else if ([request isKindOfClass:[SVFetchEngagementsRequest class]])
    {
        _engagements = [(SVFetchEngagementsRequest*)request fetchedEngagements];
        
        if ([_delegate respondsToSelector:@selector(trigger:didFetchEngagements:)])
        {
            [_delegate trigger:self didFetchEngagements:_engagements];
        }
        else
        {
            [NSException raise:@"SVTriggerDelegate: missing protocol method" format:@"SVSVTrigger's delegate must implement trigger:didFetchEngagements:."];
        }
    }
}

- (void)reportError:(NSError*)error
{
    if ([_delegate respondsToSelector:@selector(trigger:didEncounterError:)])
    {
        [_delegate trigger:self didEncounterError:error];
    }
    else
    {
        [NSException raise:@"SVTriggerDelegate: missing protocol method" format:@"SVSVTrigger's delegate must implement trigger:didEncounterError:."];
    }
}

@end
