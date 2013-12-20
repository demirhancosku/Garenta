//
//  MainVC.h
//  Garenta
//
//  Created by Kerem Balaban on 27.11.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Office.h"
#import "OfficeWorkingHour.h"
#import "LoginVC.h"

@interface LocationSelectionScreenVC : UIViewController <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate>
{
    UITableView *destinationTableView;
    UITableView *arrivalTableView;
    UIButton *searchButton;
    CGRect viewFrame;
    UIDatePicker *datePicker;
    NSMutableArray *officeWorkingSchedule;
    
}

- (id)initWithFrame:(CGRect)frame;
@end
