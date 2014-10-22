//
//  ApplicationProperties.h
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Office.h"
#import "Reservation.h"
#import "CarGroupTableVC.h"
#import <CoreLocation/CoreLocation.h>

@interface ApplicationProperties : NSObject
typedef enum{
    classic_search,
    location_search,
    advanced_search
}MainSelection;

+ (UIColor *) getOrange;
+ (UIColor *) getBlack;
+ (UIColor *) getWhite;
+ (UIColor *) getMenuTableBackgorund;
+ (UIColor *) getMenuCellBackground;
+ (UIColor *) getMenuTextColor;
+ (UIColor *) getGrey;
+ (UIColor *)getGreen;


+ (UIFont *) getFont;

//surec singleton tutulur
+ (MainSelection) getMainSelection;
+ (void) setMainSelection:(MainSelection)aMainSelection;
+ (User*)getUser;
+ (NSMutableArray*)getOffices;
+ (void)setUser:(User*)aUser;
+ (NSString*)getSAPUser;
+ (NSString*)getSAPPassword;
+ (int)getTimeout;
+ (NSString *)getAppVersion;
+ (NSString *)getAppName;

//aktiflik
+ (BOOL)isActiveVersion;

+ (void)loginToSap:(NSString *)username andPassword:(NSString *)password;

@end
