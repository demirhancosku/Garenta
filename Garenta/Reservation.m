//
//  Reservation.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "Reservation.h"

@implementation Reservation
@synthesize  checkOutTime,checkOutDay,checkInTime,checkInDay,checkInOffice,checkOutOffice, selectedCarGroup,number;

-(id)init{
    self = [super init];
    checkInDay= [Reservation defaultCheckInDate];
    checkOutDay= [Reservation defaultCheckOutDate];
    checkOutTime= [Reservation defaultCheckOutDate];
    checkInTime = [Reservation defaultCheckInDate];
    return self;
}


#pragma mark - util methods
    //sıkıcı nsdate kodları
+ (NSDate*)defaultCheckInDate{
    NSDate *checkInDate = [NSDate date];


    //once 15 dk ekliyoruz
    NSTimeInterval aTimeInterval = 15 * 60; //15 dk
    checkInDate = [checkInDate dateByAddingTimeInterval:aTimeInterval];
    //sonra 1gun ekliyoruz
    aTimeInterval = 24 * 60 * 60;
    checkInDate = [checkInDate dateByAddingTimeInterval:aTimeInterval];
    //sonra dakikaları 0lıyoruz.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                         fromDate:checkInDate];
    NSInteger difference = components.minute % 15;
    checkInDate = [checkInDate dateByAddingTimeInterval:-(NSTimeInterval)difference*60];
    return checkInDate;
}

+ (NSDate*)defaultCheckOutDate{
    NSDate *checkOutDate = [NSDate date];
    //once 15 dk ekliyoruz
    NSTimeInterval aTimeInterval = 15 * 60; //15 dk
    checkOutDate = [checkOutDate dateByAddingTimeInterval:aTimeInterval];
    //sonra dakikaları bir ger dilime
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                        fromDate:checkOutDate];
    NSInteger difference = components.minute % 15;
    checkOutDate = [checkOutDate dateByAddingTimeInterval:-(NSTimeInterval)difference*60];
    
    return checkOutDate;
}
@end
