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
@synthesize groupCode,groupName,imagePath,payNowPrice,payLaterPrice,bodyName,bodyId,fuelId,fuelName,cars,segment,segmentName,transmissonId,transmissonName;

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

+ (NSMutableArray*)getCarGroupsFromServiceResponse:(AvailCarServiceV0*) aServiceResponse withOffices:(NSMutableArray*)offices{
    
    NSMutableArray *availableCarGroups = [NSMutableArray new];
    
    
    Car *tempCar;
    Price *tempPrice;
    CarGroup *tempCarGroup;
    NSPredicate *officeFilter;
    
    NSMutableArray *prices= [[NSMutableArray alloc] init];
    for (ET_FIYATV0 *tempPriceListResult  in aServiceResponse.ET_FIYATSet) {
        tempPrice = [Price new];
        [tempPrice setModelId:tempPriceListResult.ModelId];
        [tempPrice setBrandId:tempPriceListResult.MarkaId];
        [tempPrice setCarGroup:tempPriceListResult.AracGrubu];
        [tempPrice setPayNowPrice:tempPriceListResult.SimdiOdeFiyatTry];
        [tempPrice setPayLaterPrice:tempPriceListResult.SonraOdeFiyatTry];
        [tempPrice setCarSelectPrice:tempPriceListResult.AracSecimFarkTry];
        [tempPrice setDayCount:tempPriceListResult.GunSayisi];
        [prices addObject:tempPrice];
    }
    
    
    for (ET_ARACLISTEV0 *tempAracListe in aServiceResponse.ET_ARACLISTESet) {
        tempCar = [Car new];
        [tempCar setMaterialCode:tempAracListe.Matnr];
        [tempCar setMaterialName:tempAracListe.Maktx];
        [tempCar setBrandId:tempAracListe.MarkaId];
        [tempCar setBrandName:tempAracListe.Marka];
        [tempCar setModelId:tempAracListe.ModelId];
        [tempCar setModelName:tempAracListe.Model];
        [tempCar setModelYear:tempAracListe.ModelYili];
        [tempCar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[CarGroup urlOfResolution:@"400" fromBaseUrl:tempAracListe.Zresim315]]]]];
        //temp: due to dns change no image can be loaded
        if (tempCar.image == nil) {
            [tempCar setImage:[UIImage imageNamed:@"sample_car.png"]];
        }
        [tempCar setDoorNumber:tempAracListe.KapiSayisi];
        [tempCar setPassangerNumber:tempAracListe.YolcuSayisi];
        //TODO: arac subesi buluncak nspredicate class method
        [tempCar setOfficeCode:tempAracListe.Msube];
        tempCarGroup = [CarGroup getGroupFromList:availableCarGroups WithCode:tempAracListe.Grpkod];
        if (tempCarGroup == nil) {
            tempCarGroup = [CarGroup new];
            tempCarGroup.cars = [NSMutableArray new];
            [tempCarGroup setGroupCode:tempAracListe.Grpkod];
            [tempCarGroup setGroupName:tempAracListe.Grpkodtx];
            [tempCarGroup setTransmissonId:tempAracListe.SanzimanTipiId];
            [tempCarGroup setTransmissonName:tempAracListe.SanzimanTipi];
            [tempCarGroup setFuelId:tempAracListe.YakitTipiId];
            [tempCarGroup setFuelName:tempAracListe.YakitTipi];
            [tempCarGroup setBodyId:tempAracListe.KasaTipiId];
            [tempCarGroup setBodyName:tempAracListe.KasaTipi];
            [tempCarGroup setSegment:tempAracListe.Segment];
            [tempCarGroup setSegmentName:tempAracListe.Segmenttx];
            [availableCarGroups addObject:tempCarGroup];
        }
        [tempCar setCarGroup:tempCarGroup];
        [CarGroup setPriceForCar:tempCar withPriceList:prices];
        if ([tempAracListe.Vitrinres isEqualToString:@"X"]) {
            [tempCarGroup setSampleCar:tempCar];
            [tempCarGroup setPayLaterPrice:[NSString stringWithFormat:@"%@",tempCar.pricing.payLaterPrice]];
            [tempCarGroup setPayNowPrice:[NSString stringWithFormat:@"%@",tempCar.pricing.payNowPrice]];
        }
        [tempCarGroup.cars addObject:tempCar];
    }

    return [CarGroup sortCarGroupsPriceAscending:availableCarGroups];;
}

+ (UIImage*)getImageFromJSONResults:(NSDictionary*)pics withPath:(NSString*)aPath{
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
+ (void)setPriceForCar:(Car*)aCar withPriceList:(NSMutableArray*)aPriceList{
    for (Price *tempPrice in aPriceList) {
        if ([[tempPrice modelId] isEqualToString:[aCar modelId]] && [[tempPrice brandId] isEqualToString:[aCar brandId]] && [[tempPrice carGroup] isEqualToString:[[aCar carGroup] groupCode]]) {
            [aCar setPricing:tempPrice];
        }
    }
}

#pragma mark - util methods
- (NSMutableArray*)carGroupOffices{
    NSMutableArray*offices = [NSMutableArray new];
    NSArray *filterResult;
    NSPredicate *officePredicate;
    for (Car *tempCar in self.cars) {
       officePredicate = [NSPredicate predicateWithFormat:@"mainOfficeCode = %@",tempCar.officeCode];
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
@end
