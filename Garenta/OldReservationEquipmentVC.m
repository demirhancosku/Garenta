//
//  OldReservationEquipmentVC.m
//  Garenta
//
//  Created by Kerem Balaban on 22.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationEquipmentVC.h"
#import "AdditionalEquipment.h"
#import "ReservationSummaryVC.h"

@interface OldReservationEquipmentVC ()

@property (weak, nonatomic) IBOutlet UITableView *additionalEquipmentsTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property BOOL isPayNow;
@end

@implementation OldReservationEquipmentVC

- (void)viewDidLoad {
    
    if ([super.reservation.paymentType isEqualToString:@"1"])
        _isPayNow = YES;
    else
        _isPayNow = NO;
    
    [self findOldReservationEquipments];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"additionalDriverAdded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [self recalculate];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)findOldReservationEquipments
{
    for (AdditionalEquipment *temp in super.additionalEquipments)
    {
        NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",temp.materialNumber];
        NSArray *equipmentPredicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
        
        if ([equipmentPredicateArray count] > 0)
            temp.quantity = [[equipmentPredicateArray objectAtIndex:0] quantity];
    }
    
    [self recalculate];
}

- (void)recalculate{
    [_additionalEquipmentsTableView reloadData];
    float total = 0;
    _changeReservationPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    for (AdditionalEquipment *temp in super.additionalEquipments)
    {
        if (temp.type == additionalDriver) {
            [temp setQuantity:self.reservation.additionalDrivers.count + temp.quantity];
        }
        if (_isPayNow)
            total = total + temp.difference.floatValue;
        else
            total = total + ([temp.price floatValue] * temp.quantity);
    }
    if (_isPayNow)
        total = total + super.reservation.changeReservationDifference.floatValue;
    else
        total = total + super.reservation.changeReservationDifference.floatValue + super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice.floatValue;
    
    _changeReservationPrice = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",total]];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_totalPriceLabel setText:[NSString stringWithFormat:@"%.02f",total]];
    });
}

#pragma mark - IBActions
- (IBAction)plusButtonPressed:(id)sender
{
    AdditionalEquipment*additionalEquipment = [super.additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
    if (additionalEquipment.type == additionalDriver) {
        [self performSegueWithIdentifier:@"toAdditionalDriverVCSegue" sender:sender];
    }
    else
    {
        if ([[additionalEquipment materialNumber] isEqualToString:@"HZM0012"]) {
            
            for (AdditionalEquipment *temp in super.additionalEquipments) {
                if (([[temp materialNumber] isEqualToString:@"HZM0011"] || [[temp materialNumber] isEqualToString:@"HZM0024"] || [[temp materialNumber] isEqualToString:@"HZM0009"] || [[temp materialNumber] isEqualToString:@"HZM0006"]) && [temp quantity] == 1) {
                    [temp setQuantity:0];
                }
            }
        }
        else {
            BOOL isMaximumSafetyAdded = NO;
            
            for (AdditionalEquipment *temp in super.additionalEquipments) {
                if ([[temp materialNumber] isEqualToString:@"HZM0012"] && [temp quantity] == 1) {
                    isMaximumSafetyAdded = YES;
                }
            }
            
            if (isMaximumSafetyAdded) {
                if ([[additionalEquipment materialNumber] isEqualToString:@"HZM0011"] || [[additionalEquipment materialNumber] isEqualToString:@"HZM0024"] || [[additionalEquipment materialNumber] isEqualToString:@"HZM0009"] || [[additionalEquipment materialNumber] isEqualToString:@"HZM0006"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Eklemiş olduğunuz maksimum güvence bu hizmeti kapsamaktadır" delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
        }
        
        int newValue = [additionalEquipment quantity] + 1;
        [additionalEquipment setQuantity:newValue];
        
        if (_isPayNow)
        {
            if (additionalEquipment.paid == nil) {
                additionalEquipment.paid = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            additionalEquipment.difference = [[additionalEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
        }
        
        [self recalculate];
    }
}

- (IBAction)minusButtonPressed:(id)sender {
    
    AdditionalEquipment*additionalEquipment = [super.additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
    if (additionalEquipment.type ==additionalDriver && self.reservation.additionalDrivers.count > 0)
    {
        [super deleteAdditionalDriver];
        [self.reservation.additionalDrivers removeLastObject];
    }
    else
    {
        if (_isPayNow) {
            NSDecimalNumber *itemPrice = [additionalEquipment.paid decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]];
            
            additionalEquipment.difference = [itemPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
        }
        
        int newValue = [additionalEquipment quantity]-1;
        [additionalEquipment setQuantity:newValue];
        

    }
    
    [self recalculate];
}

#pragma mark - tableviews

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return super.additionalEquipments.count;
}

- (SelectCarTableViewCell*)selectCarTableView:(UITableView*)tableView {
    
    SelectCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCarCell"];
    if (!cell) {
        cell = [SelectCarTableViewCell new];
    }
    
    [cell.selectButton setImage:[UIImage imageNamed:@"ticked_button.png"] forState:UIControlStateNormal];
    [cell.selectButton setHidden:NO];
    
    if (_isPayNow)
    {
        [cell.priceLabel setText:[NSString stringWithFormat:@"%.02f",[super.reservation.selectedCarGroup.sampleCar.pricing.payNowPrice floatValue]]];
        [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",super.reservation.changeReservationDifference.floatValue]];
    }
    else
    {
        [cell.priceLabel setText:@"0.00"];
        [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",[[super.reservation.changeReservationDifference decimalNumberByAdding:super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice] floatValue]]];
    }

    [[cell carLabel] setText:[NSString stringWithFormat:@"%@ ve benzeri",super.reservation.selectedCarGroup.sampleCar.materialName]];

    return cell;
}

- (AdditionalEquipmentTableViewCell*)additionalEquipmentTableViewCellForIndex:(int)index fromTable:(UITableView*)tableView
{
    AdditionalEquipmentTableViewCell *cell = [super additionalEquipmentTableViewCellForIndex:index fromTable:tableView];
    
    AdditionalEquipment *temp = [super.additionalEquipments objectAtIndex:index];
    
    //ŞİMDİ ÖDE REZ İSE "Ödenmiş" ve "Ödenecek" tutarları ayrı ayrı yazıyoruz, değilse ödenmiş tutar 0 oluyor
    if (_isPayNow)
    {
        cell.itemTotalPriceLabel.text = [NSString stringWithFormat:@"%.02f",temp.paid.floatValue];
        cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f",temp.difference.floatValue];
    }
    else
    {
        cell.itemTotalPriceLabel.text = @"0.00";
        cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f",(temp.quantity*temp.price.floatValue)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"toReservationSummaryVCSegue"])
    {
        [(ReservationSummaryVC *)[segue destinationViewController] setReservation:super.reservation];
        [(ReservationSummaryVC *)[segue destinationViewController] setChangeReservationPrice:_changeReservationPrice];
    }
}

@end
