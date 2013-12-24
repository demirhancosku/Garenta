//
//  CarGroupFilterVC.h
//  Garenta
//
//  Created by Ata  Cengiz on 24.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterObject.h"

@interface CarGroupFilterVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    
    NSMutableArray *fuelType;
    NSMutableArray *categoryType;
    NSMutableArray *bodyType;
    NSMutableArray *gearboxType;
    NSMutableArray *brandType;
}

@end
