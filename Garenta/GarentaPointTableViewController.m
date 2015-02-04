//
//  GarentaPointTableViewController.m
//  Garenta
//
//  Created by Ata Cengiz on 02/02/15.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import "GarentaPointTableViewController.h"

@interface GarentaPointTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UISwitch *prioritySwitch, *garentaPointSwitch, *milesAndSmilesSwitch;
@property (weak, nonatomic) UITextField *milesAndSmilesTextField;
@property (weak, nonatomic) UIButton *continueButton;
@end

@implementation GarentaPointTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int numberOfRows = 1;
    
    if (self.showPriority) {
        numberOfRows++;
    }
    if (self.showGarentaPoint) {
        numberOfRows++;
    }
    if (self.showMilesPoint) {
        numberOfRows++;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *aCell;

    NSUInteger row = [indexPath row];
    
    NSUInteger priorityCell = 0;
    NSUInteger garentaCell = 0;
    NSUInteger milesCell = 0;
    NSUInteger continueButton = 1;
    
    if (self.showGarentaPoint) {
        garentaCell++;
        milesCell++;
        continueButton++;
    }
    if (self.showMilesPoint) {
        milesCell++;
        continueButton++;
    }
    
    if (self.showPriority && row == priorityCell) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"PriorityCell" forIndexPath:indexPath];
        self.prioritySwitch = (UISwitch *)[aCell viewWithTag:1];
    }
    if (self.showGarentaPoint && row == garentaCell) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"GarentaPoint" forIndexPath:indexPath];
        self.garentaPointSwitch = (UISwitch *)[aCell viewWithTag:1];
    }
    if (self.showMilesPoint && row == milesCell) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"MilesAndSmilesPoint" forIndexPath:indexPath];
        self.milesAndSmilesSwitch = (UISwitch *)[aCell viewWithTag:1];
        self.milesAndSmilesTextField = (UITextField *)[aCell viewWithTag:2];
    }
    if (row == continueButton) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"ContinueButton" forIndexPath:indexPath];
        self.continueButton = (UIButton *)[aCell viewWithTag:1];
        [self.continueButton addTarget:self action:@selector(continueButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return aCell;
}

- (void)continueButtonPressed:(id)sender {
    
}

@end
