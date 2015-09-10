//
//  SVNetworkRequestManager.m
//
//  Created on 2012-10-16.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVNetworkRequestManager.h"
#import "SVNetworkRequest.h"


@interface SVNetworkRequestManager ()
@property (strong) NSMutableDictionary* requestDelegatePairs;
- (NSOperationQueue*)serverOperationQueue;
@end


@implementation SVNetworkRequestManager

+ (SVNetworkRequestManager*)sharedInstance
{
    static SVNetworkRequestManager* serverMediator = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serverMediator = [[SVNetworkRequestManager alloc] init];
    });
    
    return serverMediator;
}

- (NSOperationQueue*)serverOperationQueue
{
	static NSOperationQueue* operationQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [NSOperationQueue new];
		[operationQueue setMaxConcurrentOperationCount:1];
    });

	return operationQueue;
}

- (void)addRequestToQueue:(SVNetworkRequest*)request
{
    [[self serverOperationQueue] addOperation:request];
}

@end
