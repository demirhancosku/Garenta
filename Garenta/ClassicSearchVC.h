//
//  ClassicSearchVC.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import "SearchScreenVC.h"
#import "AppDelegate.h"
#import "Office.h"
#import "OfficeWorkingHour.h"
#import "LoginVC.h"
#import "CalendarTimeVC.h"
#import "OfficeListVC.h"
#import "Destination.h"
#import "Arrival.h"
#import "Reservation.h"
#import "FilterScreenVC.h"

@interface ClassicSearchVC : UIViewController <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate, UIPopoverControllerDelegate>
{
    UITableView *destinationTableView;
    UITableView *arrivalTableView;
    UIButton *searchButton;
    CGRect viewFrame;
    UIDatePicker *datePicker;
    NSMutableArray *officeWorkingSchedule;
    
    Destination *destinationInfo;
    Arrival *arrivalInfo;
    
    Reservation *reservation;
}

@property (nonatomic, retain) UIPopoverController *popOver;
- (id)initWithFrame:(CGRect)frame;

@end
