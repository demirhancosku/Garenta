//
//  Reservation.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "Reservation.h"
#import "AdditionalEquipment.h"
#import "SDReservObject.h"
#import "ETExpiryObject.h"
#import "MailSoapHandler.h"

@implementation Reservation
@synthesize  checkOutTime,checkInTime,checkInOffice,checkOutOffice, selectedCarGroup,number,reservationStatu,paymentType,reservationType;

-(id)init{
    self = [super init];
    self.checkOutTime= [Reservation defaultCheckOutDate];
    self.checkInTime = [Reservation defaultCheckInDate];
    _selectedCar = nil;
    return self;
}


#pragma mark - util methods
//sıkıcı nsdate kodları
+ (NSDate*)defaultCheckInDate{
    NSDate *checkInDate = [NSDate date];
    
    //once 2 saat 15 dk ekliyoruz
    NSTimeInterval aTimeInterval = 135 * 60; //2 saat 15 dk
    checkInDate = [checkInDate dateByAddingTimeInterval:aTimeInterval];
    //sonra 1gun ekliyoruz
    aTimeInterval = 24 * 60 * 60;
    checkInDate = [checkInDate dateByAddingTimeInterval:aTimeInterval];
    //sonra dakikaları 0lıyoruz.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:checkInDate];
    checkInDate = [gregorianCalendar dateFromComponents:components];
    NSInteger difference = components.minute % 15;
    checkInDate = [checkInDate dateByAddingTimeInterval:-(NSTimeInterval)difference*60];
    return checkInDate;
}

+ (NSDate*)defaultCheckOutDate
{
    NSDate *checkOutDate = [NSDate date];
    //once 15 dk ekliyoruz
    NSTimeInterval aTimeInterval = 135 * 60; //15 dk
    checkOutDate = [checkOutDate dateByAddingTimeInterval:aTimeInterval];
    
    //sonra dakikaları bir ger dilime
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:checkOutDate];
    
    checkOutDate = [gregorianCalendar dateFromComponents:components];
    NSInteger difference = components.minute % 15;
    checkOutDate = [checkOutDate dateByAddingTimeInterval:-(NSTimeInterval)difference*60];
    
    return checkOutDate;
}

#pragma mark - reservation pricing methods
-(NSDecimalNumber*)totalPriceWithCurrency:(NSString*)currency isPayNow:(BOOL)isPayNow andGarentaTl:(NSString *)garentaTl andIsMontlyRent:(BOOL)isMontlyRent andIsCorparatePayment:(BOOL)isCorparate andIsPersonalPayment:(BOOL)isPersonalPayment andReservation:(Reservation *)reservation
{
    NSDecimalNumber *totalPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    NSDecimalNumber *totalEquiPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    if (selectedCarGroup.sampleCar.pricing.priceWithKDV == nil)
        selectedCarGroup.sampleCar.pricing.priceWithKDV = [NSDecimalNumber decimalNumberWithString:@"0"];
    if (selectedCarGroup.sampleCar.pricing.payNowPrice == nil)
        selectedCarGroup.sampleCar.pricing.payNowPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    if (selectedCarGroup.sampleCar.pricing.payLaterPrice == nil)
        selectedCarGroup.sampleCar.pricing.payLaterPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    if ([garentaTl isEqualToString:@""]) {
        garentaTl = @"0";
    }
    
    if ([currency isEqualToString:@"TRY"])
    {
        // kampanya üzerinden geldiyse buraya girer
        if (reservation.campaignObject != nil) {
            if (isMontlyRent)
            {
                for (ETExpiryObject *tempObject in self.etExpiry) {
                    if ([tempObject.carGroup isEqualToString:selectedCarGroup.groupCode] && [tempObject.campaignID isEqualToString:reservation.campaignObject.campaignID])
                    {
                        // Burda sadece ilk taksiti alıyoruz
                        totalPrice = [totalPrice decimalNumberByAdding:tempObject.totalPrice];
                        break;
                    }
                }
                
                for (AdditionalEquipment *tempEquipment in _additionalEquipments) {
                    if (tempEquipment.quantity > 0) {
                        totalEquiPrice = [totalEquiPrice decimalNumberByAdding:([tempEquipment.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",tempEquipment.quantity]]])];
                    }
                }
            }
            else
            {
                if (reservation.campaignObject.campaignReservationType == payNowReservation || reservation.campaignObject.campaignReservationType == payFrontWithNoCancellation)
                    totalPrice = reservation.campaignObject.campaignPrice.payNowPrice;
                else
                    totalPrice = reservation.campaignObject.campaignPrice.payLaterPrice;
                
                if (self.etExpiry.count > 0) {
                    totalPrice = reservation.campaignObject.campaignPrice.priceWithKDV;
                }
                
                if (_selectedCar) {
                    if (_selectedCar.pricing.carSelectPrice == nil) {
                        _selectedCar.pricing.carSelectPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                    }
                    totalPrice = [totalPrice decimalNumberByAdding:_selectedCar.pricing.carSelectPrice];
                }
                
                for (AdditionalEquipment *tempEquipment in _additionalEquipments) {
                    if (tempEquipment.quantity >0) {
                        totalEquiPrice = [totalEquiPrice decimalNumberByAdding:([tempEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",tempEquipment.quantity]]])];
                    }
                }
            }
            
            totalPrice = [totalPrice decimalNumberByAdding:totalEquiPrice];
        }
        
        else if (isMontlyRent) {
            for (ETExpiryObject *tempObject in self.etExpiry) {
                if ([tempObject.carGroup isEqualToString:selectedCarGroup.groupCode]) {
                    // Burda sadece ilk taksiti alıyoruz
                    totalPrice = [totalPrice decimalNumberByAdding:tempObject.totalPrice];
                    break;
                }
            }
            
            for (AdditionalEquipment *tempEquipment in _additionalEquipments) {
                if (tempEquipment.quantity > 0) {
                    totalEquiPrice = [totalEquiPrice decimalNumberByAdding:([tempEquipment.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",tempEquipment.quantity]]])];
                }
            }
            
            totalPrice = [totalPrice decimalNumberByAdding:totalEquiPrice];
        }
        else if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"] && (isCorparate || isPersonalPayment)) {
            // Ata Cengiz Corparate Payment
            
            NSDecimalNumber *corparatePayment = [NSDecimalNumber decimalNumberWithString:@"0"];
            NSDecimalNumber *personalPayment = [NSDecimalNumber decimalNumberWithString:@"0"];
            
            // First vehicle Payment
            if ([[ApplicationProperties getUser] isCorporateVehiclePayment]) {
                // Payment is being handled by the corparation
                
                if (isPayNow) {
                    corparatePayment = [corparatePayment decimalNumberByAdding:selectedCarGroup.sampleCar.pricing.payNowPrice];
                }
                else {
                    corparatePayment = [corparatePayment decimalNumberByAdding:selectedCarGroup.sampleCar.pricing.payLaterPrice];
                }
                
                // Araç seçim farkı
                if (_selectedCar != nil) {
                    // Şimdilik kurumsalda araç seçimi her zaman personal
                    personalPayment = [personalPayment decimalNumberByAdding:_selectedCar.pricing.carSelectPrice];
                }
                
                // REZERVASYONDAKİ EK ÜRÜNLER
                for (AdditionalEquipment *temp in _additionalEquipments)
                {
                    if (temp.quantity > 0 && ![temp.updateStatus isEqualToString:@"D"])
                    {
                        if ([temp.paymentType isEqualToString:@"F"]) {
                            corparatePayment = [corparatePayment decimalNumberByAdding:temp.price];
                        }
                        if ([temp.paymentType isEqualToString:@"P"]) {
                            personalPayment = [personalPayment decimalNumberByAdding:temp.price];
                        }
                    }
                }
                
                if (isCorparate) {
                    totalPrice = corparatePayment;
                }
                else if (isPersonalPayment) {
                    totalPrice = personalPayment;
                }
            }
            else {
                // if corparate payment is not true then all expenses will be covered by Personel
                totalPrice = [self totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:garentaTl andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:NO andReservation:reservation];
            }
        }
        else {
            // Bireysel günlük rezervasyon
            if (isPayNow) {
                // Aylık olduğu için kdvli değeri almamız lazım
                if (self.etExpiry.count > 0) {
                    totalPrice = [[totalPrice decimalNumberByAdding:selectedCarGroup.sampleCar.pricing.priceWithKDV] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:garentaTl]];
                }
                else {
                    totalPrice = [[totalPrice decimalNumberByAdding:selectedCarGroup.sampleCar.pricing.payNowPrice] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:garentaTl]];
                }
            }
            else {
                if (self.etExpiry.count > 0) {
                    totalPrice = [totalPrice decimalNumberByAdding:selectedCarGroup.sampleCar.pricing.priceWithKDV];
                }
                else {
                    totalPrice = [totalPrice decimalNumberByAdding:selectedCarGroup.sampleCar.pricing.payLaterPrice];
                }
            }
            
            if (_selectedCar) {
                if (_selectedCar.pricing.carSelectPrice == nil) {
                    _selectedCar.pricing.carSelectPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                }
                totalPrice = [totalPrice decimalNumberByAdding:_selectedCar.pricing.carSelectPrice];
            }
            
            for (AdditionalEquipment *tempEquipment in _additionalEquipments) {
                if (tempEquipment.quantity >0) {
                    totalEquiPrice = [totalEquiPrice decimalNumberByAdding:([tempEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",tempEquipment.quantity]]])];
                }
            }
            
            totalPrice = [totalPrice decimalNumberByAdding:totalEquiPrice];
        }
    }
    
    return totalPrice;
}

-(NSDecimalNumber*)priceOfAdditionalEquipments{
    float totalValue = 0.0f;
    if (_additionalEquipments != nil) {
        for (AdditionalEquipment *tempEquipment in _additionalEquipments) {
            totalValue = totalValue + ( tempEquipment.quantity * [tempEquipment.price floatValue]);
        }
    }
    return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f.02",totalValue]];
}

+ (NSString *)createReservationAtSAP:(Reservation *)_reservation andIsPayNow:(BOOL)isPayNow andGarentaTl:(NSString *)garentaTl{
    NSString *alertString = @"";
    
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_CREATE_REZERVASYON"];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDateFormatter *timeFormatter = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        // IS_INPUT
        NSArray *isInputColumns = @[@"REZ_NO", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"ODEME_TURU", @"GARENTA_TL", @"BONUS", @"MILES_SMILES", @"GUN_SAYISI", @"TOPLAM_TUTAR", @"C_PRIORITY", @"C_CORP_PRIORITY", @"REZ_KANAL", @"FT_CIKIS_IL", @"FT_CIKIS_ILCE", @"FT_CIKIS_ADRES", @"FT_DONUS_IL", @"FT_DONUS_ILCE", @"FT_DONUS_ADRES", @"PARA_BIRIMI", @"FT_MALIYET_TIPI", @"USERNAME", @"PUAN_TIPI", @"UCUS_SAATI", @"UCUS_NO", @"ODEME_BICIMI", @"FATURA_ACIKLAMA", @"EMAIL_CONFIRM", @"TELNO_CONFIRM"];
        
        NSString *isPriority = @"";
        
        if ([[ApplicationProperties getUser] isPriority]) {
            isPriority = @"X";
        }
        
        NSString *paymentType = @"";
        
        if (isPayNow) {
            // Aylık şimdi öde
            if (_reservation.etExpiry.count > 0) {
                paymentType = @"8";
            }
            else {
                // Normal şimdi öde
                paymentType = @"1";
            }
        }
        else {
            // Aylık sonra öde
            if (_reservation.etExpiry.count > 0) {
                paymentType = @"6";
            }
            else {
                // Normal sonra öde
                paymentType = @"2";
            }
        }
        
        //AYLIKTA ÖN ÖDEMELİ YOK EKLE!
        if (_reservation.campaignObject.campaignReservationType == payFrontWithNoCancellation) {
            paymentType = @"3";
        }
        
        NSString *totalPrice = @"";
        NSString *cardPayment = @"";
        
        if (_reservation.etExpiry.count > 0) {
            totalPrice = [NSString stringWithFormat:@"%.02f",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:@"" andIsMontlyRent:YES andIsCorparatePayment:NO andIsPersonalPayment:NO andReservation:_reservation] floatValue]];
            
            cardPayment = [NSString stringWithFormat:@"%.02f",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:garentaTl andIsMontlyRent:YES andIsCorparatePayment:NO andIsPersonalPayment:NO andReservation:_reservation] floatValue]];
        }
        else if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
            totalPrice = [NSString stringWithFormat:@"%.02f", [[_reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:@"" andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:YES andReservation:_reservation] floatValue]];
            
            cardPayment = [NSString stringWithFormat:@"%.02f",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:garentaTl andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:YES andReservation:_reservation] floatValue]];
        }
        else {
            totalPrice = [NSString stringWithFormat:@"%.02f",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:@"" andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:NO andReservation:_reservation] floatValue]];
            
            cardPayment = [NSString stringWithFormat:@"%.02f",[[_reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:garentaTl andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:NO andReservation:_reservation] floatValue]];
        }
        
        NSString *dayCount = @"";
        
        if (_reservation.etExpiry.count > 0) {
            // Aylıkta gün sayısı yanlış geliyormuş
            dayCount = [Reservation getDayCount:_reservation];
        }
        else {
            dayCount = [_reservation.selectedCarGroup.sampleCar.pricing.dayCount stringValue];
            
            if ([dayCount isEqualToString:@""]) {
                dayCount = @"30";
            }
        }
        
        NSString *emailConfirmed = @"X";
        
        if (![[ApplicationProperties getUser] isLoggedIn]) {
            emailConfirmed = _reservation.temporaryUser.isUserMailChecked;
        }
        
        // G-Garenta TL kazandırmak için...İleride Mil yada Garentamı diye sorucaz... G-Garenta TL, M-Mil
        NSArray *isInputValues = @[@"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode,  paymentType, garentaTl, @"", @"", dayCount, totalPrice, @"", @"", @"40", @"", @"", @"", @"", @"", @"", @"TRY", @"", @"", @"G", @"", @"", @"", @"", emailConfirmed, @"X"];
        [handler addImportStructure:@"IS_INPUT" andColumns:isInputColumns andValues:isInputValues];
        
        // IS_USERINFO
        
        NSArray *isUserInfoColumns;
        NSArray *isUserInfoValues;
        
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            isUserInfoColumns = @[@"MUSTERINO", @"SALES_ORGANIZATION", @"DISTRIBUTION_CHANNEL", @"DIVISION", @"KANALTURU"];
            isUserInfoValues = @[[[ApplicationProperties getUser] kunnr], @"3063", @"33", @"65", @"Z07"];
        }
        else {
            
            isUserInfoColumns = @[@"MUSTERINO", @"CINSIYET", @"FIRSTNAME", @"LASTNAME", @"BIRTHDATE", @"TCKN", @"VERGINO", @"ADRESS", @"EMAIL", @"TELNO", @"UYRUK", @"ULKE", @"SALES_ORGANIZATION", @"DISTRIBUTION_CHANNEL", @"DIVISION", @"KANALTURU", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"EHLIYET_NO", @"EHLIYET_TARIHI", @"ILKODU", @"ILCEKOD", @"MIDDLENAME", @"PASAPORTNO", @"TK_KARTNO", @"TELNO_ULKE"];
            
            NSString *driverLicenseNo = @"";
            NSString *driverLicenseLocation = @"";
            NSString *driverLicenseType = @"";
            NSString *driverLicenseDate = @"";
            
            if (![_reservation.temporaryUser.driverLicenseNo isEqualToString:@""]) {
                driverLicenseNo = _reservation.temporaryUser.driverLicenseNo;
                driverLicenseLocation = _reservation.temporaryUser.driverLicenseLocation;
                driverLicenseType = _reservation.temporaryUser.driverLicenseType;
                driverLicenseDate = [dateFormatter stringFromDate:_reservation.temporaryUser.driversLicenseDate];
            }
            
            isUserInfoValues = @[@"", _reservation.temporaryUser.gender, _reservation.temporaryUser.name, _reservation.temporaryUser.surname, [dateFormatter stringFromDate:_reservation.temporaryUser.birthday], _reservation.temporaryUser.tckno, @"", _reservation.temporaryUser.address, _reservation.temporaryUser.email, _reservation.temporaryUser.mobile, _reservation.temporaryUser.nationality, _reservation.temporaryUser.country, @"3063", @"33", @"65", @"Z07", driverLicenseLocation, driverLicenseType, driverLicenseNo, driverLicenseDate, _reservation.temporaryUser.city, _reservation.temporaryUser.county, _reservation.temporaryUser.middleName, @"", @"", _reservation.temporaryUser.mobileCountry];
        }
        
        [handler addImportStructure:@"IS_USERINFO" andColumns:isUserInfoColumns andValues:isUserInfoValues];
        
        // IT_ARACLAR
        NSArray *itAraclarColumns = @[@"MATNR"];
        NSMutableArray *itAraclarValues = [NSMutableArray new];
        
        
        //kış lastiği array'de varmı bakıyoruz
        NSPredicate *winterTire = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0014"];
        NSArray *filterResult = [_reservation.additionalEquipments filteredArrayUsingPredicate:winterTire];
        
        // kış lastiği varsa ve seçilmişse, araçlar içinden kış lastiği özelliği olmayanları çıkartıyoruz.
        if (filterResult.count > 0) {
            AdditionalEquipment *temp = [filterResult objectAtIndex:0];
            NSMutableArray *tempArr = [_reservation.selectedCarGroup.cars copy];
            if (temp.quantity > 0) {
                for (Car *tempCar in tempArr) {
                    if (![tempCar.winterTire isEqualToString:@"X"]) {
                        [_reservation.selectedCarGroup.cars removeObject:tempCar];
                    }
                }
            }
        }
        
        for (Car *tempCar in _reservation.selectedCarGroup.cars) {
            if (_reservation.campaignObject.campaignScopeType == vehicleGroupCampaign || _reservation.campaignObject == nil) {
                NSArray *arr = @[[tempCar materialCode]];
                [itAraclarValues addObject:arr];
            }
            else if (_reservation.campaignObject.campaignScopeType == vehicleBrandCampaign && [_reservation.campaignObject.campaignPrice.brandId isEqualToString:tempCar.brandId])
            {
                NSArray *arr = @[[tempCar materialCode]];
                [itAraclarValues addObject:arr];
            }
            else if (_reservation.campaignObject.campaignScopeType == vehicleModelCampaign && [_reservation.campaignObject.campaignPrice.brandId isEqualToString:tempCar.brandId] && [_reservation.campaignObject.campaignPrice.modelId isEqualToString:tempCar.modelId])
            {
                NSArray *arr = @[[tempCar materialCode]];
                [itAraclarValues addObject:arr];
            }
        }
        
        [handler addTableForImport:@"IT_ARACLAR" andColumns:itAraclarColumns andValues:itAraclarValues];
        
        // IT_ITEMS
        NSArray *itItemsColumns = @[@"REZ_KALEM_NO", @"MALZEME_NO", @"MIKTAR", @"ARAC_GRUBU", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"KAMPANYA_ID", @"FIYAT", @"C_KISLASTIK", @"ARAC_RENK", @"SASI_NO", @"PLAKA_NO", @"JATO_MARKA", @"JATO_MODEL", @"FILO_SEGMENT", @"FIYAT_KODU", @"UPDATE_STATU", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"KALEM_TIPI", @"PARA_BIRIMI", @"IS_AYLIK", @"KURUM_BIREYSEL"];
        
        NSMutableArray *itItemsValues = [NSMutableArray new];
        
        NSString *matnr = @"";
        NSString *jatoBrandID = @"";
        NSString *jatoModelID = @"";
        NSString *priceCode = @"";
        NSString *isMontly = @"";
        NSString *colorCode = @"";
        NSString *carPrice = @"";
        
        if (_reservation.etReserv.count > 0) {
            priceCode = [[_reservation.etReserv objectAtIndex:0] priceCode];
        }
        
        if (_reservation.selectedCar != nil) {
            matnr = _reservation.selectedCar.materialCode;
            jatoBrandID = _reservation.selectedCar.brandId;
            jatoModelID = _reservation.selectedCar.modelId;
            colorCode = _reservation.selectedCar.colorCode;
        }
        
        if (_reservation.etExpiry.count > 0) {
            isMontly = @"X";
            // burda ilk tutarı alıyoruz
            for (ETExpiryObject *tempObject in _reservation.etExpiry) {
                
                if (_reservation.campaignObject)
                {
                    if ([tempObject.carGroup isEqualToString:_reservation.selectedCarGroup.groupCode] && [tempObject.campaignID isEqualToString:_reservation.campaignObject.campaignID]) {
                        // Burda sadece ilk taksiti alıyoruz
                        carPrice = tempObject.totalPrice.stringValue;
                        break;
                    }
                }
                else{
                    if ([tempObject.carGroup isEqualToString:_reservation.selectedCarGroup.groupCode]) {
                        // Burda sadece ilk taksiti alıyoruz
                        carPrice = tempObject.totalPrice.stringValue;
                        break;
                    }
                }
            }
            //            carPrice = _reservation.selectedCarGroup.priceWithKDV;
        }
        
        else if (isPayNow) {
            if (_reservation.campaignObject)
                carPrice = _reservation.campaignObject.campaignPrice.payNowPrice.stringValue;
            else
                carPrice = _reservation.selectedCarGroup.payNowPrice;
        }
        else{
            if (_reservation.campaignObject)
                carPrice = _reservation.campaignObject.campaignPrice.payLaterPrice.stringValue;
            else
                carPrice = _reservation.selectedCarGroup.payLaterPrice;
        }
        
        // Ata Cengiz 07.12.2014 Kurumsal rez hk
        NSString *corparatePayment = @"";
        if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
            if ([[ApplicationProperties getUser] isCorporateVehiclePayment]) {
                corparatePayment = @"";
            }
            else {
                corparatePayment = @"X";
            }
        }
        
        // ARAÇ
        NSString *campaignId = @"";
        if (_reservation.campaignObject) {
            campaignId = _reservation.campaignObject.campaignID;
        }
        
        NSArray *vehicleLine = @[@"", matnr, @"1", _reservation.selectedCarGroup.groupCode, _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, campaignId, carPrice, @"", @"", @"", @"", jatoBrandID, jatoModelID, _reservation.selectedCarGroup.segment, priceCode, @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", isMontly, corparatePayment];
        
        [itItemsValues addObject:vehicleLine];
        
        // Ekipmanlar, Hizmetler
        for (AdditionalEquipment *tempEquipment in _reservation.additionalEquipments) {
            for (int count = 0; count < tempEquipment.quantity; count++) {
                
                NSString *corparatePayment = @"";
                if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                    if ([[ApplicationProperties getUser] isCorporateVehiclePayment]) {
                        if ([tempEquipment.paymentType isEqualToString:@"F"]) {
                            corparatePayment = @"";
                        }
                    }
                    else {
                        corparatePayment = @"X";
                    }
                }
                
                NSString *price = @"";
                if (_reservation.etExpiry.count > 0) {
                    price = tempEquipment.monthlyPrice.stringValue;
                }
                else{
                    price = tempEquipment.price.stringValue;
                }
                
                NSArray *equipmentLine = @[@"", tempEquipment.materialNumber, @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", price, @"", @"", @"", @"", @"", @"", @"", @"", @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", isMontly, corparatePayment];
                
                [itItemsValues addObject:equipmentLine];
            }
        }
        
        // Aracını seçtiyse
        if (_reservation.selectedCar != nil) {
            
            NSString *corparatePayment = @"";
            if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                // Kurumsalda araç seçimi hep P
                corparatePayment = @"X";
            }
            
            NSArray *carSelectionLine = @[@"", @"HZM0031", @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", [_reservation.selectedCar.pricing.carSelectPrice stringValue], @"", @"", @"", @"", @"", @"", @"", @"", @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", isMontly, corparatePayment];
            [itItemsValues addObject:carSelectionLine];
        }
        
        [handler addTableForImport:@"IT_ITEMS" andColumns:itItemsColumns andValues:itItemsValues];
        
        // IT_EKSURUCU
        NSArray *itEkSurucuColumns = @[@"CINSIYET", @"FIRSTNAME", @"LASTNAME", @"BIRTHDATE", @"TCKN",@"PASAPORTNO", @"PASAPORTTARIHI", @"TELNO", @"UYRUK", @"ULKE", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"EHLIYET_NO", @"EHLIYET_TARIHI", @"EKSURUCU_NO", @"UPDATE_STATU", @"KALEM_NO"];
        
        NSMutableArray *itEkSurucuValues = [NSMutableArray new];
        
        for (AdditionalEquipment *temp in _reservation.additionalDrivers) {
            NSArray *additionalDriverLine = @[temp.additionalDriverGender, temp.additionalDriverFirstname, temp.additionalDriverSurname, [dateFormatter stringFromDate:temp.additionalDriverBirthday], temp.additionalDriverNationalityNumber, temp.additionalDriverPassportNumber, @"",@"",temp.additionalDriverNationality, @"", temp.additionalDriverLicensePlace, temp.additionalDriverLicenseClass, temp.additionalDriverLicenseNumber, [dateFormatter stringFromDate:temp.additionalDriverLicenseDate], @"", @"", @""];
            
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
        
        // IT_EXPIRY
        
        if (_reservation.etExpiry.count > 0) {
            NSArray *itExpiryColumns = @[@"ARAC_GRUBU", @"MARKA_ID", @"MODEL_ID", @"DONEM_BASI", @"DONEM_SONU", @"TUTAR", @"PARA_BIRIMI", @"KAMPANYA_ID", @"ODENDI", @"MALZEME"];
            
            NSMutableArray *itExpiryValues = [NSMutableArray new];
            
            NSString *brandID = @"";
            NSString *modelID = @"";
            
            if (_reservation.selectedCar != nil) {
                brandID = _reservation.selectedCar.brandId;
                modelID = _reservation.selectedCar.modelId;
            }
            else {
                brandID = _reservation.selectedCarGroup.sampleCar.brandId;
                modelID = _reservation.selectedCarGroup.sampleCar.modelId;
            }
            
            for (ETExpiryObject *tempObject in _reservation.etExpiry) {
                
                if (_reservation.campaignObject)
                {
                    // kampanyalı aracın taksit tablosu
                    NSString *campaignScopeType = @"";
                    
                    if (_reservation.campaignObject.campaignScopeType == payNowReservation) {
                        campaignScopeType = @"ZR2";
                    }
                    else if (_reservation.campaignObject.campaignScopeType == payLaterReservation){
                        campaignScopeType = @"ZR1";
                    }
                    else if (_reservation.campaignObject.campaignScopeType == payFrontWithNoCancellation){
                        campaignScopeType = @"ZR3";
                    }
                    
                    if ([tempObject.carGroup isEqualToString:_reservation.selectedCarGroup.groupCode] && [tempObject.brandID isEqualToString:brandID] && [tempObject.modelID isEqualToString:modelID] && [tempObject.campaignID isEqualToString:_reservation.campaignObject.campaignID] && [tempObject.campaignScopeType isEqualToString:campaignScopeType])
                    {
                        NSArray *arr = @[tempObject.carGroup, tempObject.brandID, tempObject.modelID, [dateFormatter stringFromDate:tempObject.beginDate], [dateFormatter stringFromDate:tempObject.endDate], tempObject.totalPrice.stringValue, tempObject.currency, tempObject.campaignID, tempObject.isPaid,tempObject.materialNo];
                        [itExpiryValues addObject:arr];
                    }
                }
                else
                {
                    // aracın taksit tablosu
                    if ([tempObject.carGroup isEqualToString:_reservation.selectedCarGroup.groupCode] && [tempObject.brandID isEqualToString:brandID] && [tempObject.modelID isEqualToString:modelID] && [tempObject.campaignID isEqualToString:@""])
                    {
                        NSArray *arr = @[tempObject.carGroup, tempObject.brandID, tempObject.modelID, [dateFormatter stringFromDate:tempObject.beginDate], [dateFormatter stringFromDate:tempObject.endDate], tempObject.totalPrice.stringValue, tempObject.currency, tempObject.campaignID, tempObject.isPaid,tempObject.materialNo];
                        [itExpiryValues addObject:arr];
                    }
                }
                //ekipmanların taksit tablosu
                if (![tempObject.materialNo isEqualToString:@""]) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber==%@",tempObject.materialNo];
                    NSArray *predicateArr = [_reservation.additionalEquipments filteredArrayUsingPredicate:predicate];
                    
                    if (predicateArr.count > 0 && [[predicateArr objectAtIndex:0] quantity] > 0) {
                        NSArray *arr = @[tempObject.carGroup, tempObject.brandID, tempObject.modelID, [dateFormatter stringFromDate:tempObject.beginDate], [dateFormatter stringFromDate:tempObject.endDate], tempObject.totalPrice.stringValue, tempObject.currency, tempObject.campaignID, tempObject.isPaid,tempObject.materialNo];
                        
                        [itExpiryValues addObject:arr];
                    }
                }
            }
            
            if (itExpiryValues.count > 0) {
                [handler addTableForImport:@"IT_EXPIRY" andColumns:itExpiryColumns andValues:itExpiryValues];
            }
        }
        
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
            
            NSString *ipAdress= [Reservation getCustomerIP];
            
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
            
            NSArray *itTahsilatValue = @[kunnr, @"K", cardOwner, cardNumber, merchantSafe, cardCV2, cardMonth, cardYear, @"", ipAdress, email, cardOwner, @"", cardPayment, @"", @"", @"", @"", _reservation.checkOutOffice.subOfficeCode, @""];
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
                User *tempUser = [ApplicationProperties getUser];
                
                NSString *mail = @"";
                NSString *fullName = @"";
                
                if (tempUser.isLoggedIn) {
                    mail = tempUser.email;
                    fullName = [NSString stringWithFormat:@"%@ %@ %@",tempUser.name,tempUser.middleName,tempUser.surname];
                }
                else
                {
                    mail = _reservation.temporaryUser.email;
                    fullName = [NSString stringWithFormat:@"%@ %@ %@",_reservation.temporaryUser.name,_reservation.temporaryUser.middleName,_reservation.temporaryUser.surname];
                }
                
                NSDictionary *esOutput = [export objectForKey:@"ES_OUTPUT"];
                NSString *reservationNo = [esOutput valueForKey:@"REZ_NO"];
                
                BOOL isSuccess = [MailSoapHandler sendReservationInfoMessage:_reservation toMail:mail withFullName:fullName withTotalPrice:totalPrice withReservationNumber:reservationNo withPaymentType:paymentType];
                
                return reservationNo;
            }
            else {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                
                if (isPayNow) {
                    NSDictionary *etKKReturn = [tables objectForKey:@"ZNET_INT_TAHSILATLOG"];
                    NSDictionary *etBapiretResturn = [tables objectForKey:@"BAPIRET2"];
                    
                    for (NSDictionary *temp in etBapiretResturn) {
                        alertString = [NSString stringWithFormat:@"%@ %@",alertString,[temp valueForKey:@"MESSAGE"]];
                    }
                    
                    if ([alertString isEqualToString:@""]) {
                        for (NSDictionary *temp in etKKReturn) {
                            alertString = [temp valueForKey:@"O_ERR_MESSAGE"];
                        }
                    }
                    
                    if ([alertString isEqualToString:@""]) {
                        alertString = @"Rezervasyon yaratımı sırasında hata oluştu. Lütfen tekrar deneyiniz";
                    }
                }
                else {
                    NSDictionary *etBapiretResturn = [tables objectForKey:@"BAPIRET2"];
                    for (NSDictionary *temp in etBapiretResturn) {
                        alertString = [NSString stringWithFormat:@"%@ %@",alertString,[temp valueForKey:@"MESSAGE"]];
                    }
                    
                    if ([alertString isEqualToString:@""]) {
                        alertString = @"Rezervasyon yaratımı sırasında hata oluştu. Lütfen tekrar deneyiniz";
                    }
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

+ (BOOL)changeReservationAtSAP:(Reservation *)_reservation andIsPayNow:(BOOL)isPayNow andTotalPrice:(NSDecimalNumber *)aTotalPrice andGarentaTl:(NSString *)garentaTl
{
    NSString *alertString = @"";
    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_UPDATE_REZERVASYON"];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDateFormatter *timeFormatter = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        // IS_INPUT
        NSArray *isInputColumns = @[@"REZ_NO", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"ODEME_TURU", @"GARENTA_TL", @"BONUS", @"MILES_SMILES", @"GUN_SAYISI", @"TOPLAM_TUTAR", @"C_PRIORITY", @"C_CORP_PRIORITY", @"REZ_KANAL", @"FT_CIKIS_IL", @"FT_CIKIS_ILCE", @"FT_CIKIS_ADRES", @"FT_DONUS_IL", @"FT_DONUS_ILCE", @"FT_DONUS_ADRES", @"PARA_BIRIMI", @"FT_MALIYET_TIPI", @"USERNAME", @"PUAN_TIPI", @"UCUS_SAATI", @"UCUS_NO", @"ODEME_BICIMI", @"FATURA_ACIKLAMA", @"EMAIL_CONFIRM", @"TELNO_CONFIRM"];
        
        NSString *isPriority = @"";
        
        if ([[ApplicationProperties getUser] isPriority]) {
            isPriority = @"X";
        }
        
        NSString *paymentType = @"";
        
        if (isPayNow) {
            // Aylık şimdi öde
            if (_reservation.etExpiry.count > 0) {
                paymentType = @"8";
            }
            else {
                // Normal şimdi öde
                paymentType = @"1";
            }
        }
        else {
            // Aylık sonra öde
            if (_reservation.etExpiry.count > 0) {
                paymentType = @"6";
            }
            else {
                // Normal sonra öde
                paymentType = @"2";
            }
        }
        
        if (_reservation.campaignObject.campaignReservationType == payFrontWithNoCancellation) {
            if (_reservation.etExpiry.count > 0) {
                paymentType = @"9";
            }
            else{
                paymentType = @"3";
            }
            
        }
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                            fromDate:[_reservation checkOutTime]
                                                              toDate:[_reservation checkInTime]
                                                             options:0];
        
        NSString *day = [NSString stringWithFormat:@"%li",(long)[components day]];
        NSString *totalPrice = [NSString stringWithFormat:@"%.02f",aTotalPrice.floatValue];
        
        // satış burosunu onurla konuşcam
        NSArray *isInputValues = @[_reservation.reservationNumber, [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode,  paymentType, garentaTl, @"", @"", day, totalPrice, @"", @"", @"40", @"", @"", @"", @"", @"", @"", @"TRY", @"", @"", @"G", @"", @"", @"", @"", @"", @""];
        
        [handler addImportStructure:@"IS_INPUT" andColumns:isInputColumns andValues:isInputValues];
        
        // IS_USERINFO
        NSArray *isUserInfoColumns;
        NSArray *isUserInfoValues;
        
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            isUserInfoColumns = @[@"MUSTERINO", @"SALES_ORGANIZATION", @"DISTRIBUTION_CHANNEL", @"DIVISION", @"KANALTURU"];
            isUserInfoValues = @[[[ApplicationProperties getUser] kunnr], @"3063", @"33", @"65", @"Z07"];
        }
        
        [handler addImportStructure:@"IS_USERINFO" andColumns:isUserInfoColumns andValues:isUserInfoValues];
        
        if ([_reservation.reservationType isEqualToString:@"10"] && _reservation.selectedCar == nil && ![_reservation.updateStatus isEqualToString:@"KAY"])
            _reservation.updateStatus = @"ARG";
        else if ([_reservation.reservationType isEqualToString:@"20"] && _reservation.selectedCar != nil && ![_reservation.updateStatus isEqualToString:@"KAY"] && ![_reservation.updateStatus isEqualToString:@"UPS"])
            _reservation.updateStatus = @"GAR";
        
        [handler addImportParameter:@"IV_UPDATE_STATU" andValue:_reservation.updateStatus];
        
        // IT_ARACLAR
        NSArray *itAraclarColumns = @[@"MATNR"];
        NSMutableArray *itAraclarValues = [NSMutableArray new];
        
        if ([_reservation.updateStatus isEqualToString:@"UPS"]) {
            for (CarGroup *tempCar in _reservation.upsellList) {
                if ([tempCar.groupCode isEqualToString:_reservation.upsellCarGroup.groupCode]) {
                    NSArray *arr = @[[tempCar.sampleCar materialCode]];
                    [itAraclarValues addObject:arr];
                }
            }
        }
        else if ([_reservation.updateStatus isEqualToString:@"DWS"])
            for (CarGroup *tempCar in _reservation.downsellList) {
                if ([tempCar.groupCode isEqualToString:_reservation.upsellCarGroup.groupCode]) {
                    NSArray *arr = @[[tempCar.sampleCar materialCode]];
                    [itAraclarValues addObject:arr];
                }
            }
        else
        {
            for (Car *tempCar in _reservation.selectedCarGroup.cars) {
                NSArray *arr = @[[tempCar materialCode]];
                [itAraclarValues addObject:arr];
            }
        }
        
        [handler addTableForImport:@"IT_ARACLAR" andColumns:itAraclarColumns andValues:itAraclarValues];
        
        // IT_ITEMS
        NSArray *itItemsColumns = @[@"REZ_KALEM_NO", @"MALZEME_NO", @"MIKTAR", @"ARAC_GRUBU", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"KAMPANYA_ID", @"FIYAT", @"C_KISLASTIK", @"ARAC_RENK", @"SASI_NO", @"PLAKA_NO", @"JATO_MARKA", @"JATO_MODEL", @"FILO_SEGMENT", @"FIYAT_KODU", @"UPDATE_STATU", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"KALEM_TIPI", @"PARA_BIRIMI", @"IS_AYLIK", @"KURUM_BIREYSEL"];
        
        NSMutableArray *itItemsValues = [NSMutableArray new];
        
        NSString *matnr = @"";
        NSString *jatoBrandID = @"";
        NSString *jatoModelID = @"";
        NSString *carPrice = @"";
        NSString *priceCode = @"";
        NSString *plateNo = @"";
        NSString *chassisNo = @"";
        NSString *colorCode = @"";
        
        if (_reservation.changeReservationDifference == nil) {
            _reservation.changeReservationDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
        }
        
        if (_reservation.etReserv.count > 0) {
            priceCode = [[_reservation.etReserv objectAtIndex:0] priceCode];
        }
        
        
        if (_reservation.upsellCarGroup)
        {
            if (_reservation.upsellSelectedCar) {
                matnr = _reservation.upsellSelectedCar.materialCode;
                jatoBrandID = _reservation.upsellSelectedCar.brandName;
                jatoModelID = _reservation.upsellSelectedCar.modelName;
                
                if (isPayNow) {
                    carPrice = _reservation.upsellSelectedCar.pricing.payNowPrice.stringValue;
                }
                else{
                    carPrice = _reservation.upsellSelectedCar.pricing.payLaterPrice.stringValue;
                }
            }
            else
            {
                matnr = @"";
                jatoBrandID = @"";
                jatoModelID = @"";
                if (isPayNow)
                    carPrice = _reservation.upsellCarGroup.sampleCar.pricing.payNowPrice.stringValue;
                else
                    carPrice = _reservation.upsellCarGroup.sampleCar.pricing.payLaterPrice.stringValue;
            }
            
            
            //UPSELL YADA DOWNSELL İLE SEÇİLMİŞ ARAÇ
            NSArray *upsellDownsellLine = @[@"", matnr, @"1", _reservation.upsellCarGroup.groupCode, _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", carPrice, @"", @"", chassisNo, plateNo, jatoBrandID, jatoModelID, _reservation.upsellCarGroup.segment, priceCode, @"I", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
            
            [itItemsValues addObject:upsellDownsellLine];
        }
        else
        {
            if (_reservation.selectedCar)
            {
                matnr = _reservation.selectedCar.materialCode;
                jatoBrandID = _reservation.selectedCar.brandName;
                jatoModelID = _reservation.selectedCar.modelName;
                plateNo = _reservation.selectedCar.plateNo;
                chassisNo = _reservation.selectedCar.chassisNo;
                colorCode = _reservation.selectedCar.colorCode;
            }
            
            if (_reservation.etExpiry.count > 0){
                for (ETExpiryObject *temp in _reservation.etExpiry){
                    if (![temp.carGroup isEqualToString:@""]) {
                        carPrice = [[temp totalPrice] stringValue];
                        break;
                    }
                }
            }
            else{
                carPrice = [[_reservation.changeReservationDifference decimalNumberByAdding:_reservation.selectedCarGroup.sampleCar.pricing.payNowPrice] stringValue];
            }
            
            // ARAÇ
            
            NSString *campaignId = @"";
            if (_reservation.campaignObject) {
                campaignId = _reservation.campaignObject.campaignID;
            }
            NSArray *vehicleLine = @[@"", matnr, @"1", _reservation.selectedCarGroup.groupCode, _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, campaignId, carPrice, @"", colorCode, chassisNo, plateNo, jatoBrandID, jatoModelID, _reservation.selectedCarGroup.segment, priceCode, @"U", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
            
            [itItemsValues addObject:vehicleLine];
        }
        
        // Ekipmanlar, Hizmetler
        for (AdditionalEquipment *tempEquipment in _reservation.additionalEquipments)
        {
            NSString *price = @"";
            if (_reservation.etExpiry.count > 0) {
                price = tempEquipment.monthlyPrice.stringValue;
            }
            else{
                price = tempEquipment.price.stringValue;
            }
            
            if ([tempEquipment updateStatus] != nil)
            {
                NSArray *equipmentLine = @[@"", tempEquipment.materialNumber, @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", price, @"", @"", @"", @"", @"", @"", @"", @"", tempEquipment.updateStatus, [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
                
                [itItemsValues addObject:equipmentLine];
            }
        }
        
        // Aracını seçtiyse ve gruba rezervasyonsa (araca rezervasyonsa ekipmanların içinde HZM0031 geliyo zaten)
        if (_reservation.selectedCar && [_reservation.reservationType isEqualToString:@"20"]) {
            
            NSString *carSelectionPrice = [NSString stringWithFormat:@"%.02f",_reservation.selectedCar.pricing.carSelectPrice.floatValue];//[_reservation.selectedCar.pricing.carSelectPrice stringValue];
            
            NSArray *carSelectionLine = @[@"", @"HZM0031", @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", carSelectionPrice, @"", @"", @"", @"", @"", @"", @"", @"", @"I", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
            [itItemsValues addObject:carSelectionLine];
        }
        
        // Upsellde Aracını seçtiyse ve gruba rezervasyonsa (araca rezervasyonsa ekipmanların içinde HZM0031 geliyo zaten)
        if (_reservation.upsellSelectedCar && [_reservation.reservationType isEqualToString:@"20"]) {
            NSArray *carSelectionLine = @[@"", @"HZM0031", @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", [_reservation.upsellSelectedCar.pricing.carSelectPrice stringValue], @"", @"", @"", @"", @"", @"", @"", @"", @"I", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
            [itItemsValues addObject:carSelectionLine];
        }
        
        [handler addTableForImport:@"IT_ITEMS" andColumns:itItemsColumns andValues:itItemsValues];
        
        // IT_EKSURUCU
        NSArray *itEkSurucuColumns = @[@"CINSIYET", @"FIRSTNAME", @"LASTNAME", @"BIRTHDATE", @"TCKN",@"PASAPORTNO", @"PASAPORTTARIHI", @"TELNO", @"UYRUK", @"ULKE", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"EHLIYET_NO", @"EHLIYET_TARIHI", @"EKSURUCU_NO", @"UPDATE_STATU", @"KALEM_NO"];
        
        NSMutableArray *itEkSurucuValues = [NSMutableArray new];
        
        for (AdditionalEquipment *temp in _reservation.additionalDrivers) {
            NSArray *additionalDriverLine = @[temp.additionalDriverGender, temp.additionalDriverFirstname, temp.additionalDriverSurname, [dateFormatter stringFromDate:temp.additionalDriverBirthday], temp.additionalDriverNationalityNumber, temp.additionalDriverPassportNumber, @"",@"",temp.additionalDriverNationality, @"", temp.additionalDriverLicensePlace, temp.additionalDriverLicenseClass, temp.additionalDriverLicenseNumber, [dateFormatter stringFromDate:temp.additionalDriverLicenseDate], @"", @"", @""];
            
            [itEkSurucuValues addObject:additionalDriverLine];
        }
        
        if ([itEkSurucuValues count] > 0) {
            [handler addTableForImport:@"IT_EKSURUCU" andColumns:itEkSurucuColumns andValues:itEkSurucuValues];
        }
        
        // IT_SD Reserv
        NSArray *itSDReservColumns = @[@"SUBE", @"GRUP_KODU", @"FIYAT_KODU", @"TARIH", @"R_VBELN", @"R_POSNR", @"R_GJAHR", @"R_AUART", @"MATNR", @"KUNNR", @"HDFSUBE", @"AUGRU", @"VKORG", @"VTWEG", @"SPART", @"TUTAR", @"GRNTTL_KAZANIR", @"MIL_KAZANIR", @"BONUS_KAZANIR"];
        
        NSMutableArray *itSDReservValues = [NSMutableArray new];
        
        for (SDReservObject *tempObject in _reservation.etReserv) {
            NSArray *arr = @[tempObject.office, tempObject.groupCode, tempObject.priceCode, tempObject.date, tempObject.rVbeln, tempObject.rPosnr, tempObject.RGjahr, tempObject.rAuart, tempObject.matnr, tempObject.kunnr, tempObject.destinationOffice, tempObject.augru, tempObject.vkorg, tempObject.vtweg, tempObject.spart, tempObject.price, tempObject.isGarentaTl, tempObject.isMiles, tempObject.isBonus];
            [itSDReservValues addObject:arr];
        }
        
        [handler addTableForImport:@"IT_SDREZERV" andColumns:itSDReservColumns andValues:itSDReservValues];
        
        // IT_EXPIRY
        if (_reservation.etExpiry.count > 0) {
            NSArray *itExpiryColumns = @[@"ARAC_GRUBU", @"MARKA_ID", @"MODEL_ID", @"DONEM_BASI", @"DONEM_SONU", @"TUTAR", @"PARA_BIRIMI", @"KAMPANYA_ID", @"ODENDI",@"MALZEME"];
            
            NSMutableArray *itExpiryValues = [NSMutableArray new];
            
            for (ETExpiryObject *tempObject in _reservation.etExpiry) {
                if ([tempObject.carGroup isEqualToString:_reservation.selectedCarGroup.groupCode]) {
                    NSArray *arr = @[tempObject.carGroup, tempObject.brandID, tempObject.modelID, [dateFormatter stringFromDate:tempObject.beginDate], [dateFormatter stringFromDate:tempObject.endDate], tempObject.totalPrice.stringValue, tempObject.currency, tempObject.campaignID, tempObject.isPaid,tempObject.materialNo];
                    [itExpiryValues addObject:arr];
                }
                
                if (![tempObject.materialNo isEqualToString:@""]) {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber==%@",tempObject.materialNo];
                    NSArray *predicateArr = [_reservation.additionalEquipments filteredArrayUsingPredicate:predicate];
                    
                    if (predicateArr.count > 0 && [[predicateArr objectAtIndex:0] quantity] > 0) {
                        NSArray *arr = @[tempObject.carGroup, tempObject.brandID, tempObject.modelID, [dateFormatter stringFromDate:tempObject.beginDate], [dateFormatter stringFromDate:tempObject.endDate], tempObject.totalPrice.stringValue, tempObject.currency, tempObject.campaignID, tempObject.isPaid,tempObject.materialNo];
                        
                        [itExpiryValues addObject:arr];
                    }
                }
            }
            
            if (itExpiryValues.count > 0) {
                [handler addTableForImport:@"IT_EXPIRY" andColumns:itExpiryColumns andValues:itExpiryValues];
            }
        }
        
        
        if ([garentaTl isEqualToString:@""]) {
            garentaTl = @"0";
        }
        NSString *cardPayment = [NSString stringWithFormat:@"%.02f",(aTotalPrice.floatValue - garentaTl.floatValue)];
        
        if (isPayNow || aTotalPrice.floatValue < 0) {
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
            
            NSString *ipAdress= [Reservation getCustomerIP];
            
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
            
            NSArray *itTahsilatValue = @[kunnr, @"K", cardOwner, cardNumber, merchantSafe, cardCV2, cardMonth, cardYear, @"", ipAdress, email, cardOwner, @"", cardPayment, @"", @"", @"", @"", _reservation.checkOutOffice.subOfficeCode, @""];
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
                User *tempUser = [ApplicationProperties getUser];
                
                NSString *mail = @"";
                NSString *fullName = @"";
                
                if (tempUser.isLoggedIn) {
                    mail = tempUser.email;
                    fullName = [NSString stringWithFormat:@"%@ %@ %@",tempUser.name,tempUser.middleName,tempUser.surname];
                }
                else
                {
                    mail = _reservation.temporaryUser.email;
                    fullName = [NSString stringWithFormat:@"%@ %@ %@",_reservation.temporaryUser.name,_reservation.temporaryUser.middleName,_reservation.temporaryUser.surname];
                }
                
                NSDictionary *esOutput = [export objectForKey:@"ES_OUTPUT"];
                
                NSString *reservationNo = [esOutput valueForKey:@"REZ_NO"];
                
                BOOL isSuccess = [MailSoapHandler sendReservationInfoMessage:_reservation toMail:mail withFullName:fullName withTotalPrice:totalPrice withReservationNumber:reservationNo withPaymentType:paymentType];
                
                return YES;
            }
            else {
                
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                
                if (isPayNow) {
                    NSDictionary *etKKReturn = [tables objectForKey:@"BAPIRET2"];
                    
                    for (NSDictionary *temp in etKKReturn) {
                        alertString = [temp valueForKey:@"MESSAGE"];
                    }
                    
                    if ([alertString isEqualToString:@""]) {
                        alertString = @"Rezervasyon güncelleme sırasında hata oluştu. Lütfen tekrar deneyiniz";
                    }
                }
                else {
                    NSDictionary *etKKReturn = [tables objectForKey:@"BAPIRET2"];
                    
                    for (NSDictionary *temp in etKKReturn) {
                        alertString = [temp valueForKey:@"MESSAGE"];
                    }
                    
                    if ([alertString isEqualToString:@""]) {
                        alertString = @"Rezervasyon güncelleme sırasında hata oluştu. Lütfen tekrar deneyiniz";
                    }
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
    
    return NO;
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

+ (NSString *)getDayCount:(Reservation *)reservation {
    
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZSD_KDK_KIRA_GUNU"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        [handler addImportParameter:@"I_CIKIS" andValue:[dateFormatter stringFromDate:reservation.checkOutTime]];
        [handler addImportParameter:@"I_DONUS" andValue:[dateFormatter stringFromDate:reservation.checkInTime]];
        [handler addImportParameter:@"I_CIKIS_SAATI" andValue:[timeFormatter stringFromDate:reservation.checkOutTime]];
        [handler addImportParameter:@"I_DONUS_SAATI" andValue:[timeFormatter stringFromDate:reservation.checkInTime]];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil)
        {
            NSDictionary *export = [resultDict objectForKey:@"EXPORT"];
            
            NSString *dayCount = [NSString stringWithFormat:@"%li", (long)[[export valueForKey:@"E_KIRA_GUN"] integerValue]] ;
            
            return dayCount;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
    
    return @"";
}

@end
