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
+ (UIColor *) getGreen;

+ (NSUInteger)getTimerObject;
+ (NSTimer *)getTimer;

+ (UIFont *) getFont;

//surec singleton tutulur
+ (MainSelection) getMainSelection;
+ (void) setMainSelection:(MainSelection)aMainSelection;
+ (User*)getUser;
+ (NSMutableArray*)getOffices;
+ (void)setTimerObject:(NSUInteger)timerObj;
+ (void)setTimer:(NSTimer *)aTimer;
+ (void)setUser:(User*)aUser;
+ (NSString *)getAppVersion;
+ (NSString *)getAppName;
+ (void)setOffices:(NSMutableArray *)officeArray;

//aktiflik
+ (BOOL)isActiveVersion;

@end
