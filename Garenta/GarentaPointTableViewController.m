//
//  GarentaPointTableViewController.m
//  Garenta
//
//  Created by Ata Cengiz on 02/02/15.
//  Copyright (c) 2015 Kerem Balaban. All rights reserved.
//

#import "GarentaPointTableViewController.h"
#import "AgreementsVC.h"
#import "ReservationSummaryVC.h"

@interface GarentaPointTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISwitch *prioritySwitch, *garentaPointSwitch, *milesAndSmilesSwitch;
@property (strong, nonatomic) UITextField *milesAndSmilesTextField, *corporateReceiptNumberTextField;
@property (strong, nonatomic) UIButton *continueButton, *priorityInformationButton;
@property (nonatomic) BOOL showPriority, showGarentaPoint, showMilesPoint, showCorparateNumber;
@end

@implementation GarentaPointTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (([[ApplicationProperties getUser] isLoggedIn] && ![[ApplicationProperties getUser] isPriority]) || ![[ApplicationProperties getUser] isLoggedIn]) {
        [self setShowPriority:YES];
    }
    
    if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
        [self setShowCorparateNumber:YES];
    }
    
    if (self.reservation.selectedCarGroup.sampleCar.pricing.canGarentaPointEarn) {
        [self setShowGarentaPoint:YES];
    }
    
    if (self.reservation.selectedCarGroup.sampleCar.pricing.canMilesPointEarn) {
        [self setShowMilesPoint:YES];
    }
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
    if (self.showCorparateNumber) {
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
    NSUInteger continueButton = 0;
    NSUInteger corpateCell = 0;
    
    if (self.showPriority) {
        garentaCell++;
        milesCell++;
        continueButton++;
        corpateCell++;
    }
    if (self.showGarentaPoint) {
        milesCell++;
        continueButton++;
        corpateCell++;
    }
    if (self.showMilesPoint) {
        continueButton++;
        corpateCell++;
    }
    if (self.showCorparateNumber) {
        continueButton++;
    }
    
    if (self.showPriority && row == priorityCell) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"PriorityCell" forIndexPath:indexPath];
        self.prioritySwitch = (UISwitch *)[aCell viewWithTag:1];
        self.priorityInformationButton = (UIButton *)[aCell viewWithTag:2];
        [self.priorityInformationButton addTarget:self action:@selector(informationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.showGarentaPoint && row == garentaCell) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"GarentaPoint" forIndexPath:indexPath];
        self.garentaPointSwitch = (UISwitch *)[aCell viewWithTag:1];
        [self.garentaPointSwitch addTarget:self action:@selector(garentaPointSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
        
        self.garentaPointSwitch.on = YES;
        
        if (!self.showMilesPoint) {
            self.garentaPointSwitch.userInteractionEnabled = NO;
        }
    }
    if (self.showMilesPoint && row == milesCell) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"MilesAndSmilesPoint" forIndexPath:indexPath];
        self.milesAndSmilesSwitch = (UISwitch *)[aCell viewWithTag:1];
        [self.milesAndSmilesSwitch addTarget:self action:@selector(milesPointSwitchValueChange:) forControlEvents:UIControlEventValueChanged];

        self.milesAndSmilesTextField = (UITextField *)[aCell viewWithTag:2];
        
        if (!self.showGarentaPoint) {
            self.milesAndSmilesSwitch.on = YES;
            self.milesAndSmilesSwitch.userInteractionEnabled = NO;
        }
    }
    if (self.showCorparateNumber && row == corpateCell) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"CorporateReceiptNoCell" forIndexPath:indexPath];
        self.milesAndSmilesTextField = (UITextField *)[aCell viewWithTag:1];

    }
    if (row == continueButton) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"ContinueButton" forIndexPath:indexPath];
        self.continueButton = (UIButton *)[aCell viewWithTag:1];
        [self.continueButton addTarget:self action:@selector(continueButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return aCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    NSUInteger priorityCell = 0;
    NSUInteger garentaCell = 0;
    NSUInteger milesCell = 0;
    NSUInteger continueButton = 0;
    NSUInteger corpateCell = 0;
    
    if (self.showPriority) {
        garentaCell++;
        milesCell++;
        continueButton++;
        corpateCell++;
    }
    if (self.showGarentaPoint) {
        milesCell++;
        continueButton++;
        corpateCell++;
    }
    if (self.showMilesPoint) {
        continueButton++;
        corpateCell++;
    }
    if (self.showCorparateNumber) {
        continueButton++;
    }
    
    if ((self.showMilesPoint && row == milesCell) || (self.showCorparateNumber && row == corpateCell)) {
        return 90;
    }
    else if(row == continueButton) {
        return 45;
    }
    else {
        return 54;
    }
}

- (void)informationButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ToAgreementSegue" sender:self];
}

- (void)continueButtonPressed:(id)sender {
    
    if (self.showMilesPoint && self.milesAndSmilesSwitch.on) {
        if (self.milesAndSmilesTextField.text == nil || [self.milesAndSmilesTextField.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Mil kazanmak için lütfen TK numaranızı giriniz" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    [self performSegueWithIdentifier:@"ToReservationSummarySegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ToAgreementSegue"]) {
        [(AgreementsVC*)[segue destinationViewController] setHtmlName:@"PriorityRules"];
        [(AgreementsVC*)[segue destinationViewController] setAgreementName:@"Priority Kart Ayrıcalıkları"];
    }
    if ([segue.identifier isEqualToString:@"ToReservationSummarySegue"]) {
        if (self.prioritySwitch.on) {
            self.reservation.becomePriority = YES;
        }
        if (self.garentaPointSwitch.on) {
            self.reservation.gainGarentaTL = YES;
        }
        if (self.milesAndSmilesSwitch.on) {
            self.reservation.gainMiles = YES;
            self.reservation.tkNumber = self.milesAndSmilesTextField.text;
        }
        if (self.showCorparateNumber) {
            self.reservation.corporateReceiptNumber = self.corporateReceiptNumberTextField.text;
        }
        
        [(ReservationSummaryVC *)[segue destinationViewController] setReservation:self.reservation];
    }
}

- (void)garentaPointSwitchValueChange:(id)sender {
    
    UISwitch *tempSwitch = (UISwitch *)sender;
    
    if (tempSwitch.on) {
        self.milesAndSmilesSwitch.on = NO;
    }
    else {
        self.milesAndSmilesSwitch.on = YES;
        tempSwitch.on = NO;
    }
}

- (void)milesPointSwitchValueChange:(id)sender {
    
    UISwitch *tempSwitch = (UISwitch *)sender;
    
    if (tempSwitch.on) {
        self.garentaPointSwitch.on = NO;
    }
    else {
        self.garentaPointSwitch.on = YES;
        tempSwitch.on = NO;
    }
}

@end
