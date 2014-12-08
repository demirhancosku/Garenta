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

+ (NSMutableArray *)getOfficesFromSAP {
    
    NSMutableArray *offices = [NSMutableArray new];

    @try {
        
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZMOB_KDK_GET_SUBE_CALISMA_SAAT"];
        
        NSDictionary *resultDict = [handler prepCall];
        
        if (resultDict != nil) {
            NSDictionary *resultTables = [resultDict objectForKey:@"EXPORT"];
            
            NSDictionary *officeInformation = [resultTables objectForKey:@"EXPT_SUBE_BILGILERI"];
            NSDictionary *officeInformationArray = [officeInformation objectForKey:@"ZMOB_TT_SUBE_MASTER"];
            
            NSDictionary *officeWorkingHours = [resultTables objectForKey:@"EXPT_CALISMA_ZAMANI"];
            NSDictionary *officeWorkingHoursArray = [officeWorkingHours objectForKey:@"ZMOB_TT_SUBE_CALSAAT"];
            
            NSDictionary *officeHolidays = [resultTables objectForKey:@"EXPT_TATIL_ZAMANI"];
            NSDictionary *officeHolidayArray = [officeHolidays objectForKey:@"ZMOB_TT_SUBE_TATIL"];
            
            for (NSDictionary *tempDict in officeInformationArray) {
                // Aktif olmayan şubeleri almıyoruz
                if (![[tempDict valueForKey:@"AKTIFSUBE"] isEqualToString:@"X"]) {
                    continue;
                }
                
                Office *tempOffice = [[Office alloc] init];
                [tempOffice setMainOfficeCode:[tempDict valueForKey:@"MERKEZ_SUBE"]];
                [tempOffice setMainOfficeName:[tempDict valueForKey:@"MERKEZ_SUBETX"]];
                [tempOffice setSubOfficeCode:[tempDict valueForKey:@"ALT_SUBE"]];
                [tempOffice setSubOfficeName:[tempDict valueForKey:@"ALT_SUBETX"]];
                [tempOffice setSubOfficeType:[tempDict valueForKey:@"ALT_SUBETIPTX"]];
                [tempOffice setSubOfficeTypeCode:[tempDict valueForKey:@"ALT_SUBETIP"]];
                [tempOffice setCityCode:[tempDict valueForKey:@"SEHIR"]];
                [tempOffice setCityName:[tempDict valueForKey:@"SEHIRTX"]];
                [tempOffice setAddress:[tempDict valueForKey:@"ADRES"]];
                [tempOffice setTel:[tempDict valueForKey:@"TEL"]];
                [tempOffice setFax:[tempDict valueForKey:@"FAX"]];
                [tempOffice setLongitude:[tempDict valueForKey:@"XKORD"]];
                [tempOffice setLatitude:[tempDict valueForKey:@"YKORD"]];
                
                
                NSMutableArray *workingHoursArray = [NSMutableArray new];
                
                for (NSDictionary *tempWorkHourDict in officeWorkingHoursArray) {
                    if ([[tempWorkHourDict valueForKey:@"MERKEZ_SUBE"] isEqualToString:[tempOffice mainOfficeCode]]) {
                        OfficeWorkingTime *tempTime = [[OfficeWorkingTime alloc] init];
                        tempTime.startTime = [tempWorkHourDict valueForKey:@"BEGTI"];
                        tempTime.endingHour = [tempWorkHourDict valueForKey:@"ENDTI"];
                        tempTime.weekDayCode = [tempWorkHourDict valueForKey:@"CADAY"];
                        tempTime.weekDayName = [tempWorkHourDict valueForKey:@"CADAYTX"];
                        tempTime.subOffice = [tempWorkHourDict valueForKey:@"ALT_SUBE"];
                        tempTime.mainOffice = [tempWorkHourDict valueForKey:@"MERKEZ_SUBE"];
                        
                        [workingHoursArray addObject:tempTime];
                    }
                }
                
                [tempOffice setWorkingDates:[workingHoursArray copy]];
                
                NSMutableArray *holidayArray = [NSMutableArray new];
                
                for (NSDictionary *tempHolidayDict in officeHolidayArray) {
                    if ([[tempHolidayDict valueForKey:@"MERKEZ_SUBE"] isEqualToString:[tempOffice mainOfficeCode]]) {
                        OfficeHolidayTime *tempTime = [[OfficeHolidayTime alloc] init];
                        tempTime.startTime = [tempHolidayDict valueForKey:@"BEGTI"];
                        tempTime.endingHour = [tempHolidayDict valueForKey:@"ENDTI"];
                        tempTime.holidayDate = [tempHolidayDict valueForKey:@"BEGDA"];
                        tempTime.subOffice = [tempHolidayDict valueForKey:@"ALT_SUBE"];
                        tempTime.mainOffice = [tempHolidayDict valueForKey:@"MERKEZ_SUBE"];
                        
                        [holidayArray addObject:tempTime];
                    }
                }
                
                [tempOffice setHolidayDates:[holidayArray copy]];
                
                [offices addObject:tempOffice];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
    
    [ApplicationProperties setOffices:offices];
    return offices;
}

@end
