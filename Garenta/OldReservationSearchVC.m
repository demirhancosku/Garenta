//
//  OldReservationSearchVC.m
//  Garenta
//
//  Created by Kerem Balaban on 21.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationSearchVC.h"

#define kCheckOutTag 0
#define kCheckInTag 1

@interface OldReservationSearchVC ()

@end

@implementation OldReservationSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (OfficeSelectionCell *)officeSelectTableViewCell:(UITableView *)tableView
//{
//    OfficeSelectionCell *cell = [super officeSelectTableViewCell:tableView];
//    
//    if (tableView.tag == kCheckOutTag)
//    {
//        [[cell officeLabel] setTextColor:[UIColor lightGrayColor]];
//        [cell setAccessoryType:UITableViewCellAccessoryNone];
//    }
//    
//    return cell;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end