//
//  SVConfig.m
//
//  Created on 2012-11-09.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import "SVConfig.h"
#import "SVConstants.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonDigest.h>
#import <netinet/in.h>
#import <sys/utsname.h>


@interface SVConfig ()
@property (copy) NSMutableDictionary* configParameters;
@property (assign) BOOL usingTestServer;
@property (assign) BOOL notificationsEnabled;
@property (assign) BOOL passbookEnabled;
@end


@implementation SVConfig

+ (SVConfig*)sharedInstance
{
    static SVConfig* sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SVConfig hiddenAlloc] init];
    });
    
    return sharedInstance;
}

// used to prevent non-singleton creation of the config object
+ (id)hiddenAlloc
{
    return [super alloc];
}

+ (id)alloc
{
    NSAssert(FALSE, @"Must access SVConfig via sharedInstance method.");
    return nil;
}

- (id)init
{
    if ((self = [super init]))
    {
        // master dictionary to contain parameters for fetching engagements
        
        NSArray* sectionKeys = [NSArray arrayWithObjects:
                                kUserDeviceParametersPlacement,
                                kUserDeviceParametersApp,
                                kUserDeviceParametersAdSpace,
                                kUserDeviceParametersDevice,
                                kUserDeviceParametersUser,
                                kUserDeviceParametersAd,
                                kUserDeviceParametersResponse,
                                nil];
        
        NSArray* sections = [NSArray arrayWithObjects:
                             [NSNull null],
                             [NSNull null],
                             [NSNull null],
                             [NSNull null],
                             [NSNull null],
                             [NSNull null],
                             [NSNull null],
                             nil];
        
        _configParameters = [NSMutableDictionary dictionaryWithObjects:sections forKeys:sectionKeys];
        
        
        // these values never change
        [self setMraidEnabled:@"1" adRepresentation:@"markup"];
        [self setDeviceInfo];
    }
    return self;
}

#pragma mark - Private State Accessors

- (BOOL)internetAvailable
{
	struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
    
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityGetFlags(target, &flags);
    
	BOOL isReachable = flags & kSCNetworkFlagsReachable;

	CFRelease(target);
    
	return isReachable;
}

- (NSURL*)fetchEngagementsUrl
{
    // QA and production server URL's
    NSString* urlString = _usingTestServer ? @"http://qa-ads.socialvi.be/v1" : @"http://ads.socialvi.be/v1";
    NSURL* url = [NSURL URLWithString:urlString];
    return url;
}

- (BOOL)localNotificationsEnabled
{
    return _notificationsEnabled;
}

- (BOOL)passbookPassesEnabled
{
    return _passbookEnabled;
}

#pragma mark - Private Device Info Accessors

- (NSString*)getCountry
{
    NSString* countryName = nil;
    
    // if CoreTelephony is available, obtain the ISO Alpha-2 country code
    Class telephonyClass = NSClassFromString(@"CTTelephonyNetworkInfo");
    if (telephonyClass)
    {
        CTTelephonyNetworkInfo* telephonyInfo = [[telephonyClass alloc] init];
        
        Class carrierClass = NSClassFromString(@"CTCarrier");
        if (carrierClass)
        {
            CTCarrier* carrier = [telephonyInfo subscriberCellularProvider];
            countryName = [[carrier isoCountryCode] uppercaseString];
        }
    }
    
    return countryName;
}

- (NSString*)getCarrier
{
    NSString* carrierName = nil;
    
    // if CoreTelephony is available, obtain the carrier's name
    Class telephonyClass = NSClassFromString(@"CTTelephonyNetworkInfo");
    if (telephonyClass)
    {
        CTTelephonyNetworkInfo* telephonyInfo = [[telephonyClass alloc] init];
        
        Class carrierClass = NSClassFromString(@"CTCarrier");
        if (carrierClass)
        {
            CTCarrier* carrier = [telephonyInfo subscriberCellularProvider];
            carrierName = [carrier carrierName];
        }
    }
    
    return carrierName;
}

- (NSString*)getUserAgent
{
    // throw-away web view to obtain device user agent
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    return userAgent;
}

- (NSString*)getDeviceModel
{
    // from sys/utsname
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString* model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return model;
}

- (NSString*)getOperatingSystem
{
    NSString* systemName = [[UIDevice currentDevice] systemName];
    return systemName;
}

- (NSString*)getSystemVersion
{
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    return systemVersion;
}

- (NSString*)getManufacturer
{
    return @"Apple";
}

- (NSString*)getCoordinatesFromLocation:(CLLocation*)location
{
    NSString* coordinates = nil;

    // if CoreLocation is available, obtain the long and lat in string form
    Class coordinateClass = NSClassFromString(@"CLLocation");
    if (coordinateClass)
    {
        CLLocationCoordinate2D coordinate = [location coordinate];
        coordinates = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];    
    }
    
    return coordinates;
}

#pragma mark - Private Configuration

// set by the Publisher Instance
- (void)setUserIdentifier:(NSString*)userId
{
    NSMutableDictionary* parameters = [_configParameters valueForKey:kUserDeviceParametersUser];
    if ([parameters isKindOfClass:[NSNull class]])
    {
        parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    [parameters setValue:userId forKey:kFetchEngagementsUserIdentifier];
    
    [_configParameters setValue:parameters forKey:kUserDeviceParametersUser];
}

// set in init
- (void)setMraidEnabled:(NSString*)mraidEnabled adRepresentation:(NSString*)representation
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setValue:mraidEnabled forKey:kFetchEngagementsAdMraidEnabled];
    [parameters setValue:representation forKey:kFetchEngagementsAdRepresentation];
    
    [_configParameters setValue:[NSDictionary dictionaryWithDictionary:parameters] forKey:kUserDeviceParametersAd];
}

- (void)setDeviceCountry:(NSString*)country carrier:(NSString*)carrier userAgent:(NSString*)userAgent manufacturer:(NSString*)manufacturer model:(NSString*)model operatingSystem:(NSString*)operatingSystem systemVersion:(NSString*)systemVersion
{
    // grab the dictionary that was previous constructed (if it exists)
    NSMutableDictionary* parameters = [_configParameters valueForKey:kUserDeviceParametersDevice];
    if ([parameters isKindOfClass:[NSNull class]])
    {
        // if device parameters haven't yet been set, create a new dictionary
        parameters = [NSMutableDictionary dictionaryWithCapacity:7];
    }
    
    [parameters setValue:country forKey:kFetchEngagementsDeviceCountry];
    [parameters setValue:carrier forKey:kFetchEngagementsDeviceCarrier];
    [parameters setValue:userAgent forKey:kFetchEngagementsDeviceUserAgent];
    [parameters setValue:manufacturer forKey:kFetchEngagementsDeviceManufacturer];
    [parameters setValue:model forKey:kFetchEngagementsDeviceModel];
    [parameters setValue:operatingSystem forKey:kFetchEngagementsDeviceOS];
    [parameters setValue:systemVersion forKey:kFetchEngagementsDeviceOSVersion];
    
    
    [_configParameters setValue:parameters forKey:kUserDeviceParametersDevice];
}

- (void)setDeviceInfo
{
    // get info from device
    NSString* country = [self getCountry];
    NSString* carrier = [self getCarrier];
    NSString* userAgent = [self getUserAgent];
    NSString* manufacturer = [self getManufacturer];
    NSString* model = [self getDeviceModel];
    NSString* os = [self getOperatingSystem];
    NSString* osVersion = [self getSystemVersion];
    
    [self setDeviceCountry:country carrier:carrier userAgent:userAgent manufacturer:manufacturer model:model operatingSystem:os systemVersion:osVersion];
}

- (NSString*)commaSeparatedStringFromArray:(NSArray*)array
{
    NSString* list = nil;
    
    // add each string in the array to the list
    for (id item in array)
    {
        if ([item isKindOfClass:[NSString class]])
        {
            list = [list stringByAppendingFormat:@", %@", item];
        }
    }
    // remove the leading comma and space
    if (list.length > 0)
    {
        list = [list substringFromIndex:2];
    }
    
    return list;
}

#pragma mark - Public Configuration

- (void)useTestServer:(BOOL)test
{
    _usingTestServer = test;
}

- (void)enableLocalNotifications:(BOOL)enable
{
    _notificationsEnabled = enable;
}

- (void)enablePassbookPasses:(BOOL)enable
{
    _passbookEnabled = enable;
    
    if (enable)
    {
        // check that the PassKit framework is accessible
        Class passClass = NSClassFromString(@"PKPass");
        if (!passClass)
        {
            [NSException raise:@"SVConfig: missing framework" format:@"PassKit framework must be included to enable Passbook passes:."];
        }
    }
}

// optional app parameters
- (void)setAppName:(NSString*)name keywords:(NSArray*)keywords version:(NSString*)version
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    [parameters setValue:name forKey:kFetchEngagementsAppName];
    [parameters setValue:version forKey:kFetchEngagementsAppVersion];
    
    NSString* keywordString = [self commaSeparatedStringFromArray:keywords];
    [parameters setValue:keywordString forKey:kFetchEngagementsAppKeywords];
    
    
    [_configParameters setValue:[NSDictionary dictionaryWithDictionary:parameters] forKey:kUserDeviceParametersApp];
}

// optional geo-location
- (void)setCurrentLocation:(CLLocation*)location
{
    // grab the dictionary that was previous constructed (if it exists)
    NSMutableDictionary* parameters = [_configParameters valueForKey:kUserDeviceParametersDevice];
    if ([parameters isKindOfClass:[NSNull class]])
    {
        // if geo location hasn't yet been set, create a new dictionary
        parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    NSString* geoLoc = [self getCoordinatesFromLocation:location];
    [parameters setValue:geoLoc forKey:kFetchEngagementsDeviceGeoLocation];
    
    
    [_configParameters setValue:parameters forKey:kUserDeviceParametersDevice];
}

// optional device identifier
- (void)setDeviceId:(NSString*)deviceId
{
    // grab the dictionary that was previous constructed (if it exists)
    NSMutableDictionary* parameters = [_configParameters valueForKey:kUserDeviceParametersDevice];
    if ([parameters isKindOfClass:[NSNull class]])
    {
        // if device parameters haven't yet been set, create a new dictionary
        parameters = [NSMutableDictionary dictionaryWithCapacity:8];
    }
    
    
    // hash the device ID
    NSData* input = [deviceId dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* output = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(input.bytes, input.length, output.mutableBytes);
    
    NSString* hashedId = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    
    
    [parameters setValue:hashedId forKey:kFetchEngagementsDevicePlatformId];
    
    
    [_configParameters setValue:parameters forKey:kUserDeviceParametersDevice];
}

// optional user parameters
- (void)setUserAge:(NSNumber*)age gender:(NSString*)gender zip:(NSString*)zip country:(NSString*)country keywords:(NSArray*)keywords additionalAttributes:(NSDictionary*)additional
{
    // grab the dictionary that was constructed when User Identifier was passed in
    NSMutableDictionary* parameters = [_configParameters valueForKey:kUserDeviceParametersUser];
    if ([parameters isKindOfClass:[NSNull class]])
    {
        // if user ID hasn't yet been set, create a new dictionary
        parameters = [NSMutableDictionary dictionaryWithCapacity:8];
    }
    
    [parameters setValue:zip forKey:kFetchEngagementsUserZip];
    [parameters setValue:country forKey:kFetchEngagementsUserCountry];
    
    
    // if an age is supplied, calculate the year of birth and supply both values
    if (age != nil)
    {
        NSDate* currentDate = [NSDate date];
        NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit fromDate:currentDate];
        NSInteger currentYear = [components year];
        
        NSInteger yearOfBirth = currentYear - [age integerValue];
        NSNumber* birthYear = [NSNumber numberWithInteger:yearOfBirth];
        
        [parameters setValue:birthYear forKey:kFetchEngagementsUserYearOfBirth];
        [parameters setValue:age forKey:kFetchEngagementsUserAge];
    }
    
    
    // if supplied gender string begins with an M or an F, send along the representing character
    if (gender.length > 0)
    {
        NSString* genderCharacter = [[gender substringToIndex:1] lowercaseString];
        
        if ([genderCharacter isEqualToString:@"m"] || [genderCharacter isEqualToString:@"f"])
        {
            [parameters setValue:genderCharacter forKey:kFetchEngagementsUserGender];
        }
    }
    
    
    // convert the array of optional keywords into a comma separated list
    NSString* keywordString = [self commaSeparatedStringFromArray:keywords];
    [parameters setValue:keywordString forKey:kFetchEngagementsUserInterests];
    
    
    // convert the dictionary of additional attributes into a JSON string;
    // if there is an error in conversion the output will be nil, and thus ignored
    if (additional != nil)
    {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:additional options:0 error:NULL];
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [parameters setValue:jsonString forKey:kFetchEngagementsUserExtraAttributes];
    }
    
    
    [_configParameters setValue:parameters forKey:kUserDeviceParametersUser];
}

@end
