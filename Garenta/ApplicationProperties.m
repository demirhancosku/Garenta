//
//  ApplicationProperties.m
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
// All singleton...one place

#import "ApplicationProperties.h"
#import "ZGARENTA_OFIS_SRVRequestHandler.h"
#import "ZGARENTA_ARAC_SRVRequestHandler.h"
#import "ZGARENTA_EKHIZMET_SRVRequestHandler.h"
#import "ZGARENTA_versiyon_srvRequestHandler.h"
#import "ZGARENTA_REZERVASYON_SRVRequestHandler.h"
#import "ZGARENTA_LOGIN_SRV_01RequestHandler.h"
#import "ZGARENTA_GET_CUST_KK_SRVRequestHandler.h"
#import <objc/runtime.h>
@implementation ApplicationProperties
MainSelection mainSelection;
static User* myUser;

NSMutableArray *offices;
static NSString *GATEWAY_USER = @"GW_ADMIN";
static NSString *GATEWAY_PASS = @"1qa2ws3ed";
static NSString *appVersion = @"1.0";
static NSString *appName = @"REZ";

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

+ (NSMutableArray*)getOffices{
    if (offices == nil) {
        offices = [[NSMutableArray alloc] init];
    }
    return offices;
}

+ (void)setUser:(User*)aUser
{
    [[NSUserDefaults standardUserDefaults] setObject:aUser.kunnr forKey:@"KUNNR"];
    [[NSUserDefaults standardUserDefaults] setObject:aUser.password forKey:@"PASSWORD"];
    [[NSUserDefaults standardUserDefaults] setObject:aUser.username forKey:@"USERNAME"];
    
    myUser = aUser;
}

+ (NSString*)getSAPUser{
    return GATEWAY_USER;
}
+ (NSString*)getSAPPassword{
    return GATEWAY_PASS;
}

+ (int)getTimeout{
    return 60;
}

+ (NSString *)getAppVersion{
    return appVersion;
}

+ (NSString *)getAppName {
    return appName;
}

#pragma mark - URL Methods: will be deleted soon

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
    
    return [NSString stringWithFormat:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_ARAC_SRV/AvailCarServiceSet(ImppMsube='%@',ImppSehir='%@',ImppHdfsube='%@',ImppLangu='T',ImppLand='T',ImppUname='XXXXX',ImppKdgrp='',ImppKunnr='%@',ImppEhdat=datetime'2010-01-12T00:00:00',ImppGbdat=datetime'1983-07-15T00:00:00',ImppFikod='',ImppWaers='TL',ImppBegda=datetime'%@',ImppEndda=datetime'%@',ImppBeguz='%@',ImppEnduz='%@')?$expand=ET_ARACLISTESet,ET_FIYATSet&$format=json",mSube,sehir,checkInOffice.mainOfficeCode,kunnr,checkOutDayString,checkInDayString,checkOutTimeString,checkInTimeString];;
    
    
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
    NSString *rezEndda= [ dayFormat stringFromDate:aReservation.checkInTime];
    NSString *rezBegtime = [timeFormat stringFromDate:aReservation.checkOutTime];
    NSString *rezBegda = [dayFormat stringFromDate:aReservation.checkOutTime];
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

+ (NSString *)getLocations
{
    // ATA eğer ilerde maltıpıl lang. olayı gelirse buraya dokunuruz
    return @"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_LOCATION_SRV/LocationServiceSet(IvLangu='T')?$expand=ET_ILSet,ET_ILCESet,ET_ULKESet&$format=json";
}

+ (NSMutableArray*)closestFirst:(int)count fromOffices:(NSMutableArray*)someOffices toMyLocation:(CLLocation*)userLocation{
    __block NSMutableArray *closestOffices = [[NSMutableArray alloc] init];
    NSLog(@"%f",userLocation.coordinate.latitude);
    NSArray *sortedArray;
    sortedArray = [someOffices sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        CLLocation *firstOfficeLocation = [[CLLocation alloc] initWithLatitude:[[(Office*)a latitude] doubleValue] longitude:[[(Office*)a longitude] doubleValue]];
        CLLocation *secondOfficeLocation = [[CLLocation alloc] initWithLatitude:[[(Office*)b latitude] doubleValue] longitude:[[(Office*)b longitude] doubleValue]];
        
        double firstDistance = [userLocation distanceFromLocation:firstOfficeLocation];
        double secondDistance = [userLocation distanceFromLocation:secondOfficeLocation];
        if (firstDistance<secondDistance) {
            return (NSComparisonResult)NSOrderedAscending;
        }else if(secondDistance<firstDistance){
            return (NSComparisonResult)NSOrderedDescending;
        }else{
            return (NSComparisonResult)NSOrderedSame;
        }
        
    }];
    
    __block NSPredicate *officeCodePredicate; // to get rid of suboffices
    [sortedArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        officeCodePredicate = [NSPredicate predicateWithFormat:@"mainOfficeCode = %@",[(Office*)obj mainOfficeCode]];
        if ([closestOffices filteredArrayUsingPredicate:officeCodePredicate].count == 0) {
            [closestOffices addObject:obj];
        }
        if (closestOffices.count >= count) {
            *stop = YES;
        }
    }];
    return closestOffices;
}


#pragma mark - service configurations
+ (void)configureOfficeService{
    //Initialize the request handler with the service document URL and SAP client from the application settings.
    ZGARENTA_OFIS_SRVRequestHandler *requestHandler = [ZGARENTA_OFIS_SRVRequestHandler uniqueInstance];
    [requestHandler setServiceDocumentURL:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_OFIS_SRV"];
    [requestHandler setSAPClient:@""];
    
    /* Set to 'NO' to disable service negotiation */
    requestHandler.useServiceNegotiation = YES;
    
	/* Set to 'YES' to use local metadata for service proxy initialization */
    requestHandler.useLocalMetadata = NO;
    
    /* Set to 'YES' to use JSON in HTTP requests */
    requestHandler.useJSON = NO;
}

+ (void)configureCarService{
    //Initialize the request handler with the service document URL and SAP client from the application settings.
    ZGARENTA_ARAC_SRVRequestHandler *requestHandler = [ZGARENTA_ARAC_SRVRequestHandler uniqueInstance];
    [requestHandler setServiceDocumentURL:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_ARAC_SRV"];
    [requestHandler setSAPClient:@""];
    
    /* Set to 'NO' to disable service negotiation */
    requestHandler.useServiceNegotiation = YES;
    
	/* Set to 'YES' to use local metadata for service proxy initialization */
    requestHandler.useLocalMetadata = NO;
    
    /* Set to 'YES' to use JSON in HTTP requests */
    requestHandler.useJSON = NO;
}

+ (void)configureAdditionalEquipmentService{
    //Initialize the request handler with the service document URL and SAP client from the application settings.
    ZGARENTA_EKHIZMET_SRVRequestHandler *requestHandler = [ZGARENTA_EKHIZMET_SRVRequestHandler uniqueInstance];
    [requestHandler setServiceDocumentURL:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_EKHIZMET_SRV"];
    [requestHandler setSAPClient:@""];
    
    /* Set to 'NO' to disable service negotiation */
    requestHandler.useServiceNegotiation = YES;
    
	/* Set to 'YES' to use local metadata for service proxy initialization */
    requestHandler.useLocalMetadata = NO;
    
    /* Set to 'YES' to use JSON in HTTP requests */
    requestHandler.useJSON = NO;
}
+ (void)configureVersionService{
    ZGARENTA_versiyon_srvRequestHandler *requestHandler = [ZGARENTA_versiyon_srvRequestHandler uniqueInstance];
    [requestHandler setServiceDocumentURL:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_VERSIYON_SRV"];
    [requestHandler setSAPClient:@""];
    
    /* Set to 'NO' to disable service negotiation */
    requestHandler.useServiceNegotiation = YES;
    
	/* Set to 'YES' to use local metadata for service proxy initialization */
    requestHandler.useLocalMetadata = NO;
    
    /* Set to 'YES' to use JSON in HTTP requests */
    requestHandler.useJSON = NO;
}

+ (void)configureReservationService{
    ZGARENTA_REZERVASYON_SRVRequestHandler *requestHandler = [ZGARENTA_REZERVASYON_SRVRequestHandler uniqueInstance];
    [requestHandler setServiceDocumentURL:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_REZERVASYON_SRV"];
    [requestHandler setSAPClient:@""];
    
    /* Set to 'NO' to disable service negotiation */
    requestHandler.useServiceNegotiation = YES;
    
	/* Set to 'YES' to use local metadata for service proxy initialization */
    requestHandler.useLocalMetadata = NO;
    
    /* Set to 'YES' to use JSON in HTTP requests */
    requestHandler.useJSON = NO;
}

+ (void)configureLoginService{
    ZGARENTA_LOGIN_SRV_01RequestHandler *requestHandler = [ZGARENTA_LOGIN_SRV_01RequestHandler uniqueInstance];
    [requestHandler setServiceDocumentURL:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_LOGIN_SRV_01"];
    [requestHandler setSAPClient:@""];
    
    /* Set to 'NO' to disable service negotiation */
    requestHandler.useServiceNegotiation = YES;
    
	/* Set to 'YES' to use local metadata for service proxy initialization */
    requestHandler.useLocalMetadata = NO;
    
    /* Set to 'YES' to use JSON in HTTP requests */
    requestHandler.useJSON = NO;
}
+ (void)configureCreditCardService{
    ZGARENTA_GET_CUST_KK_SRVRequestHandler *requestHandler = [ZGARENTA_GET_CUST_KK_SRVRequestHandler uniqueInstance];
    [requestHandler setServiceDocumentURL:@"https://garentarezapp.celikmotor.com.tr:8000/sap/opu/odata/sap/ZGARENTA_GET_CUST_KK_SRV"];
    [requestHandler setSAPClient:@""];
    
    /* Set to 'NO' to disable service negotiation */
    requestHandler.useServiceNegotiation = YES;
    
	/* Set to 'YES' to use local metadata for service proxy initialization */
    requestHandler.useLocalMetadata = NO;
    
    /* Set to 'YES' to use JSON in HTTP requests */
    requestHandler.useJSON = NO;
}
+ (void)fillProperties:(id)object{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    for (NSUInteger i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        if ([ApplicationProperties isNSString:property]) {
            [object setValue:@" " forKey:key];
        }
    }
    
    free(properties);
    
}
+ (BOOL) isNSString:(objc_property_t)prop{
    
    const char * propAttr = property_getAttributes(prop);
    NSString *propString = [NSString stringWithUTF8String:propAttr];
    
    NSRange isRange = [propString rangeOfString:@"NSString" options:NSCaseInsensitiveSearch];
    if(isRange.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)checkYoungDriverAddition:(CarGroup *)selectedCarGroup andBirthday:(NSDate *)birthday andLicenseDate:(NSDate *)licenseDate
{
    if (birthday == nil || licenseDate == nil) {
        return NO;
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *customerBirthdayYear = [[formatter stringFromDate:birthday] substringToIndex:4];
    NSString *customerLicenseYear = [[formatter stringFromDate:licenseDate] substringToIndex:4];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentYear = [components year];
    
    NSInteger age = currentYear - customerBirthdayYear.integerValue;
    NSInteger licenceYear = currentYear - customerLicenseYear.integerValue;
    
    if (selectedCarGroup.minAge > age)
        return YES;
    else if (selectedCarGroup.minDriverLicense > licenceYear)
        return YES;
    
    return NO;
}

+ (BOOL)isCarGroupAvailableByAge:(CarGroup *)activeCarGroup andBirthday:(NSDate *)birthday
{
    if (birthday == nil) {
        return NO;
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *customerBirthdayYear = [[formatter stringFromDate:birthday] substringToIndex:4];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentYear = [components year];
    
    NSInteger age = currentYear - customerBirthdayYear.integerValue;
    
    if (activeCarGroup.minYoungDriverAge > age)
        return YES;
    else if (activeCarGroup.minYoungDriverLicense > age)
        return YES;
    
    return NO;
}



+ (void)loginToSap:(NSString *)username andPassword:(NSString *)password
{
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZMOB_REZ_LOGIN"];
        
        [handler addImportParameter:@"IV_PASSWORD" andValue:password];
        [handler addImportParameter:@"IV_FREETEXT" andValue:username];
        [handler addImportParameter:@"IV_LANGU" andValue:@"T"];
        
        [handler addTableForReturn:@"ET_RETURN"];
        [handler addTableForReturn:@"ET_PARTNERS"];
        [handler addTableForReturn:@"ET_CARDTYPES"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *sysubrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([sysubrc isEqualToString:@"0"]) {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *allPartners = [tables objectForKey:@"ZMOB_LOGIN_ALL_PARTNERS"];
                
                if (allPartners.count > 0)
                {
                    for (NSDictionary *tempDict in allPartners) {
                        User *user = [User new];
                        
                        NSDateFormatter *formatter = [NSDateFormatter new];
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                        
                        [user setName:[tempDict valueForKey:@"MC_NAME2"]];
                        [user setMiddleName:[tempDict valueForKey:@"NAMEMIDDLE"]];
                        [user setSurname:[tempDict valueForKey:@"MC_NAME1"]];
                        [user setKunnr:[tempDict valueForKey:@"PARTNER"]];
                        [user setUsername:username];
                        [user setPassword:password];
                        [user setPartnerType:[tempDict valueForKey:@"MUSTERI_TIPI"]];
                        [user setCompany:[tempDict valueForKey:@"FIRMA_KODU"]];
                        [user setCompanyName:[tempDict valueForKey:@"FIRMA_NAME1"]];
                        [user setCompanyName2:[tempDict valueForKey:@"FIRMA_NAME2"]];
                        [user setMobileCountry:[tempDict valueForKey:@"MOBILE_ULKE"]];
                        [user setMobile:[tempDict valueForKey:@"MOBILE"]];
                        [user setEmail:[tempDict valueForKey:@"EMAIL"]];
                        [user setTckno:[tempDict valueForKey:@"TCKNO"]];
                        [user setGarentaTl:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"GARENTATL"]]];
                        [user setPriceCode:[tempDict valueForKey:@"FIYAT_KODU"]];
                        [user setPriceType:[tempDict valueForKey:@"FIYAT_TIPI"]];
                        [user setBirthday:[formatter dateFromString:[tempDict valueForKey:@"BIRTHDAY"]]];
                        [user setDriversLicenseDate:[formatter dateFromString:[tempDict valueForKey:@"EHLIYET_TARIHI"]]];
                        
                        if ([[tempDict valueForKey:@"C_PRIORITY"] isEqualToString:@"X"]) {
                            [user setIsPriority:YES];
                        }
                        
                        if ([[user partnerType] isEqualToString:@"B"]) {
                            [user setIsLoggedIn:YES];
                            [ApplicationProperties setUser:user];
                        }
                        else {
                            // Şu an sadece bireysel kullanıcıları alıyoruz
                        }
                    }
                }
                else {
                    alertString = @"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz.";
                }
            }
            else {
                alertString = @"Kullanıcı adı ve şifrenizi kontrol ederek lütfen tekrar deneyiniz.";
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        if (![alertString isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            });
        }
    }
}

@end
