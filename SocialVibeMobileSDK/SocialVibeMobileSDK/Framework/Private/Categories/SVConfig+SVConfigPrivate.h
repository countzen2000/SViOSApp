//
//  SVConfig+SVConfigPrivate.h
//
//  Created on 2012-11-09.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

/*
    Private methods accessible only to other SDK classes.
 */

#import "SVConfig.h"

@interface SVConfig (SVConfigPrivate)

- (NSMutableDictionary*)configParameters;

- (BOOL)internetAvailable;

- (NSURL*)fetchEngagementsUrl;

- (BOOL)localNotificationsEnabled;

- (BOOL)passbookPassesEnabled;

- (void)setUserIdentifier:(NSString*)userId;

@end
