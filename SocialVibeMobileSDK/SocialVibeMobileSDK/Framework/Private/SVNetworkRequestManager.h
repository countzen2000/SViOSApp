//
//  SVNetworkRequestManager.h
//
//  Created on 2012-10-16.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Serial operation queue.
 */

#import <Foundation/Foundation.h>

@class SVNetworkRequest;

@interface SVNetworkRequestManager : NSObject

+ (SVNetworkRequestManager*)sharedInstance;

- (void)addRequestToQueue:(SVNetworkRequest*)request;

@end
