//
//  SVFetchPKPassRequest.h
//
//  Created on 2012-11-14.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVNetworkRequest.h"

/*
    Download data for Passbook passes and return PKPass object.
 */

@interface SVFetchPKPassRequest : SVNetworkRequest

+ (SVFetchPKPassRequest*)requestWithDelegate:(id<SVNetworkRequestDelegate>)delegate;
- (id)fetchedPKPass;

@end
