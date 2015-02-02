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
#import "CarSelectedProtocol.h"
#import "CarGroupViewController.h"
#import "WYStoryboardPopoverSegue.h"

@interface CarGroupManagerViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate,CarSelectedProtocol,WYPopoverControllerDelegate>{

    NSMutableArray *groupVCs;
    CarGroup *activeCarGroup;
    WYPopoverController* popoverController;
}

@property (strong,nonatomic) NSMutableArray *additionalEquipments;
@property (strong,nonatomic) NSMutableArray *additionalEquipmentsFullList;
@property BOOL isYoungDriver;

@property(nonatomic,strong)NSMutableArray *carGroups;
@property(nonatomic,strong)Reservation *reservation;
@property (strong, nonatomic) UIPageViewController *pageViewController;
- (id)initWithCarGroups:(NSMutableArray*)someCarGroups andReservartion:(Reservation*)aReservation;
- (void)carGroupSelected:(CarGroup*)aCarGroup withOffice:(Office*)anOffice;
@end
