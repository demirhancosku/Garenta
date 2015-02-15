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
#import "WYPopoverController.h"
#import "OfficeSelectionCell.h"
#import "TimeSelectionCell.h"


@interface ClassicSearchVC : UIViewController <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate, UIPopoverControllerDelegate,CLLocationManagerDelegate>
{
    CGRect viewFrame;
    UIDatePicker *datePicker;
    NSMutableArray *offices;
    CLLocationManager *locationManager;
    NSMutableData *bigData;
    NSMutableArray *availableCarGroups;
    CLLocation  *lastLocation;
    int selectedTag;
}

@property (strong,nonatomic) IBOutlet UITableView *destinationTableView;
@property (strong,nonatomic) IBOutlet UITableView *arrivalTableView;
@property (strong,nonatomic) IBOutlet UIButton *searchButton;
@property (strong,nonatomic) WYPopoverController *myPopoverController;
@property (strong,nonatomic) Reservation *reservation;
@property (nonatomic, retain) UIPopoverController *popOver;

- (IBAction)showCarGroup:(id)sender;
- (void)addNotifications;
- (OfficeSelectionCell *)officeSelectTableViewCell:(UITableView *)tableView;
- (TimeSelectionCell *)timeSelectTableViewCell:(UITableView *)tableView;

@end
