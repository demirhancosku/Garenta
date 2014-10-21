//
//  Reservation.m
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "Reservation.h"
#import "AdditionalEquipment.h"
@implementation Reservation
@synthesize  checkOutTime,checkInTime,checkInOffice,checkOutOffice, selectedCarGroup,number;

-(id)init{
    self = [super init];
    checkOutTime= [Reservation defaultCheckOutDate];
    checkInTime = [Reservation defaultCheckInDate];
    _selectedCar = nil;
    return self;
}


#pragma mark - util methods
    //sıkıcı nsdate kodları
+ (NSDate*)defaultCheckInDate{
    NSDate *checkInDate = [NSDate date];

    //once 2 saat 15 dk ekliyoruz
    NSTimeInterval aTimeInterval = 135 * 60; //2 saat 15 dk
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

+ (NSDate*)defaultCheckOutDate
{
    NSDate *checkOutDate = [NSDate date];
    //once 15 dk ekliyoruz
    NSTimeInterval aTimeInterval = 135 * 60; //15 dk
    checkOutDate = [checkOutDate dateByAddingTimeInterval:aTimeInterval];

    //sonra dakikaları bir ger dilime
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                        fromDate:checkOutDate];
    NSInteger difference = components.minute % 15;
    checkOutDate = [checkOutDate dateByAddingTimeInterval:-(NSTimeInterval)difference*60];
    
    return checkOutDate;
}
#pragma mark - reservation pricing methods
-(NSDecimalNumber*)totalPriceWithCurrency:(NSString*)currency isPayNow:(BOOL)isPayNow andGarentaTl:(NSString *)garentaTl
{
    float totalPrice = 0.00f;
    if ([currency isEqualToString:@"TRY"])
    {
        if (isPayNow) {
            totalPrice = totalPrice + [selectedCarGroup.sampleCar.pricing.payNowPrice floatValue] - garentaTl.floatValue;
        }else{
            totalPrice = totalPrice + [selectedCarGroup.sampleCar.pricing.payLaterPrice floatValue];
        }
        if (_selectedCar) {
            totalPrice = totalPrice + [_selectedCar.pricing.carSelectPrice floatValue];
        }
        
        for (AdditionalEquipment *tempEquipment in _additionalEquipments) {
            if (tempEquipment.quantity >0) {
                totalPrice = totalPrice + (tempEquipment.quantity * [tempEquipment.price floatValue]);
            }
        }
        
    }
    
    return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",totalPrice]];

}

-(NSDecimalNumber*)priceOfAdditionalEquipments{
    float totalValue = 0.0f;
    if (_additionalEquipments != nil) {
        for (AdditionalEquipment *tempEquipment in _additionalEquipments) {
            totalValue = totalValue + ( tempEquipment.quantity * [tempEquipment.price floatValue]);
        }
    }
    return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f.02",totalValue]];
}


@end
