//
//  SVFetchPKPassRequest.m
//
//  Created on 2012-11-14.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVFetchPKPassRequest.h"
#import "SVConstants.h"
#import <PassKit/PassKit.h>


@interface SVFetchPKPassRequest ()
@property (strong) id pkPass;
@end


@implementation SVFetchPKPassRequest

+ (SVFetchPKPassRequest*)requestWithDelegate:(id<SVNetworkRequestDelegate>)delegate
{
    return [[SVFetchPKPassRequest alloc] initWithDelegate:delegate];
}

- (void)generateRequest
{
    NSString* passUrlString = [self.parameters valueForKey:kPassbookPassUrl];
    NSURL* pkPassUrl = [NSURL URLWithString:passUrlString];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:pkPassUrl];
    
    self.request = request;
}

- (void)processData:(NSData*)data withError:(NSError**)error
{
    // to have gotten this far, the PassKit.framework must have already been added to the project;
    // however, if PassKit is not available and Passbook not enabled, use NSClassFromString to prevent
    // the importing project's compiler from generating an error
    Class passClass = NSClassFromString(@"PKPass");
    if (passClass)
    {
        _pkPass = [[passClass alloc] initWithData:data error:error];
    }
}

- (id)fetchedPKPass
{
    return _pkPass;
}

@end
