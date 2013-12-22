//
//  LocationSearchVC.h
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
#import <CoreLocation/CoreLocation.h>
#import "Coordinate.h"
#import "Destination.h"
#import "Arrival.h"
#import "Reservation.h"
#import "FilterScreenVC.h"

@interface LocationSearchVC : UIViewController <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate, CLLocationManagerDelegate, UIPopoverControllerDelegate>
{
    UITableView *destinationTableView;
    UITableView *arrivalTableView;
    UIButton *searchButton;
    CGRect viewFrame;
    UIDatePicker *datePicker;
    NSMutableArray *officeWorkingSchedule;
    UIPopoverController *popOver;
    CLLocationManager *locationManager;
    
    Destination *destinationInfo;
    Arrival *arrivalInfo;
    
    Reservation *reservation;
    
}

- (id)initWithFrame:(CGRect)frame;

@end
