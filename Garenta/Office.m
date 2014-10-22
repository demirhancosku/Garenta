//
//  Office.m
//  Garenta
//
//  Created by Ata  Cengiz on 19.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "Office.h"

@implementation Office

@synthesize address, fax, latitude, longitude, cityCode, cityName, subOfficeCode, subOfficeType, tel, mainOfficeCode, mainOfficeName, subOfficeName, subOfficeTypeCode;


+ (Office*)getOfficeFrom:(NSMutableArray*)offices withCode:(NSString*)officeCode{
    for (Office *tempOffice in offices) {
        if ([tempOffice.subOfficeCode isEqualToString:officeCode]) {
            return tempOffice;
        }
    }
    return nil;
    
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

+ (double)getDistanceFromOldPointY:(double)old_lat andOldPointX:(double)old_lon andNewPointY:(double) new_lat andNewPointX:(double) new_lon{
    const int R =     6371;
    double dLat = (new_lat - old_lat) * (M_PI/180);
    double dLon = (new_lon - old_lon) * (M_PI/180);
    old_lat = old_lat * (M_PI/180);
    new_lat = new_lat * (M_PI/180);
    double a = pow(sin(new_lat - old_lat), 2) + cos(new_lat)*cos(old_lat)*pow(sin(new_lon - old_lon), 2);
    
    a= pow(sin(dLat/2), 2) + cos(old_lat)*cos(new_lat)*pow(sin(dLon/2), 2);
    
    double b = 2 * a * pow(tan(2*(sqrt(a)-sqrt(1 - a))), 2);
    b = 2*atan2(sqrt(a),sqrt((1-a)));
    double c = R * b;
    
    
    return c*1000;
}
@end
