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

//+ (NSMutableArray*)sortCarGroupsBy:(NSString*)aParameter{
//    if (aParameter isEqualToString@"Sonra") {
//        <#statements#>
//    }
//}
- (NSMutableArray*)getBestCarsWithFilter:(NSString*)aFilter{
    //fiyata gore sirali bu grupraki her
    NSMutableArray *bestCarList =[[NSMutableArray alloc] init];
    //dunyanin en cirkin kodu devam buralar hep elden gecicek aalpk
    Car* carToBeCompared;
    if ([aFilter isEqualToString:@"Fiyat"]) {
        
        for (Car *tempCar in cars) {
            carToBeCompared = [self findCarWithOffice:tempCar.office fromList:bestCarList];
            if (carToBeCompared == nil ) {
                [bestCarList addObject:tempCar];
            }else{
                if ( [carToBeCompared.pricing.payLaterPrice floatValue]>[tempCar.pricing.payLaterPrice floatValue]) {
                    [bestCarList removeObject:carToBeCompared];
                    [bestCarList addObject:tempCar];
                    
                }
            }
            
        }
    }
    return bestCarList;
}

- (Car*)findCarWithOffice:(Office*)anOffice fromList:(NSMutableArray*)aCarList{
    
    for (Car *tempCar in aCarList) {
        if ([tempCar.office.mainOfficeCode isEqualToString:anOffice.mainOfficeCode]) {
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
    
    
    NSMutableArray *prices= [[NSMutableArray alloc] init];
    for (ET_FIYATV0 *tempPriceListResult  in aServiceResponse.ET_FIYATSet) {
        tempPrice = [Price new];
        [tempPrice setModelId:tempPriceListResult.ModelId];
        [tempPrice setBrandId:tempPriceListResult.MarkaId];
        [tempPrice setCarGroup:tempPriceListResult.AracGrubu];
        [tempPrice setPayNowPrice:tempPriceListResult.SimdiOdeFiyatTry];
        [tempPrice setPayLaterPrice:tempPriceListResult.SonraOdeFiyatTry];
        [tempPrice setCarSelectPrice:tempPriceListResult.AracSecimFarkTry];
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
//        [tempCar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[CarGroup urlOfResolution:@"400" fromBaseUrl:tempAracListe.Zresim315]]]]];
        //TODO: arac subesi buluncak nspredicate class method
//         tempCar setOffice:tempAracListe.Msube
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
        }
        [tempCarGroup.cars addObject:tempCar];
    }
    return availableCarGroups;
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
    
    return [finalString stringByReplacingOccurrencesOfString: @" " withString:@"%20"];;
    
}
//model marka ara grubu belli olmali
+ (void)setPriceForCar:(Car*)aCar withPriceList:(NSMutableArray*)aPriceList{
    for (Price *tempPrice in aPriceList) {
        if ([[tempPrice modelId] isEqualToString:[aCar modelId]] && [[tempPrice brandId] isEqualToString:[aCar brandId]] && [[tempPrice carGroup] isEqualToString:[[aCar carGroup] groupCode]]) {
            [aCar setPricing:tempPrice];
        }
    }
}


@end
