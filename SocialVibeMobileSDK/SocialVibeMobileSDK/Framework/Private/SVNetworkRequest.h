//
//  SVNetworkRequest.h
//
//  Created on 2012-10-16.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    Template class for handling network requests.
 */

@protocol SVNetworkRequestDelegate;

@interface SVNetworkRequest : NSOperation <NSURLConnectionDelegate>
// The network request maintains a strong reference to the delegate so that
// after a trigger has been created and told to make a fetch, the app using
// the SDK does not need to explicitly retain the trigger object itself to
// receive the fetched engagements. When the network request finishes, it
// sends its delegate callback and then releases its delegate before being
// dealloc'd; if no one else is explicitly holding onto the trigger object
// at this point, it will be dealloc'd after sending its callback as well.
@property (strong) id delegate;
@property (strong) NSMutableURLRequest* request;
@property (strong) NSDictionary* parameters;
@property (strong) NSMutableData* data;
@property (strong) NSError* operationError;

- (id)initWithDelegate:(id<SVNetworkRequestDelegate>)delegate;

- (void)generateRequest;

- (void)performRequestWithParameters:(NSDictionary*)parameters;

- (void)processData:(NSData*)data withError:(NSError**)error;

- (void)finish;

@end


@protocol SVNetworkRequestDelegate <NSObject>

- (void)networkRequest:(SVNetworkRequest*)request didFinishWithError:(NSError*)error;

@end