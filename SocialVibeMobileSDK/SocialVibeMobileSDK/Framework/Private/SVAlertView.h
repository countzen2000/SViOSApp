//
//  SVAlertView.h
//
//  Created on 2012-11-08.
//  Copyright (c) 2012 SocialVibe. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
    AlertView subclass to hold additional information for scheduling local notifications.
 */

@interface SVAlertView : UIAlertView
@property (copy) NSString* fireDate;
@property (copy) NSString* notificationText;
@property (copy) NSString* followUpUrl;
@end
