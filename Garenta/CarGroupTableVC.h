//
//  CarGroupTableVC.h
//  Garenta
//
//  Created by Alp Keser on 5/15/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarGroup.h"
#import "CarSelectedProtocol.h"
@interface CarGroupTableVC : UITableViewController

@property(weak,nonatomic)CarGroup *activeCarGroup;
@property(strong,nonatomic)id<CarSelectedProtocol> delegate;
@property (nonatomic) BOOL isMontlyRent;

@end
