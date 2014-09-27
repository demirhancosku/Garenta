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
#import "TKCalendarMonthView.h"
#import "Office.h"
#import "Reservation.h"
#pragma mark - CalendarMonthViewController

@interface CalendarTimeVC : UITableViewController //TKCalendarMonthViewController
{
    NSDate *selectedTime;
    NSDate *tempTime;
    int tag;
}

@property(strong,nonatomic)Reservation *reservation;
- (id)initWithReservation:(Reservation*)aReservation andTag:(int) aTag;
@end