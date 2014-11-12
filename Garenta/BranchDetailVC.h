//
//  BranchDetailVC.h
//  Garenta
//
//  Created by Onur Küçük on 29.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Office.h"
#import "BranchInfoCell.h"
#import "BranchMapCell.h"
#import "OfficeHolidayTime.h"
#import <CoreLocation/CoreLocation.h>
@interface BranchDetailVC : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource,UITableViewDelegate>
{
    int numberOfWorkingDay;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property(nonatomic, strong)Office *selectedOffice;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSArray *officeHours;
@property (nonatomic, strong)NSArray *holidayDatesArray;

@end
