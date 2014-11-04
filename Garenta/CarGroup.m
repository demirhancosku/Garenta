//
//  CarGroup.m
//  Garenta
//
//  Created by Alp Keser on 12/28/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroup.h"
#import "GTMBase64.h"
#import "Price.h"

@implementation CarGroup

@synthesize groupCode,groupName,imagePath,payNowPrice,payLaterPrice,bodyName,bodyId,fuelId,fuelName,cars,segment,segmentName,transmissonId,transmissonName, minAge, minDriverLicense, minYoungDriverAge, minYoungDriverLicense;

+ (CarGroup*)getGroupFromList:(NSMutableArray*)carList WithCode:(NSString*)aGroupCode{
    for (CarGroup*tempCarGroup in carList) {
        if ([tempCarGroup.groupCode isEqualToString:aGroupCode] ) {
            return tempCarGroup;
        }
    }
    return nil;
}

- (Car*)findCarWithOffice:(Office*)anOffice fromList:(NSMutableArray*)aCarList{
    
    for (Car *tempCar in aCarList) {
        if ([tempCar.officeCode isEqualToString:anOffice.mainOfficeCode]) {
            return tempCar;
        }
    }
    
    return nil;
}

+ (NSMutableArray *)getCarGroupsFromServiceResponse:(NSDictionary *)serviceResponse withOffices:(NSMutableArray *)offices {
    
    NSMutableArray *availableCarGroups = [NSMutableArray new];
    
    
    // ET_FIYAT
    NSDictionary *etFiyatArray = [serviceResponse objectForKey:@"ZSD_KDK_FIYATLANDIRMA_FUNC_EXP"];
    
    NSMutableArray *prices= [[NSMutableArray alloc] init];
    
    for (NSDictionary *tempDict in etFiyatArray) {
        Price *tempPrice = [Price new];
        
        [tempPrice setBrandId:[tempDict valueForKey:@"MARKA_ID"]];
        [tempPrice setModelId:[tempDict valueForKey:@"MODEL_ID"]];
        [tempPrice setCarGroup:[tempDict valueForKey:@"ARAC_GRUBU"]];
        [tempPrice setPayNowPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"SIMDI_ODE_FIYAT_TRY"]]];
        [tempPrice setPayLaterPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"SONRA_ODE_FIYAT_TRY"]]];
        [tempPrice setCarSelectPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"ARAC_SECIM_FARK_TRY"]]];
        [tempPrice setDayCount:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"GUN_SAYISI"]]];
        [tempPrice setSalesOffice:[tempDict valueForKey:@"CIKIS_SUBE"]];
        
        [prices addObject:tempPrice];
    }
    
    // ET_ARACLISTE
    NSDictionary *etAracListeArray = [serviceResponse objectForKey:@"ZPM_S_ARACLISTE"];
    
    for (NSDictionary *tempDict in etAracListeArray)
    {
        Car *tempCar = [Car new];
        
        [tempCar setMaterialCode:[tempDict valueForKey:@"MATNR"]];
        [tempCar setMaterialName:[tempDict valueForKey:@"MAKTX"]];
        [tempCar setBrandId:[tempDict valueForKey:@"MARKA_ID"]];
        [tempCar setBrandName:[tempDict valueForKey:@"MARKA"]];
        [tempCar setModelId:[tempDict valueForKey:@"MODEL_ID"]];
        [tempCar setModelName:[tempDict valueForKey:@"MODEL"]];
        [tempCar setModelYear:[tempDict valueForKey:@"MODEL_YILI"]];
        [tempCar setSalesOffice:[tempDict valueForKey:@"MSUBE"]];
        
        NSString *imagePath = [tempDict valueForKey:@"ZRESIM_315"];
        
        [tempCar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]]];

        if (tempCar.image == nil) {
            [tempCar setImage:[UIImage imageNamed:@"sample_car.png"]];
        }
        
        [tempCar setDoorNumber:[tempDict valueForKey:@"KAPI_SAYISI"]];
        [tempCar setPassangerNumber:[tempDict valueForKey:@"YOLCU_SAYISI"]];
        [tempCar setOfficeCode:[tempDict valueForKey:@"ASUBE"]];
        
        CarGroup *tempCarGroup = [CarGroup getGroupFromList:availableCarGroups WithCode:[tempDict valueForKey:@"GRPKOD"]];
        
        if (tempCarGroup == nil)
        {
            tempCarGroup = [CarGroup new];
            tempCarGroup.cars = [NSMutableArray new];
            
            [tempCarGroup setGroupCode:[tempDict valueForKey:@"GRPKOD"]];
            [tempCarGroup setGroupName:[tempDict valueForKey:@"GRPKODTX"]];
            [tempCarGroup setTransmissonId:[tempDict valueForKey:@"SANZIMAN_TIPI_ID"]];
            [tempCarGroup setTransmissonName:[tempDict valueForKey:@"SANZIMAN_TIPI"]];
            [tempCarGroup setFuelId:[tempDict valueForKey:@"YAKIT_TIPI_ID"]];
            [tempCarGroup setFuelName:[tempDict valueForKey:@"YAKIT_TIPI"]];
            [tempCarGroup setBodyId:[tempDict valueForKey:@"KASA_TIPI_ID"]];
            [tempCarGroup setBodyName:[tempDict valueForKey:@"KASA_TIPI"]];
            [tempCarGroup setSegment:[tempDict valueForKey:@"SEGMENT"]];
            [tempCarGroup setSegmentName:[tempDict valueForKey:@"SEGMENTTX"]];
            
            [tempCarGroup setMinAge:[[tempDict valueForKey:@"MIN_YAS"] integerValue]];
            [tempCarGroup setMinDriverLicense:[[tempDict valueForKey:@"MIN_EHLIYET"] integerValue]];
            [tempCarGroup setMinYoungDriverAge:[[tempDict valueForKey:@"GENC_SRC_YAS"] integerValue]];
            [tempCarGroup setMinYoungDriverLicense:[[tempDict valueForKey:@"GENC_SRC_EHL"] integerValue]];
            
            [availableCarGroups addObject:tempCarGroup];
        }
        
        [tempCar setCarGroup:tempCarGroup];
        
        [CarGroup setPriceForCar:tempCar withPriceList:prices];
        
        if ([[tempDict valueForKey:@"VITRINRES"] isEqualToString:@"X"]) {
            [tempCarGroup setSampleCar:tempCar];
            [tempCarGroup setPayLaterPrice:[NSString stringWithFormat:@"%.02f",tempCar.pricing.payLaterPrice.floatValue]];
            [tempCarGroup setPayNowPrice:[NSString stringWithFormat:@"%.02f",tempCar.pricing.payNowPrice.floatValue]];
        }
        
        [tempCarGroup.cars addObject:tempCar];
        
    }

    return [self sortCarGroupsPriceAscending:availableCarGroups];
}

+ (UIImage*)getImageFromJSONResults:(NSDictionary*)pics withPath:(NSString*)aPath {
    UIImage *carImage = [[UIImage alloc] init];
    NSString *picBinaryString;
    NSData *picData;
    //aalpk burda eger resim bulunmuyorsa standart bir resim koymak lazım
    for (NSDictionary *picLine in pics) {
        if ([[picLine objectForKey:@"Path"] isEqualToString:aPath]) {
            picBinaryString = [picLine objectForKey:@"Picturedata"];
            picData =
            [NSData dataWithData:[YAJL_GTMBase64 decodeString:picBinaryString]];
            
            carImage = [UIImage imageWithData:picData];
            
        }
    }
    return carImage;
}

+ (NSString*)urlOfResolution:(NSString*)aResolution fromBaseUrl:(NSString*)baseUrl{
    NSString *finalString;
    @try {
        NSArray *urlParts = [baseUrl componentsSeparatedByString:@"/jato/"];
        finalString = [NSString stringWithFormat:@"%@/jato/%@/%@",[urlParts objectAtIndex:0],aResolution,[urlParts objectAtIndex:1]];
    }
    @catch (NSException *exception) {
        return @"sorry";
    }
    
    return [finalString stringByReplacingOccurrencesOfString: @" " withString:@"%20"];
    
}
//model marka ara grubu belli olmali
+ (void)setPriceForCar:(Car*)aCar withPriceList:(NSMutableArray*)aPriceList {
    
    for (Price *tempPrice in aPriceList) {
        if ([[tempPrice modelId] isEqualToString:[aCar modelId]] && [[tempPrice brandId] isEqualToString:[aCar brandId]] && [[tempPrice carGroup] isEqualToString:[[aCar carGroup] groupCode]] && [[tempPrice salesOffice] isEqualToString:[aCar salesOffice]]) {
            [aCar setPricing:tempPrice];
            break;
        }
    }
}

#pragma mark - util methods
- (NSMutableArray*)carGroupOffices {
    NSMutableArray*offices = [NSMutableArray new];
    NSArray *filterResult;
    NSPredicate *officePredicate;
    for (Car *tempCar in self.cars) {
       officePredicate = [NSPredicate predicateWithFormat:@"subOfficeCode = %@",tempCar.officeCode];
        filterResult = [offices filteredArrayUsingPredicate:officePredicate];
        if ([filterResult count] == 0) {
            [offices addObjectsFromArray:[[ApplicationProperties getOffices] filteredArrayUsingPredicate:officePredicate]];
        }
    }
    return offices;
}

+ (NSMutableArray*)sortCarGroupsPriceAscending:(NSMutableArray*)someCarGroups{
    NSArray *sortedArray;
    sortedArray = [someCarGroups sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        CarGroup *carGroup1 = (CarGroup*)a;
        CarGroup *carGroup2 = (CarGroup*)b;
        
        
        if ([carGroup1.payNowPrice floatValue]<[carGroup2.payNowPrice floatValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }else if([carGroup1.payNowPrice floatValue]>[carGroup2.payNowPrice floatValue]){
            return (NSComparisonResult)NSOrderedDescending;
        }else{
            return (NSComparisonResult)NSOrderedSame;
        }
        
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
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


@end
