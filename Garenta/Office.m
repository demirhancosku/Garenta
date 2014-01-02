//
//  Office.m
//  Garenta
//
//  Created by Ata  Cengiz on 19.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "Office.h"

@implementation Office

@synthesize address, fax, latitude, longitude, region, regionText, subOfficeCode, subOfficeType, tel, workingHours, mainOfficeCode, mainOfficeName, subOfficeName, subOfficeTypeCode, holidayDates;


+ (Office*)getOfficeFrom:(NSMutableArray*)offices withCode:(NSString*)officeCode{
    for (Office *tempOffice in offices) {
        if ([tempOffice.mainOfficeCode isEqualToString:officeCode]) {
            return tempOffice;
        }
    }
    return nil;
    
}
@end
