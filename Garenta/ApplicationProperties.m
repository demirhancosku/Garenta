//
//  ApplicationProperties.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
// All singleton...one place

#import "ApplicationProperties.h"
#import "AdditionalEquipment.h"
#import "SDReservObject.h"
#import "MBProgressHUD.h"

@implementation ApplicationProperties
MainSelection mainSelection;
static User* myUser;

NSMutableArray *offices;

+ (NSString *)getAppName {
    return @"REZ";
}

+ (NSString *)getAppVersion {
    return @"1.0";
}

+ (UIColor *)getOrange{
    return [UIColor colorWithRed:255/255.0 green:80.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+ (UIColor *)getGreen{
    return [UIColor colorWithRed:121.0f/255.0 green:158.0/255.0 blue:42.0/255.0 alpha:1.0];
}

+ (UIColor *)getBlack{
    return [UIColor colorWithRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1.0];
    
}

+ (UIColor *)getWhite{
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (UIColor *) getGrey{
    return [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
}
+ (UIColor *)getDarkBlueColor{
    return [UIColor colorWithRed:52.0/255.0 green:109.0/255.0 blue:153.0/255.0 alpha:1.0];
}
+ (UIFont *)getFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:16.0];
}

//sample color codes
+ (UIColor*)getMenuTableBackgorund{
    return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
}

+ (UIColor*)getMenuCellBackground{
    //    return [UIColor colorWithRed:237.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:1.0];
    return [self getOrange];
}

+ (UIColor*)getMenuTextColor{
    return [UIColor colorWithRed:10.0/255.0 green:200.0/255.0 blue:247.0/255.0 alpha:1.0];
}


+ (MainSelection) getMainSelection{
    
    return mainSelection;
}
+ (void) setMainSelection:(MainSelection) aSelection{
    mainSelection = aSelection;
}

+ (User*)getUser{
    if (myUser == nil)
    {
        myUser = [[User alloc] init];
        
        myUser.kunnr    = [[NSUserDefaults standardUserDefaults] stringForKey:@"KUNNR"];
        myUser.password = [[NSUserDefaults standardUserDefaults] stringForKey:@"PASSWORD"];
        myUser.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERNAME"];
        
        if ([myUser.kunnr isEqualToString:@""] || myUser.kunnr == nil) {
            [myUser setIsLoggedIn:NO];
        }else{
            [myUser setIsLoggedIn:YES];
        }
    }
    
    return myUser;
}

+ (NSMutableArray*)getOffices {
    
    if (offices == nil) {
        offices = [NSMutableArray new];
    }

    return offices;
}

+ (void)setOffices:(NSMutableArray *)officeArray {
    offices = officeArray;
}

+ (void)setUser:(User*)aUser
{
    [[NSUserDefaults standardUserDefaults] setObject:aUser.kunnr forKey:@"KUNNR"];
    [[NSUserDefaults standardUserDefaults] setObject:aUser.password forKey:@"PASSWORD"];
    [[NSUserDefaults standardUserDefaults] setObject:aUser.username forKey:@"USERNAME"];
    
    myUser = aUser;
}

+ (BOOL)isActiveVersion{
    NSString *active = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"ACTIVEVERSION"];
    if([active isEqualToString:@"F"])
        return NO;
    
    return YES;
}

@end
