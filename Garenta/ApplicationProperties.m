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
NSMutableArray *offices;
static NSString *GATEWAY_USER = @"GW_ADMIN";
static NSString *GATEWAY_PASS = @"1qa2ws3ed";

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

+ (NSMutableArray*)getOffices{
    if (offices == nil) {
        offices = [[NSMutableArray alloc] init];
    }
    return offices;
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

+ (NSString*)getAvailableCarURLWithCheckOutOffice:(Office*) checkOutOffice andCheckInOffice:(Office*) checkInOffice andCheckOutDay:(NSDate*)checkOutDay andCheckOutTime:(NSDate*)checkOutTime andCheckInDay:(NSDate*)checkInDay andCheckInTime:(NSDate*)checkInTime{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-ddThh:mm"];
    NSString *checkOutDayString = [format stringFromDate:checkOutDay];
    NSString *checkInDayString = [format stringFromDate:checkInDay];
    
    //aalpk iyi yollardan denedim olmadi simdi cakma zamani
    checkOutDayString = [NSString stringWithFormat:@"%@T00:00:00",checkOutDayString];
    checkInDayString = [NSString stringWithFormat:@"%@T00:00:00",checkInDayString];
    [format setDateFormat:@"HH:mm"];
    NSString *checkOutTimeString =[format stringFromDate:checkOutTime];
    NSString *checkInTimeString =[format stringFromDate:checkInTime];
    
    
    
    // user login olmus mu
    NSString* kunnr = [[ApplicationProperties getUser] kunnr];
    NSString*mSube = checkOutOffice.mainOfficeCode;
    NSString*sehir =@"";

    if (mSube == nil) {
        mSube = @"";
        sehir = checkOutOffice.cityCode;
    }
    
    //main office vr mı
    //aalpk : cikis main office bossa  bakıp onu yollayalım
    
        return [NSString stringWithFormat:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_ARAC_SRV/AvailCarService(ImppMsube='%@',ImppSehir='%@',ImppHdfsube='%@',ImppLangu='T',ImppLand='T',ImppUname='XXXXX',ImppKdgrp='',ImppKunnr='%@',ImppEhdat=datetime'2010-01-12T00:00:00',ImppGbdat=datetime'1983-07-15T00:00:00',ImppFikod='',ImppWaers='TL',ImppBegda=datetime'%@',ImppEndda=datetime'%@',ImppBeguz='%@',ImppEnduz='%@')?$expand=ET_ARACLISTESet,ET_RESIMLERSet&$format=json",mSube,sehir,checkInOffice.mainOfficeCode,kunnr,checkOutDayString,checkInDayString,checkOutTimeString,checkInTimeString];
    

}

+ (NSString*)getCreateReservationURLWithReservation:(Reservation*)aReservation{
    User *user = [ApplicationProperties getUser];
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"yyyy-MM-ddThh:mm"];
    [timeFormat setDateFormat:@"HH:mm"];

    NSString *muserino = @"";
    NSString *tckn = @"";
    NSString *tel = @"";
    NSString *lastname = @"";
    NSString *firstname = @"";
    NSString *email = @"";
    NSString *cinsiyet = @"";
    NSString *birthdate = @"1970-10-10";
    if (user.isLoggedIn) {
        muserino = user.kunnr;
    }else{
        tckn = user.tckno;
        tel = user.mobile;
        lastname = user.surname;
        firstname = user.name;
        email = user.email;
        cinsiyet = user.gender;
        birthdate = [dayFormat stringFromDate:user.birthday];
    }

    NSString *teslimSubesi = aReservation.checkInOffice.mainOfficeCode;
    NSString *rezEndtime = [timeFormat stringFromDate:aReservation.checkInTime];
    NSString *rezEndda= [ dayFormat stringFromDate:aReservation.checkInDay];
    NSString *rezBegtime = [timeFormat stringFromDate:aReservation.checkOutTime];
    NSString *rezBegda = [dayFormat stringFromDate:aReservation.checkOutDay];
    NSString *aracgrubu = aReservation.selectedCarGroup.groupCode;
    NSString *alisSubesi = aReservation.checkOutOffice.mainOfficeCode;
    NSString *toplamTutar = aReservation.selectedCarGroup.payLaterPrice;

    
     rezEndda = [NSString stringWithFormat:@"%@T00:00:00",rezEndda];
     rezBegda = [NSString stringWithFormat:@"%@T00:00:00",rezBegda];
    birthdate =[NSString stringWithFormat:@"%@T00:00:00",birthdate];
    
    return [NSString stringWithFormat:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_temprezervasyon_SRV/ReservationService(Tckn='%@',Uyruk='',TeslimSubesi='%@',Telno='%@',RezEndtime='%@',RezEndda=datetime'%@',RezBegtime='%@',RezBegda=datetime'%@',Musterino='%@',Matnr='',Lastname='%@',GarentaTl=0.0M,Firstname='%@',Email='%@',Cinsiyet='%@',Bonus=0.0M,Birthdate=datetime'%@',Aracgrubu='%@',AlisSubesi='%@',ToplamTutar=%@M)?$format=json",tckn,teslimSubesi,tel,rezEndtime,rezEndda,rezBegtime,rezBegda,muserino,lastname,firstname,email,cinsiyet,birthdate,aracgrubu,alisSubesi,toplamTutar];
    

}
+ (NSString*)getVersionUrl{
    return @"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_versiyon_SRV/VersiyonService(IAppName='rezapp',IVers='1.0')?$format=json";
}

+ (BOOL)isActiveVersion{
    NSString *active = [[NSUserDefaults standardUserDefaults]
     stringForKey:@"ACTIVEVERSION"];
    if([active isEqualToString:@"F"])
        return NO;
    
    return YES;
}
@end
