//
//  SVEngagement+SVEngagementPrivate.h
//
//  Created on 2012-10-26.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Private methods accessible only to other SDK classes.
 */

#import "SVEngagement.h"

@interface SVEngagement ()
@property (assign) NSUInteger width;
@property (assign) NSUInteger height;
@property (copy) NSString* name;
@property (copy) NSString* displayText;
@property (copy) NSString* baseUrl;
@property (copy) NSString* engagementId;
@property (copy) NSString* bannerImageUrl;
@property (copy) NSString* engagementUrl;
@property (assign) CGFloat revenue;
@property (assign) CGFloat currency;
@property (copy) NSString* markup;

+ (SVEngagement*)engagementWithProperties:(NSDictionary*)properties;

- (id)initWithProperties:(NSDictionary*)properties;

@end
