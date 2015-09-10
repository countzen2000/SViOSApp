//
//  SVNetworkRequest.m
//
//  Created on 2012-10-16.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVNetworkRequest.h"
#import "SVNetworkRequestManager.h"
#import "SVConstants.h"


@interface SVNetworkRequest ()
@property (assign) BOOL finished;
@end


@implementation SVNetworkRequest

- (id)initWithDelegate:(id<SVNetworkRequestDelegate>)delegate
{
	self = [self init];
    if (self)
    {
        _delegate = delegate;
        _request = nil;
        _parameters = nil;
        _data = nil;
        _operationError = nil;
    }
    return self;
}

- (void)performRequestWithParameters:(NSMutableDictionary*)parameters
{
    _parameters = parameters;
    
    [self generateRequest];
    
    @try
    {
        [[SVNetworkRequestManager sharedInstance] addRequestToQueue:self];
    }
    @catch (NSException *exception)
    {
        [self finish];
    }
}

#pragma mark - Internal Methods

- (void)generateRequest
{
    NSAssert(NO, @"SVNetworkRequest subclass must override generateRequest");
}

- (void)main
{
    NSAssert(_request, @"SVNetworkRequest has nil request object");
    
    dispatch_async(dispatch_queue_create("bkg_op_queue", NULL), ^{
    
        NSURLConnection* connection = [NSURLConnection connectionWithRequest:_request delegate:self];
        if (!connection)
        {
            // create error
            NSString* errorDomain = kSVErrorDomain;
            NSInteger errorCode = NSURLErrorCannotConnectToHost;
            NSDictionary* description = @{NSLocalizedDescriptionKey : @"Cannot establish a connection."};
            _operationError = [NSError errorWithDomain:errorDomain code:errorCode userInfo:description];
            
            // report error
            [self finish];
        }
        else
        {
            while (!self.finished)
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
        
    });
}

- (void)finish
{
    self.finished = YES;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
    
        [_delegate networkRequest:self didFinishWithError:_operationError];
        _delegate = nil;
    });
}

- (void)processData:(NSData*)data withError:(NSError**)error
{
    NSAssert(NO, @"SVNetworkRequest subclass must override processData:withError:");
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    // for debugging purposes
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        DLog(@"Status Code: %d", [(NSHTTPURLResponse*)response statusCode]);
    }
    
    // begin recording data
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // handle error
    _data = nil;
    _operationError = error;
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    // process data
    NSError* error = nil;
    [self processData:self.data withError:&error];
    
    _operationError = error;
    [self finish];
}

@end
