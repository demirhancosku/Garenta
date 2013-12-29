//
//  CarGroupViewController.h
//  Garenta
//
//  Created by Alp Keser on 12/27/13.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarGroup.h"
#import "Car.h"
@interface CarGroupViewController : UIViewController
@property (nonatomic,assign) int index;
@property (nonatomic,retain) CarGroup *carGroup;
@property (nonatomic,retain) UIPageViewController *myBoss;

- (id)initWithFrame:(UIPageViewController*)aBoss andCarGroups:(CarGroup*)aCarGroup;
@end
