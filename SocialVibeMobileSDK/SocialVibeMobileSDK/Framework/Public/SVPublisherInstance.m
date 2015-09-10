//
//  SVPublisherInstance.m
//
//  Created on 2012-10-15.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVPublisherInstance.h"
#import "SVTrigger+SVTriggerPrivate.h"
#import "SVConfig+SVConfigPrivate.h"
#import "SVConstants.h"
#import <CommonCrypto/CommonHMAC.h>


@interface SVPublisherInstance ()
@property (copy) NSString* placementId;
@property (copy) NSString* secretKey;
@end


@implementation SVPublisherInstance

+ (SVPublisherInstance*)publisherInstanceWithPlacementIdentifier:(NSString*)placementId userIdentifier:(NSString*)userId secretKey:(NSString*)secretKey
{
    return [[SVPublisherInstance alloc] initWithPlacementIdentifier:placementId secretKey:secretKey userIdentifier:userId];
}

- (id)initWithPlacementIdentifier:(NSString*)placementId secretKey:(NSString*)secretKey userIdentifier:(NSString*)userId
{
    self = [super init];
    if (self)
    {
        if (placementId.length == 0 || userId.length == 0)
        {
            [NSException raise:@"SVPublisherInstance: missing parameters" format:@"SVPublisherInstance must have a placement ID and a user ID."];
        }
        
        _placementId = placementId;
        _secretKey = secretKey;
        
        [self setUserIdentifier:userId];
    }
    return self;
}

#pragma mark - Private Configuration Parameters

// pass the user ID up to the config singleton to add to the master parameter dictionary
- (void)setUserIdentifier:(NSString*)userId
{
    [[SVConfig sharedInstance] setUserIdentifier:userId];
}

// get the master parameter dictionary, and add this publisher instance's placement ID
- (NSMutableDictionary*)configParametersDictionary
{
    NSMutableDictionary* configParameters = [[SVConfig sharedInstance] configParameters];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    [parameters setValue:_placementId forKey:kFetchEngagementsPlacementIdentifier];
    [configParameters setValue:parameters forKey:kUserDeviceParametersPlacement];
    
    return [NSMutableDictionary dictionaryWithDictionary:configParameters];
}

#pragma mark - Trigger Creation

- (SVTrigger*)triggerForEngagementsOfWidth:(NSUInteger)width height:(NSUInteger)height maxResults:(NSUInteger)maxResults withDelegate:(id<SVTriggerDelegate>)delegate
{
    SVTrigger* trigger = [SVTrigger triggerForEngagementsOfWidth:width height:height maxResults:maxResults withDelegate:delegate];
    [trigger setFetchEngagementParameters:[self configParametersDictionary]];
    return trigger;
}

#pragma mark - Signature Validation

// if the hash of the payload is identical to the signature, then it is valid
- (BOOL)validateCreditPayload:(NSString*)payload withSignature:(NSString*)signature
{
    BOOL valid = NO;
    
    if (_secretKey)
    {
        // SHA 256 HMAC of payload using secret key
        const char* key  = [_secretKey cStringUsingEncoding:NSASCIIStringEncoding];
        const char* input = [payload cStringUsingEncoding:NSASCIIStringEncoding];
        unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
        
        CCHmac(kCCHmacAlgSHA256, key, strlen(key), input, strlen(input), cHMAC);
        
        NSData* output = [NSData dataWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];
        NSString* hashedPayload = [output description];
        hashedPayload = [hashedPayload stringByReplacingOccurrencesOfString:@" " withString:@""];
        hashedPayload = [hashedPayload stringByReplacingOccurrencesOfString:@"<" withString:@""];
        hashedPayload = [hashedPayload stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        valid = [hashedPayload isEqualToString:signature];
    }

    return valid;
}

@end
