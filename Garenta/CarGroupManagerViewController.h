//
//  CarGroupManagerViewController.h
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "Car.h"
#import "CarGroupViewController.h"
@interface CarGroupManagerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate>{
    Reservation *reservation;
    NSMutableArray *carGroups;
    UITableView *tableView;
    UIPageViewController *groupPageVC;
    NSMutableArray *groupVCs;
    CarGroup *activeCarGroup;
}
- (id)initWithCarGroups:(NSMutableArray*)someCarGroups andReservartion:(Reservation*)aReservation;
@end
