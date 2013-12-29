//
//  OfficeListVC.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassicSearchVC.h"
#import "Destination.h"
#import "Arrival.h"
#import "ClassicSearchVC.h"
#import "Reservation.h"

@interface OfficeListVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    UITableView *officeListTable;
    NSMutableArray *officeList;
    NSMutableArray *searchData;
    Destination *destination;
    Arrival *arrival;
    Office *tempOffice;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    Reservation *reservation;
    int tag;
}
- (id)initWithReservation:(Reservation*)aReservation andTag:(int)aTag andOfficeList:(NSMutableArray*) officeList;

@end
