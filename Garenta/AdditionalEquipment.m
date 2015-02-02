//
//  AdditionalEquipment.m
//  Garenta
//
//  Created by Alp Keser on 6/3/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "AdditionalEquipment.h"
#import "ETExpiryObject.h"

@implementation AdditionalEquipment

- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] alloc] init];
    if (copy) {
        [copy setMaterialNumber:[self.materialNumber copyWithZone:zone]];
        [copy setMaterialDescription:[self.materialDescription copyWithZone:zone]];
        [copy setMaterialInfo:[self.materialInfo copyWithZone:zone]];
        [copy setQuantity:self.quantity];
        [copy setPrice:[self.price copyWithZone:zone]];
        [copy setMonthlyPrice:[self.monthlyPrice copyWithZone:zone]];
        [copy setMaxQuantity:[self.maxQuantity copyWithZone:zone]];
        [copy setAdditionalDriverFirstname:@""];
        [copy setAdditionalDriverMiddlename:@""];
        [copy setAdditionalDriverSurname:@""];
        [copy setAdditionalDriverBirthday:[NSDate date]];
        [copy setAdditionalDriverGender:@""];
        [copy setAdditionalDriverNationality:@""];
        [copy setAdditionalDriverNationalityNumber:@""];
        [copy setAdditionalDriverPassportNumber:@""];
        [copy setAdditionalDriverLicenseClass:@""];
        [copy setAdditionalDriverLicenseNumber:@""];
        [copy setAdditionalDriverLicensePlace:@""];
        [copy setUpdateStatus:@""];
        [copy setAdditionalDriverLicenseDate:[NSDate date]];
        [copy setIsRequired:NO];

        [(AdditionalEquipment*)copy setType:self.type];
    }
    
    return copy;
}

+ (NSDictionary *)getAdditionalEquipmentsFromSAP:(Reservation *)_reservation andIsYoungDriver:(BOOL)_isYoungDriver
{
    NSMutableArray *_additionalEquipments = [NSMutableArray new];
    NSMutableArray *_additionalEquipmentsFullList = [NSMutableArray new];
    
    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_KDK_GET_EQUIPMENT_LIST"];
        
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        
        NSDateFormatter *timeFormatter  = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        [handler addImportParameter:@"IMPP_MSUBE" andValue:_reservation.checkOutOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_DSUBE" andValue:_reservation.checkInOffice.subOfficeCode];
        [handler addImportParameter:@"IMPP_LANGU" andValue:@"T"];
        [handler addImportParameter:@"IMPP_GRPKOD" andValue:_reservation.selectedCarGroup.groupCode];
        [handler addImportParameter:@"IMPP_MARKAID" andValue:_reservation.selectedCarGroup.sampleCar.brandId];
        [handler addImportParameter:@"IMPP_MODELID" andValue:_reservation.selectedCarGroup.sampleCar.modelId];
        [handler addImportParameter:@"IMPP_BEGDA" andValue:[dateFormatter stringFromDate:_reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDDA" andValue:[dateFormatter stringFromDate:_reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_BEGUZ" andValue:[timeFormatter stringFromDate:_reservation.checkOutTime]];
        [handler addImportParameter:@"IMPP_ENDUZ" andValue:[timeFormatter stringFromDate:_reservation.checkInTime]];
        [handler addImportParameter:@"IMPP_KANAL" andValue:@"40"];
        
        if (_reservation.selectedCarGroup.priceWithKDV.floatValue > 0) {
            [handler addImportParameter:@"IMPP_TUTAR" andValue:_reservation.selectedCarGroup.priceWithKDV];
        }
        else
            [handler addImportParameter:@"IMPP_TUTAR" andValue:_reservation.selectedCarGroup.sampleCar.pricing.payNowPrice.stringValue];
        
        NSString *fikod = @"";
        NSString *kunnr = @"";
        
        if ([[ApplicationProperties getUser] isLoggedIn]) {
            fikod = [[ApplicationProperties getUser] priceCode];
            kunnr = [[ApplicationProperties getUser] kunnr];
        }
        
        if (([fikod isEqualToString:@""] || fikod == nil) && _reservation.etReserv.count > 0) {
            fikod = [[_reservation.etReserv objectAtIndex:0] priceCode];
        }
        
        [handler addImportParameter:@"IMPP_MUSNO" andValue:kunnr];
        [handler addImportParameter:@"IMPP_FIKOD" andValue:fikod];
        
        [handler addTableForReturn:@"EXPT_EKPLIST"];
        [handler addTableForReturn:@"EXPT_SIGORTA"];
        [handler addTableForReturn:@"EXPT_EKSURUCU"];
        [handler addTableForReturn:@"EXPT_EXPIRY"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil)
        {
            NSDictionary *tables = [resultDict objectForKey:@"TABLES"];
            
            _additionalEquipments = [NSMutableArray new];
            _additionalEquipmentsFullList = [NSMutableArray new];
            
            NSDictionary *etExpiry = [tables objectForKey:@"ZSD_KDK_AYLIK_TAKSIT_ST"];
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            for (NSDictionary *tempDict in etExpiry) {
                ETExpiryObject *tempObject = [ETExpiryObject new];
                
                [tempObject setCarGroup:[tempDict valueForKey:@"ARAC_GRUBU"]];
                [tempObject setBeginDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_BASI"]]];
                [tempObject setEndDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_SONU"]]];
                [tempObject setCampaignID:[tempDict valueForKey:@"KAMPANYA_ID"]];
                [tempObject setCampaignScopeType:[tempDict valueForKey:@"KAMP_REZTURU"]];
                [tempObject setBrandID:[tempDict valueForKey:@"MARKA_ID"]];
                [tempObject setModelID:[tempDict valueForKey:@"MODEL_ID"]];
                [tempObject setIsPaid:[tempDict valueForKey:@"ODENDI"]];
                [tempObject setCurrency:[tempDict valueForKey:@"PARA_BIRIMI"]];
                [tempObject setMaterialNo:[tempDict valueForKey:@"MALZEME"]];
                [tempObject setTotalPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                
                [_reservation.etExpiry addObject:tempObject];
            }
            
            NSDictionary *equipmentList = [tables objectForKey:@"ZPM_S_EKIPMAN_LISTE"];
            
            for (NSDictionary *tempDict in equipmentList)
            {
                // ek ürünlerin kampanyalı fiyatları
                NSDecimalNumber *campaignPrice = [NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"KAMPANYALI_TUTAR"]];
                
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MATNR"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MUS_TANIMI"]];
                if (campaignPrice.floatValue > 0) {
                    [tempEquip setPrice:campaignPrice];
                }
                else{
                    [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"NETWR"]]];
                }
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_MIKTAR"]]];
                [tempEquip setType:standartEquipment];
                
                if ([[ApplicationProperties getUser] isLoggedIn]) {
                    if ([[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                        NSString *fatTip = [tempDict valueForKey:@"FAT_TIP"];
                        
                        if (fatTip == nil || [fatTip isEqualToString:@""]) {
                            fatTip = @"P";
                        }
                        
                        [tempEquip setPaymentType:fatTip];
                    }
                }
                
                if ([tempEquip.materialNumber isEqualToString:@"HZM0014"]) {
                    NSPredicate *tempPredicate = [NSPredicate predicateWithFormat:@"winterTire=%@",@"X"];
                    NSArray *tempPredicateArray = [_reservation.selectedCarGroup.cars filteredArrayUsingPredicate:tempPredicate];
                    if (tempPredicateArray.count == 0) {
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                    {
                        [_additionalEquipments addObject:tempEquip];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                }
                else
                {
                    // Ata Cengiz 07.12.2014 corparate
                    NSString *mandotaryEquipment = [tempDict valueForKey:@"ZORUNLU"];
                    
                    if ([mandotaryEquipment isEqualToString:@"X"]) {
                        [tempEquip setQuantity:1];
                        [tempEquip setIsRequired:YES];
                    }
                    else {
                        [tempEquip setQuantity:0];
                    }
                    
                    [_additionalEquipments addObject:tempEquip];
                    [_additionalEquipmentsFullList addObject:tempEquip];
                }
            }
            
            NSDictionary *assuranceList = [tables objectForKey:@"ZMOB_KDK_S_SIGORTA"];
            
            for (NSDictionary *tempDict in assuranceList)
            {
                // ek ürünlerin kampanyalı fiyatları
                NSDecimalNumber *campaignPrice = [NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"KAMPANYALI_TUTAR"]];
                
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                if (campaignPrice.floatValue > 0) {
                    [tempEquip setPrice:campaignPrice];
                }
                else{
                    [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                }
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                [tempEquip setType:additionalInsurance];
                
                // Ata Cengiz 07.12.2014 corparate
                NSString *mandotaryEquipment = [tempDict valueForKey:@"ZORUNLU"];
                
                if ([mandotaryEquipment isEqualToString:@"X"]) {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                }
                else {
                    [tempEquip setQuantity:0];
                }
                
                if ([[ApplicationProperties getUser] isLoggedIn]) {
                    if ([[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                        NSString *fatTip = [tempDict valueForKey:@"FAT_TIP"];
                        
                        if (fatTip == nil || [fatTip isEqualToString:@""]) {
                            fatTip = @"P";
                        }
                        [tempEquip setPaymentType:fatTip];
                    }
                }
                
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0020"] && tempEquip.price.floatValue > 0) //tek yön ücreti varsa hep 1 olacak
                {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                    [_additionalEquipments insertObject:tempEquip atIndex:0];
                    [_additionalEquipmentsFullList addObject:tempEquip];
                }
                
                // ARAÇ SEÇİM FARKI full list içinde var, ekrana gösterdiğimiz array de yok
                else if ([[tempEquip materialNumber] isEqualToString:@"HZM0031"])
                {
                    //eski ezervasyonlardan araç seçim farkı geliyomu kontrolü
                    NSPredicate *carSelectPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
                    NSArray *carSelectPredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:carSelectPredicate];
                    
                    _reservation.selectedCarGroup.sampleCar.pricing.carSelectPrice = tempEquip.price;
                    for (Car *temp in _reservation.selectedCarGroup.cars) {
                        temp.pricing.carSelectPrice = tempEquip.price;
                    }
                    
                    if (carSelectPredicateArray.count > 0)
                    {
                        [tempEquip setQuantity:1];
                        [tempEquip setIsRequired:YES];
                        [tempEquip setPrice:[[carSelectPredicateArray objectAtIndex:0] price]];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                        [_additionalEquipmentsFullList addObject:tempEquip];
                }
                // EĞER GENÇ SÜRÜCÜ VARSA MAKSİMUM GÜVENCE EN ÜSTE EKLENİYO VE ZORUNLU OLUYO
                else if ([[tempEquip materialNumber]isEqualToString:@"HZM0012"])
                {
                    // eski ezervasyonlardan Maks.güvence geliyomu kontrolü
                    NSPredicate *maxSecurePredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0012"];
                    NSArray *maxSecurePredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:maxSecurePredicate];
                    
                    if (_isYoungDriver || maxSecurePredicateArray.count > 0)
                    {
                        [tempEquip setQuantity:1];
                        [tempEquip setIsRequired:YES];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                    {
                        [_additionalEquipments addObject:tempEquip];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                }
                else
                {
                    [_additionalEquipments addObject:tempEquip];
                    [_additionalEquipmentsFullList addObject:tempEquip];
                }
            }
            
            NSDictionary *additionalEquipmentList = [tables objectForKey:@"ZMOB_KDK_S_EKSURUCU"];
            
            for (NSDictionary *tempDict in additionalEquipmentList)
            {
                // ek ürünlerin kampanyalı fiyatları
                NSDecimalNumber *campaignPrice = [NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"KAMPANYALI_TUTAR"]];
                
                AdditionalEquipment *tempEquip = [AdditionalEquipment new];
                [tempEquip setMaterialNumber:[tempDict valueForKey:@"MALZEME"]];
                [tempEquip setMaterialDescription:[tempDict valueForKey:@"MAKTX"]];
                [tempEquip setMaterialInfo:[tempDict valueForKey:@"MALZEME_INFO"]];
                if (campaignPrice.floatValue > 0) {
                    [tempEquip setPrice:campaignPrice];
                }
                else{
                    [tempEquip setPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                }
                [tempEquip setMonthlyPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"AYLIK_TAHSIL"]]];
                [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"MAX_ADET"]]];
                
                // Ata Cengiz 07.12.2014 corparate
                NSString *mandotaryEquipment = [tempDict valueForKey:@"ZORUNLU"];
                
                if ([mandotaryEquipment isEqualToString:@"X"]) {
                    [tempEquip setQuantity:1];
                    [tempEquip setIsRequired:YES];
                }
                else {
                    [tempEquip setQuantity:0];
                }
                
                if ([[ApplicationProperties getUser] isLoggedIn]) {
                    if ([[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
                        NSString *fatTip = [tempDict valueForKey:@"FAT_TIP"];
                        
                        if (fatTip == nil || [fatTip isEqualToString:@""]) {
                            fatTip = @"P";
                        }
                        
                        [tempEquip setPaymentType:fatTip];
                    }
                }
                
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0004"])
                    [tempEquip setType:additionalDriver];
                else
                    [tempEquip setType:additionalInsurance];
                
                // GENÇ SÜRÜCÜ full list içinde var, ekrana gösterdiğimiz array de yok
                // GENÇ SÜRÜCÜ eklenince silinmemesi için isRequired = YES
                // GENÇ SÜRÜCÜ 1'den fazla ekleyememesi için MaxQuantity = 1
                if ([[tempEquip materialNumber] isEqualToString:@"HZM0007"])
                {
                    // eski ezervasyonlardan genç sürücü geliyomu kontrolü
                    NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0007"];
                    NSArray *equipmentPredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
                    
                    if (_isYoungDriver || equipmentPredicateArray.count > 0)
                    {
                        [tempEquip setIsRequired:YES];
                        [tempEquip setQuantity:1];
                        [tempEquip setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                        [_additionalEquipments insertObject:tempEquip atIndex:0];
                        [_additionalEquipmentsFullList addObject:tempEquip];
                    }
                    else
                        [_additionalEquipmentsFullList addObject:tempEquip];
                }
                else{
                    [_additionalEquipments addObject:tempEquip];
                    [_additionalEquipmentsFullList addObject:tempEquip];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
        return [NSDictionary dictionaryWithObjectsAndKeys:_additionalEquipments, @"currentList", _additionalEquipmentsFullList, @"fullList", nil];

    }
}
@end
