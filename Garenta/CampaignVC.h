//
//  CampaignVCTableViewController.h
//  Garenta
//
//  Created by Kerem Balaban on 26.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampaignVC : UITableViewController

@property (strong,nonatomic) CarGroup *carGroup;
//@property (strong,nonatomic) NSMutableArray *campaignIdArray;
@property (strong,nonatomic) NSMutableArray *officeList;
@property (strong,nonatomic) Reservation *reservation;

@end


