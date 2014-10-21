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

+ (BOOL)isActiveVersion{
    NSString *active = [[NSUserDefaults standardUserDefaults]
                        stringForKey:@"ACTIVEVERSION"];
    if([active isEqualToString:@"F"])
        return NO;
    
    return YES;
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

+ (NSString *)createReservationAtSAP:(Reservation *)_reservation andIsPayNow:(BOOL)isPayNow {
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_CREATE_REZERVASYON"];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDateFormatter *timeFormatter = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm"];
        
        // IS_INPUT
        
        NSArray *isInputColumns = @[@"REZ_NO", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"ODEME_TURU", @"GARENTA_TL", @"BONUS", @"MILES_SMILES", @"GUN_SAYISI", @"TOPLAM_TUTAR", @"C_PRIORITY", @"C_CORP_PRIORITY", @"REZ_KANAL", @"FT_CIKIS_IL", @"FT_CIKIS_ILCE", @"FT_CIKIS_ADRES", @"FT_DONUS_IL", @"FT_DONUS_ILCE", @"FT_DONUS_ADRES", @"PARA_BIRIMI", @"FT_MALIYET_TIPI", @"USERNAME", @"PUAN_TIPI", @"UCUS_SAATI", @"UCUS_NO", @"ODEME_BICIMI", @"FATURA_ACIKLAMA", @"EMAIL_CONFIRM", @"TELNO_CONFIRM"];
        
        NSString *isPriority = @"";
        
        if ([[ApplicationProperties getUser] isPriority]) {
            isPriority = @"X";
        }
        
        NSString *paymentType = @"";
        
        if (isPayNow) {
            paymentType = @"1";
        }
        else {
            paymentType = @"2";
        }
        
        NSString *totalPrice = [[_reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:nil] stringValue];
        
        // satış burosunu onurla konuşcam
        NSArray *isInputValues = @[@"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode,  paymentType, @"", @"", @"", [_reservation.selectedCarGroup.sampleCar.pricing.dayCount stringValue], totalPrice, isPriority, @"", @"40", @"", @"", @"", @"", @"", @"", @"TRY", @"", @"", @"", @"", @"", @"", @"", @"", @""];
        [handler addImportStructure:@"IS_INPUT" andColumns:isInputColumns andValues:isInputValues];
        
        // IS_USERINFO
        
        NSArray *isUserInfoColumns;
        NSArray *isUserInfoValues;
        
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            isUserInfoColumns = @[@"MUSTERINO"];
            isUserInfoValues = @[[[ApplicationProperties getUser] kunnr]];
        }
        else {
            
            isUserInfoColumns = @[@"MUSTERINO", @"CINSIYET", @"FIRSTNAME", @"LASTNAME", @"BIRTHDATE", @"TCKN", @"VERGINO", @"ADRESS", @"EMAIL", @"TELNO", @"UYRUK", @"ULKE", @"SALES_ORGANIZATION", @"DISTRIBUTION_CHANNEL", @"DIVISION", @"KANALTURU", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"EHLIYET_NO", @"EHLIYET_TARIHI", @"ILKODU", @"ILCEKOD", @"MIDDLENAME", @"PASAPORTNO", @"TK_KARTNO", @"TELNO_ULKE"];
            isUserInfoValues = @[@""];
            
            return @"";// Şimdilik
        }
        
        [handler addImportStructure:@"IS_USERINFO" andColumns:isUserInfoColumns andValues:isUserInfoValues];
        
        // IT_ARACLAR
        NSArray *itAraclarColumns = @[@"MATNR"];
        NSMutableArray *itAraclarValues = [NSMutableArray new];
        
        for (Car *tempCar in _reservation.selectedCarGroup.cars) {
            NSArray *arr = @[[tempCar materialCode]];
            [itAraclarValues addObject:arr];
        }
        
        [handler addTableForImport:@"IT_ARACLAR" andColumns:itAraclarColumns andValues:itAraclarValues];
        
        // IT_ITEMS
        NSArray *itItemsColumns = @[@"REZ_KALEM_NO", @"MALZEME_NO", @"MIKTAR", @"ARAC_GRUBU", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"KAMPANYA_ID", @"FIYAT", @"C_KISLASTIK", @"ARAC_RENK", @"SASI_NO", @"PLAKA_NO", @"JATO_MARKA", @"JATO_MODEL", @"FILO_SEGMENT", @"FIYAT_KODU", @"UPDATE_STATU", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"KALEM_TIPI", @"PARA_BIRIMI", @"IS_AYLIK", @"KURUM_BIREYSEL"];
        
        NSMutableArray *itItemsValues = [NSMutableArray new];
        
        NSString *matnr = @"";
        NSString *jatoBrandID = @"";
        NSString *jatoModelID = @"";
        
        if (_reservation.selectedCar != nil) {
            matnr = _reservation.selectedCar.materialCode;
            jatoBrandID = _reservation.selectedCar.brandId;
            jatoModelID = _reservation.selectedCar.modelId;
        }
        
        // ARAÇ
        
        NSArray *vehicleLine = @[@"", matnr, @"1", _reservation.selectedCarGroup.groupCode, _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", _reservation.selectedCarGroup.payLaterPrice, @"", @"", @"", @"", jatoBrandID, jatoModelID, _reservation.selectedCarGroup.segment, @"", @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
        
        [itItemsValues addObject:vehicleLine];
        
        // Ekipmanlar, Hizmetler
        
        for (AdditionalEquipment *tempEquipment in _reservation.additionalEquipments) {
            for (int count = 0; count < tempEquipment.quantity; count++) {
                NSArray *equipmentLine = @[@"", tempEquipment.materialNumber, @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", [tempEquipment.price stringValue], @"", @"", @"", @"", @"", @"", @"", @"", @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
                
                [itItemsValues addObject:equipmentLine];
            }
        }
        
        // Aracını seçtiyse
        if (_reservation.selectedCar != nil) {
            
            NSArray *carSelectionLine = @[@"", @"HZM0031", @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", [_reservation.selectedCar.pricing.carSelectPrice stringValue], @"", @"", @"", @"", @"", @"", @"", @"", @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
            [itItemsValues addObject:carSelectionLine];
        }
        
        [handler addTableForImport:@"IT_ITEMS" andColumns:itItemsColumns andValues:itItemsValues];
        
        // IT_EKSURUCU
        NSArray *itEkSurucuColumns = @[@"CINSIYET", @"FIRSTNAME", @"LASTNAME", @"BIRTHDATE", @"TCKN", @"TELNO", @"UYRUK", @"ULKE", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"EHLIYET_NO", @"EHLIYET_TARIHI", @"EKSURUCU_NO", @"UPDATE_STATU", @"KALEM_NO"];
        
        NSMutableArray *itEkSurucuValues = [NSMutableArray new];
        
        for (AdditionalEquipment *temp in _reservation.additionalDrivers) {
            NSArray *additionalDriverLine = @[temp.additionalDriverGender, temp.additionalDriverFirstname, temp.additionalDriverSurname, [dateFormatter stringFromDate:temp.additionalDriverBirthday], @"", @"", @"", @"", temp.additionalDriverLicensePlace, temp.additionalDriverLicenseClass, temp.additionalDriverLicenseNumber, [dateFormatter stringFromDate:temp.additionalDriverLicenseDate], @"", @"", @""];
            [itEkSurucuValues addObject:additionalDriverLine];
        }
        
        if ([itEkSurucuValues count] > 0) {
            [handler addTableForImport:@"IT_EKSURUCU" andColumns:itEkSurucuColumns andValues:itEkSurucuValues];
        }
        
        // IT_SD Reserv
        
        NSArray *itSDReservColumns = @[@"SUBE", @"GRUP_KODU", @"FIYAT_KODU", @"TARIH", @"R_VBELN", @"R_POSNR", @"R_GJAHR", @"R_AUART", @"MATNR", @"KUNNR", @"HDFSUBE", @"AUGRU", @"VKORG", @"VTWEG", @"SPART", @"TUTAR", @"GRNTTL_KAZANIR", @"MIL_KAZANIR", @"BONUS_KAZANIR"];
        
        NSMutableArray *itSDReservValues = [NSMutableArray new];
        
        for (SDReservObject *tempObject in _reservation.etReserv) {
            if ([tempObject.office isEqualToString:_reservation.checkOutOffice.subOfficeCode] && [tempObject.groupCode isEqualToString:_reservation.selectedCarGroup.groupCode]) {
                NSArray *arr = @[tempObject.office, tempObject.groupCode, tempObject.priceCode, tempObject.date, tempObject.rVbeln, tempObject.rPosnr, tempObject.RGjahr, tempObject.rAuart, tempObject.matnr, tempObject.kunnr, tempObject.destinationOffice, tempObject.augru, tempObject.vkorg, tempObject.vtweg, tempObject.spart, tempObject.price, tempObject.isGarentaTl, tempObject.isMiles, tempObject.isBonus];
                [itSDReservValues addObject:arr];
            }
        }
        
        [handler addTableForImport:@"IT_SDREZERV" andColumns:itSDReservColumns andValues:itSDReservValues];
        
        if (isPayNow) {
            // IT_TAHSILAT
            
            NSArray *itTahsilatColumns = @[@"KUNNR", @"TAHSTIP", @"KART_SAHIBI", @"KART_NUMARASI", @"MER_KEY", @"GUVENLIKKODU", @"AY", @"YIL", @"ORDER_ID", @"CUSTOMER_IP", @"CUSTOMER_EMAIL" ,@"CUSTOMER_FULLNAME", @"COMPANYNAME", @"AMOUNT", @"POINT", @"POINT_TUTAR", @"IS_POINT", @"GARENTA_TL", @"VKBUR", @"MUSTERIONAY"];
            
            NSMutableArray *itTahsilatValues = [NSMutableArray new];
            
            NSString *kunnr = @"";
            NSString *email = @"";
            
            if ([[ApplicationProperties getUser] isLoggedIn]) {
                kunnr = [[ApplicationProperties getUser] kunnr];
                email = [[ApplicationProperties getUser] email];
            }
            
            NSString *cardOwner = @"";
            NSString *cardNumber = @"";
            NSString *cardCV2 = @"";
            NSString *cardMonth = @"";
            NSString *cardYear = @"";
            NSString *merchantSafe = @"";
            
            NSString *ipAdress= [ApplicationProperties getCustomerIP];
            
            if ([_reservation.paymentNowCard.uniqueId isEqualToString:@""] || _reservation.paymentNowCard.uniqueId == nil) {
                cardOwner = _reservation.paymentNowCard.nameOnTheCard;
                cardNumber = _reservation.paymentNowCard.cardNumber;
                cardCV2 = _reservation.paymentNowCard.cvvNumber;
                cardMonth = _reservation.paymentNowCard.expirationMonth;
                cardYear = _reservation.paymentNowCard.expirationYear;
            }
            else {
                merchantSafe = _reservation.paymentNowCard.uniqueId;
            }
            
            NSArray *itTahsilatValue = @[kunnr, @"K", cardOwner, cardNumber, merchantSafe, cardCV2, cardMonth, cardYear, @"", ipAdress, email, cardOwner, @"", totalPrice, @"", @"", @"", @"", _reservation.checkOutOffice.subOfficeCode, @""];
            [itTahsilatValues addObject:itTahsilatValue];
            
            [handler addTableForImport:@"IT_TAHSILAT" andColumns:itTahsilatColumns andValues:itTahsilatValues];
        }
        
        [handler addTableForReturn:@"ET_RETURN"];
        [handler addTableForReturn:@"ET_KK_RETURN"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil) {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            
            NSString *subrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([subrc isEqualToString:@"0"]) {
                NSDictionary *esOutput = [export objectForKey:@"ES_OUTPUT"];
                
                NSString *reservationNo = [esOutput valueForKey:@"REZ_NO"];
                return reservationNo;
            }
            else {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                
                if (isPayNow) {
                    NSDictionary *etKKReturn = [tables objectForKey:@"ZNET_INT_TAHSILATLOG"];
                    
                    for (NSDictionary *temp in etKKReturn) {
                        alertString = [temp valueForKey:@"O_ERR_MESSAGE"];
                    }
                    
                    if ([alertString isEqualToString:@""]) {
                        alertString = @"Rezervasyon yaratımı sırasında hata oluştu. Lütfen tekrar deneyiniz";
                    }
                }
                else {
                    alertString = @"Rezervasyon yaratımı sırasında hata oluştu. Lütfen tekrar deneyiniz";
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![alertString isEqualToString:@""]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                }
            });
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
    
    return @"";
}

+ (NSString *)getCustomerIP
{
    NSString *ipAdress = @"192.168.1.1";
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mobil.garenta.com.tr/hgs/Service1.svc/json/getip/"]];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        NSError *jsonError;
        
        NSDictionary *requestResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if (jsonError == nil) {
            ipAdress =[requestResult valueForKey:@"GetUserIPResult"];
        }
    }
    
    return ipAdress;
}

@end
