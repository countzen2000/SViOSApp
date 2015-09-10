//
//  SVEngagement.m
//
//  Created on 2012-10-15.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVEngagement.h"
#import "SVEngagement+SVEngagementPrivate.h"
#import "SVConstants.h"


@implementation SVEngagement

+ (SVEngagement*)engagementWithProperties:(NSDictionary*)properties
{
    return [[SVEngagement alloc] initWithProperties:properties];
}

- (id)initWithProperties:(NSDictionary*)properties
{
    self = [super init];
    if (self)
    {
        _width = [[properties objectForKey:kEngagementsResponseWidth] unsignedIntegerValue];
        _height = [[properties objectForKey:kEngagementsResponseHeight] unsignedIntegerValue];
        _name = [properties objectForKey:kEngagementsResponseName];
        _displayText = [properties objectForKey:kEngagementsResponseDisplayText];
        _baseUrl = [properties objectForKey:kEngagementsResponseBaseUrl];
        _engagementId = [properties objectForKey:kEngagementsResponseId];
        _bannerImageUrl = [properties objectForKey:kEngagementsResponseImageUrl];
        _engagementUrl = [properties objectForKey:kEngagementsResponseUrl];
        _revenue = [[properties objectForKey:kEngagementsResponseRevenueAmount] floatValue];
        _currency = [[properties objectForKey:kEngagementsResponseCurrencyAmount] floatValue];
        _markup = [properties objectForKey:kEngagementsResponseMarkup];
    }
    return self;
}

@end
