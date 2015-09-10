//
//  SVTrigger+SVTriggerPrivate.h
//
//  Created on 2012-10-29.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Private methods accessible only to other SDK classes.
 */

#import "SVTrigger.h"

@interface SVTrigger ()
@property (strong) NSMutableDictionary* fetchEngagementParameters;

+ (SVTrigger*)triggerForEngagementsOfWidth:(NSUInteger)width height:(NSUInteger)height maxResults:(NSUInteger)maxResults withDelegate:(id)delegate;

@end
