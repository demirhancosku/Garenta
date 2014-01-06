//
//  ClassicSearchVC.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//


#import "AppDelegate.h"
#import "Office.h"
#import "OfficeWorkingTime.h"
#import "LoginVC.h"
#import "CalendarTimeVC.h"
#import "OfficeListVC.h"
#import "Destination.h"
#import "Arrival.h"
#import "Reservation.h"
#import "CarGroupScrollVC.h"

@interface ClassicSearchVC : UIViewController <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate, UIPopoverControllerDelegate,CLLocationManagerDelegate>
{
    UITableView *destinationTableView;
    UITableView *arrivalTableView;
    UIButton *searchButton;
    CGRect viewFrame;
    UIDatePicker *datePicker;
    NSMutableArray *officeWorkingSchedule;
    CLLocationManager *locationManager;
    NSMutableData *bigData;
    Reservation *reservation;
    LoaderAnimationVC *loaderVC;
    NSMutableArray *availableCarGroups;
    Coordinate  *lastLocation;
}

@property (nonatomic, retain) UIPopoverController *popOver;
- (id)initWithFrame:(CGRect)frame;

@end
