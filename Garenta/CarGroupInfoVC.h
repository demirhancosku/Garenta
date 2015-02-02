//
//  CarGroupInfoVC.h
//  Garenta
//
//  Created by Kerem Balaban on 26.01.2015.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarGroupInfoVC : UIViewController

@property (strong,nonatomic)IBOutlet UILabel *minimumInfo;
@property (strong,nonatomic)IBOutlet UILabel *youngInfo;
@property (strong,nonatomic)IBOutlet UILabel *dailyDepositInfo;
@property (strong,nonatomic)IBOutlet UILabel *creditCardInfo;
@property (strong,nonatomic)IBOutlet UILabel *monthlyDepositInfo;
@property (strong,nonatomic) CarGroup *carGroup;

@end
