//
//  ReservationSummaryViewController.h
//  Garenta
//
//  Created by Alp Keser on 1/1/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "BaseVC.h"
#import "Reservation.h"
#import "CarGroupViewController.h"
@interface ReservationSummaryViewController : BaseVC<UITableViewDataSource,UITableViewDelegate>{
    CarGroupViewController *carGroupVC;
    Reservation *reservation;
    UITableView*tableView;
}

- (id)initWithReservation:(Reservation*)aReservation;
@end
