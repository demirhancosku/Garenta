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
   //trans
    Car *tempCar;
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
    }
    //tans
    NSMutableArray *carGroups = [[NSMutableArray alloc] init];
    NSError *err;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:nil options:NSJSONReadingMutableContainers error:&err];
    
    NSDictionary *result = [jsonDict objectForKey:@"d"];
    //parsing
    NSDictionary *carList = [result objectForKey:@"ET_ARACLISTESet"];
    NSDictionary *priceList = [result objectForKey:@"ET_FIYATSet"];
    
    NSDictionary *carListResult = [carList objectForKey:@"results"];
    NSDictionary *priceListResult = [priceList objectForKey:@"results"];
    
    //parse pricelist first
    NSMutableArray *prices= [[NSMutableArray alloc] init];
    Price *tempPrice;
    for (NSDictionary*tempPriceListResult  in priceListResult) {
        tempPrice = [[Price alloc] init];
        [tempPrice setModelId:[tempPriceListResult objectForKey:@"ModelId"]];
        [tempPrice setBrandId:[tempPriceListResult objectForKey:@"MarkaId"]];
        [tempPrice setCarGroup:[tempPriceListResult objectForKey:@"AracGrubu"]];
        [tempPrice setPayNowPrice:[tempPriceListResult objectForKey:@"SimdiOdeFiyatTry"]];
        [tempPrice setPayLaterPrice:[tempPriceListResult objectForKey:@"SonraOdeFiyatTry"]];
        [tempPrice setCarSelectPrice:[tempPriceListResult objectForKey:@"AracSecimFarkTry"]];
        [prices addObject:tempPrice];
    }
    
    
    //car segment yapisi onemli kodlar
    //her ofisin bir segment-grup-araba hiyerarsisi var
    
    
//    Car *tempCar;
    
    CarGroup *tempCarGroup;
    Office *tempOffice;
    NSMutableArray *availableCarGroups = [[NSMutableArray alloc] init];
    for (NSDictionary *tempCarResult in carListResult){
        
        tempCar = [[Car alloc] init];
        [tempCar setMaterialCode:[tempCarResult objectForKey:@"Matnr"]];
        [tempCar setMaterialName:[tempCarResult objectForKey:@"Maktx"]];
        [tempCar setBrandId:[tempCarResult objectForKey:@"MarkaId"]];
        [tempCar setBrandName:[tempCarResult objectForKey:@"Marka"]];
        [tempCar setModelId:[tempCarResult objectForKey:@"ModelId"]];
        [tempCar setModelName:[tempCarResult objectForKey:@"Model"]];
        [tempCar setModelYear:[tempCarResult objectForKey:@"ModelYili"]];
        [tempCar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[CarGroup urlOfResolution:@"400" fromBaseUrl:[tempCarResult objectForKey:@"Zresim315"]]]]]];
        //aalpk burasi duzelcek importu aliorz export boscunku
        [tempCar setCurrency:[tempCarResult objectForKey:@"ImppWaers"]];
        [tempCar setOffice:[Office getOfficeFrom:offices withCode:[tempCarResult objectForKey:@"Msube"]]];
        //eger o grup yoksa daha
        tempCarGroup = [CarGroup getGroupFromList:availableCarGroups WithCode:[tempCarResult objectForKey:@"Grpkod"]];
        if ( tempCarGroup== nil) {
            //grup yarat
            //TODO: aalpk devam et gruba
            tempCarGroup = [[CarGroup alloc] init];
            tempCarGroup.cars = [[NSMutableArray alloc] init];
            [tempCarGroup setGroupCode:[tempCarResult objectForKey:@"Grpkod"]];
            [tempCarGroup setGroupName:[tempCarResult objectForKey:@"Grpkodtx"]];
            [tempCarGroup setTransmissonId:[tempCarResult objectForKey:@"SanzimanTipiId"]];
            [tempCarGroup setTransmissonName:[tempCarResult objectForKey:@"SanzimanTipi"]];
            [tempCarGroup setFuelId:[tempCarResult objectForKey:@"YakitTipiId"]];
            [tempCarGroup setFuelName:[tempCarResult objectForKey:@"YakitTipi"]];
            [tempCarGroup setBodyId:[tempCarResult objectForKey:@"KasaTipiId"]];
            [tempCarGroup setBodyName:[tempCarResult objectForKey:@"KasaTipi"]];
            [tempCarGroup setSegment:[tempCarResult objectForKey:@"Segment"]];
            [tempCarGroup setSegmentName:[tempCarResult objectForKey:@"Segmenttx"]];
            [availableCarGroups addObject:tempCarGroup];
        }
        [tempCar setCarGroup:tempCarGroup];
        [CarGroup setPriceForCar:tempCar withPriceList:prices];
        
        if ([[tempCarResult objectForKey:@"Vitrinres"] isEqualToString:@"X"]) {
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
