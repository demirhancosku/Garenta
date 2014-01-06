//
//  CarGroup.m
//  Garenta
//
//  Created by Alp Keser on 12/28/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "CarGroup.h"

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
                if ( [carToBeCompared.payLaterPrice floatValue]>[tempCar.payLaterPrice floatValue]) {
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
@end
