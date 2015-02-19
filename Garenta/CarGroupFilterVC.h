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
    UITableView *tableVC;
    
    UIButton *clearButton;
    UIButton *searchButton;
    
    NSMutableArray *fuelFilter;
    NSMutableArray *segmentFilter;
    NSMutableArray *bodyFilter;
    NSMutableArray *transmissionFilter;
    NSMutableArray *brandFilter;
    NSMutableArray *modelFilter;
    NSMutableArray *modelYearFilter;
    NSMutableArray *colorFilter;
    NSMutableArray *engineVolumeFilter;
    NSMutableArray *horsePowerFilter;
    
    NSMutableArray *filteredCarGroups;
}

@property(strong,nonatomic)Reservation *reservation;
@property(strong,nonatomic)NSMutableArray *carGroups;
@property(strong,nonatomic)NSMutableArray *tempCarGroup;
-(id)initWithReservation:(Reservation*)aReservation andCarGroup:(NSMutableArray*)aCarGroups;

@end
