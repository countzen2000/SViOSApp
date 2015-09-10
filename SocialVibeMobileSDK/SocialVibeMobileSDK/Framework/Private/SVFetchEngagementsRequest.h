//
//  SVFetchEngagementsRequest.h
//
//  Created on 2012-10-24.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVNetworkRequest.h"

/*
    Download engagements.
 */

@interface SVFetchEngagementsRequest : SVNetworkRequest

+ (SVFetchEngagementsRequest*)requestWithDelegate:(id<SVNetworkRequestDelegate>)delegate;
- (NSArray*)fetchedEngagements;

@end
