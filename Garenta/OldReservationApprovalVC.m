//
//  OldReservationApprovalVC.m
//  Garenta
//
//  Created by Kerem Balaban on 28.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationApprovalVC.h"

@interface OldReservationApprovalVC ()

@end

@implementation OldReservationApprovalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    // Do any additional setup after loading the view.
    
    if (super.reservation.isContract) {
        self.title = @"Sözleşme Onayı";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnToMenu:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reservationUpdated" object:nil];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
