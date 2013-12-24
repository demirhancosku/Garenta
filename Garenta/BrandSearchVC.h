//
//  BrandSearchVC.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Office.h"
#import "OfficeWorkingHour.h"
#import "LoginVC.h"
#import "CalendarTimeVC.h"
#import "Destination.h"
#import "Arrival.h"
#import "Reservation.h"
#import "CarGroupScrollVC.h"

@interface BrandSearchVC : UIViewController <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate, UIPopoverControllerDelegate>
{
    UITableView *destinationTableView;
    UITableView *arrivalTableView;
    UITableView *brandTableView;
    
    UIButton *searchButton;
    CGRect viewFrame;
    UIDatePicker *datePicker;
    NSMutableArray *officeWorkingSchedule;
    UIPopoverController *popOver;
    
    Destination *destinationInfo;
    Arrival *arrivalInfo;
    
    Reservation *reservation;
    
}

- (id)initWithFrame:(CGRect)frame;

@end
