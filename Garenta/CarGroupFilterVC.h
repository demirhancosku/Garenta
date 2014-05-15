//
//  CarGroupFilterVC.h
//  Garenta
//
//  Created by Ata  Cengiz on 24.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterObject.h"
#import "Reservation.h"
#import "CarGroup.h"
#import "Car.h"
@interface CarGroupFilterVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    
    NSMutableArray *fuelFilter;
    NSMutableArray *segmentFilter;
    NSMutableArray *bodyFilter;
    NSMutableArray *transmissionFilter;
    NSMutableArray *brandFilter;
    
    NSMutableArray *filteredCarGroups;
    


}
@property(strong,nonatomic)Reservation *reservation;
@property(strong,nonatomic)NSMutableArray *carGroups;
-(id)initWithReservation:(Reservation*)aReservation andCarGroup:(NSMutableArray*)aCarGroups;

@end
