//
//  ApplicationProperties.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
// All singleton...one place

#import "ApplicationProperties.h"

@implementation ApplicationProperties
MainSelection mainSelection;
User* myUser;
static NSString *GATEWAY_USER = @"GW_ADMIN";
static NSString *GATEWAY_PASS = @"1qa2ws3ed";

+ (UIColor *)getOrange{
    return [UIColor colorWithRed:255/255.0 green:80.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+ (UIColor *)getBlack{
    return [UIColor colorWithRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1.0];
    
}

+ (UIColor *)getWhite{
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
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
    if (myUser == nil) {
        myUser = [[User alloc] init];
        myUser.kunnr = [[NSUserDefaults standardUserDefaults]
                                  stringForKey:@"KUNNR"];
        myUser.password = [[NSUserDefaults standardUserDefaults]
                              stringForKey:@"PASSWORD"];
        if ([myUser.kunnr isEqualToString:@""]) {
            [myUser setIsLoggedIn:NO];
        }else{
            [myUser setIsLoggedIn:YES];
        }
    }
    return myUser;
}
+ (void)setUser:(User*)aUser{
    myUser = aUser;
}

+ (NSString*)getSAPUser{
    return GATEWAY_USER;
}
+ (NSString*)getSAPPassword{
    return GATEWAY_PASS;
}

+ (int)getTimeout{
    return 15;
}

+ (NSString*)getAvailableCarURL{
    return @"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_ARAC_SRV/AvailCarService(ImppMsube='3064',ImppSehir='00',ImppHdfsube='3065',ImppLangu='T',ImppLand='T',ImppUname='XXXXX',ImppKdgrp='',ImppKunnr='',ImppEhdat=datetime'2010-01-12T00:00:00',ImppGbdat=datetime'1983-07-15T00:00:00',ImppFikod='',ImppWaers='TL',ImppBegda=datetime'2013-12-25T00:00:00',ImppEndda=datetime'2013-12-31T00:00:00',ImppBeguz='09:00:00',ImppEnduz='17:00:00')?$expand=ET_ARACLISTESet,ET_RESIMLERSet&$format=json";
}

+ (Office*)getOfficeFrom:(NSMutableArray*)offices withCode:(NSString*)officeCode{
    for (Office *tempOffice in offices) {
        if ([tempOffice.mainOfficeCode isEqualToString:officeCode]) {
            return tempOffice;
        }
    }
    return nil;
    
}
@end
