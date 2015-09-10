//
//  SVFetchEngagementsRequest.m
//
//  Created on 2012-10-24.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVFetchEngagementsRequest.h"
#import "SVPublisherInstance.h"
#import "SVEngagement+SVEngagementPrivate.h"
#import "SVConfig+SVConfigPrivate.h"
#import "SVConstants.h"


@interface SVFetchEngagementsRequest ()
@property (strong) NSMutableArray* engagements;
@end


@implementation SVFetchEngagementsRequest

+ (SVFetchEngagementsRequest*)requestWithDelegate:(id<SVNetworkRequestDelegate>)delegate
{
    return [[SVFetchEngagementsRequest alloc] initWithDelegate:delegate];
}

- (void)generateRequest
{
    // could target either production or QA server
    NSURL* fetchEngagementsUrl = [[SVConfig sharedInstance] fetchEngagementsUrl];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:fetchEngagementsUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    // send the request body data (currently in dictionaries) in JSON format
    NSError* error = nil;
    NSData* bodyData = [NSJSONSerialization dataWithJSONObject:self.parameters options:0 error:&error];
    [request setHTTPBody:bodyData];
    

    NSString* contentLength = [NSString stringWithFormat:@"%d", [bodyData length]];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    
    self.request = request;
}

- (void)processData:(NSData*)data withError:(NSError**)error
{
    id response = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:error];
    DLog(@"SVFetchEngagementsRequest response: %@", response);
    
    if ([response isKindOfClass:[NSArray class]])
    {
        _engagements = [NSMutableArray arrayWithCapacity:[response count]];
        
        for (id activity in response)
        {
            if ([activity isKindOfClass:[NSDictionary class]])
            {
                SVEngagement* engagement = [SVEngagement engagementWithProperties:activity];
                [_engagements addObject:engagement];
            }
        }
    }
    else
    {
        // return an error if we get a response we cannot parse
        NSString* errorDomain = kSVErrorDomain;
        NSInteger errorCode = NSURLErrorBadServerResponse;
        NSDictionary* description = @{NSLocalizedDescriptionKey : @"Bad server response."};
        *error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:description];
    }
}

- (NSArray*)fetchedEngagements
{
    return _engagements;
}

@end
