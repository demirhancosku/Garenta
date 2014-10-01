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

+ (Office*)getClosestOfficeFromList:(NSMutableArray*)officeList withCoordinate:(Coordinate*) lastLocation{
    Office *closestOffice;
    double closestDistance;
    for (Office *tempOffice in officeList) {
        if (closestOffice == nil) {
            closestOffice = tempOffice;
            closestDistance = [Office getDistanceFromOldPointY:lastLocation.coordinate.latitude andOldPointX:lastLocation.coordinate.longitude andNewPointY:[tempOffice.latitude doubleValue] andNewPointX:[tempOffice.longitude doubleValue]];
        }else{
            if (closestDistance > [Office getDistanceFromOldPointY:lastLocation.coordinate.latitude andOldPointX:lastLocation.coordinate.longitude andNewPointY:[tempOffice.latitude doubleValue] andNewPointX:[tempOffice.longitude doubleValue]]) {
                closestDistance = [Office getDistanceFromOldPointY:lastLocation.coordinate.latitude andOldPointX:lastLocation.coordinate.longitude andNewPointY:[tempOffice.latitude doubleValue] andNewPointX:[tempOffice.longitude doubleValue]];
                closestOffice = tempOffice;
            }
        }

    }
    return closestOffice;
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
