//
//  CalendarTimeVC.h
//  Garenta
//
//  Created by Kerem Balaban on 20.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapkuLibrary.h"
#import "Destination.h"
#import "Arrival.h"

#pragma mark - CalendarMonthViewController
@interface CalendarTimeVC : TKCalendarMonthViewController
{
    UISlider *mySlider;
    UITextField *sliderText;
    NSMutableArray *officeList;
    Destination *destination;
    Arrival *arrival;
    NSDate *selectedDate;
}

- (id)initWithOfficeList:(NSMutableArray *)office andDest:(Destination *)dest;
- (id)initWithOfficeList:(NSMutableArray *)office andArr:(Arrival *)arr;
@end