//
//  Office.m
//  Garenta
//
//  Created by Ata  Cengiz on 19.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "Office.h"

@implementation Office

@synthesize address, fax, latitude, longitude, region, regionText, subOfficeCode, subOfficeType, tel, workingHours, mainOfficeCode, mainOfficeName, subOfficeName, subOfficeTypeCode, holidayDates,carSegmentList;
- (CarSegment*)getCarSegmentWithCode:(NSString*)segmentCode{
    for (CarSegment *tempCarSegment in carSegmentList) {
        if ([tempCarSegment.segment isEqualToString:segmentCode]) {
            return tempCarSegment;
        }
    }
    
    return nil;
}


@end
