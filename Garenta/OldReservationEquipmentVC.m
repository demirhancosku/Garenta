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
#import "OldReservationSummaryVC.h"
#import "AdditionalDriverVC.h"
#import "CarSelectionVC.h"

@interface OldReservationEquipmentVC () <WYPopoverControllerDelegate>

@property (strong,nonatomic)WYPopoverController *myPopoverController;
@property (weak, nonatomic) IBOutlet UITableView *additionalEquipmentsTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTextLabel;
@property BOOL isPayNow;
@end

@implementation OldReservationEquipmentVC

- (void)viewDidLoad {
    
    _carSelectionArray = [NSMutableArray new];
    
    // ŞİMDİ ÖDE-SONRA ÖDE REZERVASYON?
    if ([super.reservation.paymentType isEqualToString:@"1"])
        _isPayNow = YES;
    else
        _isPayNow = NO;
    
    // REZERVASYON YARATILDIĞI ESNADA ARAÇ SEÇİLMİŞSE -YES
    if (super.reservation.selectedCar)
        _isCarSelected = YES;
    else
        _isCarSelected = NO;
    
    [self findOldReservationEquipments];
    [self getCarSelectionPrice];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"carSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [self calculateCarSelectedPrice];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"additionalDriverAdded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [self recalculate];
    }];
}

- (void)calculateCarSelectedPrice
{
    _isCarSelected = YES;
    
    NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
    NSArray *equipmentPredicateArray = [super.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
    
    if ([equipmentPredicateArray count] > 0)
    {
        AdditionalEquipment *temp = [AdditionalEquipment new];
        temp = [equipmentPredicateArray objectAtIndex:0];
        
        [temp setQuantity:1];
        if (_isPayNow)
        {
            if (temp.paid == nil) {
                temp.paid = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            temp.difference = [[temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
        }
    }
    
    [self recalculate];
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
        {
            temp.quantity = [[equipmentPredicateArray objectAtIndex:0] quantity];
            temp.updateStatus = @"U";
        }
    }
    
    [self recalculate];
}

- (void)getCarSelectionPrice
{
    for (Car *tempCar in super.reservation.selectedCarGroup.cars)
    {
        if ([_carSelectionArray count] == 0) {
            [_carSelectionArray addObject:tempCar];
        }
        else {
            BOOL isNewModelId = YES;
            
            for (int i = 0; i < [_carSelectionArray count]; i++) {
                if ([[[_carSelectionArray objectAtIndex:i] modelId] isEqualToString:tempCar.modelId]) {
                    isNewModelId = NO;
                    break;
                }
            }
            
            if (isNewModelId) {
                [_carSelectionArray addObject:tempCar];
            }
        }
    }
    
    [_additionalEquipmentsTableView reloadData];
}

- (void)recalculate{
    float total = 0;
    _changeReservationPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    for (AdditionalEquipment *temp in super.additionalEquipments)
    {
//        if (temp.type == additionalDriver) {
//            [temp setQuantity:self.reservation.additionalDrivers.count + temp.quantity];
//        }
        if (_isPayNow)
            total = total + temp.difference.floatValue;
        else
            total = total + ([temp.price floatValue] * temp.quantity);
    }
    
    if (_isPayNow)
    {
        if (super.reservation.etExpiry.count > 0) {
            total = total + [[[super.reservation.etExpiry objectAtIndex:0] totalPrice] floatValue];
        }
        else{
            total = total + super.reservation.changeReservationDifference.floatValue;
        }
    }
    else
    {
        if (super.reservation.etExpiry.count > 0) {
            total = total + [[[super.reservation.etExpiry objectAtIndex:0] totalPrice] floatValue] + super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice.floatValue;
        }
        else{
            total = total + super.reservation.changeReservationDifference.floatValue + super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice.floatValue;
        }
    }
    
    // ARAÇ SEÇİLMİŞ VE GRUBA REZERVASYONSA
    if (_isCarSelected && [super.reservation.reservationType isEqualToString:@"20"])
        total = total + super.reservation.selectedCar.pricing.carSelectPrice.floatValue;
    // ARAÇ SEÇİLMEMİŞ VE ARACA REZERVASYONDA
    //    else if (!_isCarSelected && [super.reservation.reservationType isEqualToString:@"10"])
    //        total = total - super.reservation.selectedCar.pricing.carSelectPrice.floatValue;
    
    _changeReservationPrice = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",total]];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_totalPriceLabel setText:[NSString stringWithFormat:@"%.02f TL",total]];
        
        if (total < 0) {
            [_totalTextLabel setText:@"İade Tutarı    :"];
        }else{
            if (super.reservation.etExpiry.count > 0) {
                [_totalTextLabel setText:@"1.Taksit Toplam:"];
            }
            else{
                [_totalTextLabel setText:@"Ödenecek Toplam:"];
            }
        }
    });
    
    [_additionalEquipmentsTableView reloadData];
}

#pragma mark - IBActions
- (IBAction)plusButtonPressed:(id)sender
{
    AdditionalEquipment*additionalEquipment = [super.additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
    if (additionalEquipment.type == additionalDriver) {
        
        int newValue = [additionalEquipment quantity] + 1;
        [additionalEquipment setQuantity:newValue];
        
        if (_isPayNow)
        {
            if (additionalEquipment.paid == nil) {
                additionalEquipment.paid = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            additionalEquipment.difference = [[additionalEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
        }
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
        else
        {
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
    if (additionalEquipment.type == additionalDriver && self.reservation.additionalDrivers.count > 0)
    {
        [super deleteAdditionalDriver];
        [self.reservation.additionalDrivers removeLastObject];
    }
    
    int newValue = [additionalEquipment quantity]-1;
    [additionalEquipment setQuantity:newValue];
    
    if (_isPayNow) {
        additionalEquipment.difference = [[additionalEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
    }
//    else
//    {
//        int newValue = [additionalEquipment quantity]-1;
//        [additionalEquipment setQuantity:newValue];
//        
//        if (_isPayNow) {
//            additionalEquipment.difference = [[additionalEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
//        }
//    }
    
    [self recalculate];
}

#pragma mark - tableviews

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return super.additionalEquipments.count + 1;
}

- (SelectCarTableViewCell*)selectCarTableView:(UITableView*)tableView {
    
    SelectCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCarCell"];
    if (!cell) {
        cell = [SelectCarTableViewCell new];
    }
    
    if (_isCarSelected)
    {
        [cell.selectButton setImage:[UIImage imageNamed:@"ticked_button.png"] forState:UIControlStateNormal];
        [cell.selectButton setHidden:NO];
        [[cell carLabel] setText:[NSString stringWithFormat:@"%@",super.reservation.selectedCarGroup.sampleCar.materialName]];
    }
    else
    {
        [cell.selectButton setImage:[UIImage imageNamed:@"unticked_button.png"] forState:UIControlStateNormal];
        [cell.selectButton setHidden:YES];
        
        if ([_carSelectionArray count] == 0)
            [[cell carLabel] setText:@""];
        else
        {
            Car *car = [_carSelectionArray objectAtIndex:0];
            [[cell carLabel] setText:[NSString stringWithFormat:@"Sadece %.02f TL ödeyerek aracınızı seçebilirsiniz.",[car.pricing.carSelectPrice floatValue]]];
        }
    }
    
    //ÖDEME YAPILMIŞSA
    if (_isPayNow)
    {
        [cell.priceLabel setText:[NSString stringWithFormat:@"%.02f",[super.reservation.selectedCarGroup.sampleCar.pricing.payNowPrice floatValue]]];
        
        //GRUBA REZERVASYON VE ARAÇ SEÇİLİ İSE
        if ([super.reservation.reservationType isEqualToString:@"20"] && _isCarSelected)
        {
            //AYLIKTA İLK TASKİDİ GÖSTERİYORUZ
            if (super.reservation.etExpiry.count > 0)
                [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",(super.reservation.changeReservationDifference.floatValue + [[[super.reservation.etExpiry objectAtIndex:0] totalPrice] floatValue])]];
            else
                [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",(super.reservation.changeReservationDifference.floatValue + super.reservation.selectedCar.pricing.carSelectPrice.floatValue)]];
        }
        else
        {
            if (super.reservation.etExpiry.count > 0)
                [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",([[[super.reservation.etExpiry objectAtIndex:0] totalPrice] floatValue] - [super.reservation.selectedCarGroup.sampleCar.pricing.payNowPrice floatValue])]];
            else
                [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",super.reservation.changeReservationDifference.floatValue]];
        }
    }
    else
    {
        [cell.priceLabel setText:@"0.00"];
        //GRUBA REZERVASYON VE ARAÇ SEÇİLİ İSE
        if ([super.reservation.reservationType isEqualToString:@"20"] && _isCarSelected)
        {
            [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",(super.reservation.changeReservationDifference.floatValue + super.reservation.selectedCar.pricing.carSelectPrice.floatValue + super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice.floatValue)]];
        }
        else
        {
            [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",[[super.reservation.changeReservationDifference decimalNumberByAdding:super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice] floatValue]]];
        }
    }
    
    return cell;
}

- (AdditionalEquipmentTableViewCell*)additionalEquipmentTableViewCellForIndex:(int)index fromTable:(UITableView*)tableView
{
    AdditionalEquipmentTableViewCell *cell = [super additionalEquipmentTableViewCellForIndex:index fromTable:tableView];
    
    AdditionalEquipment *temp = [ super.additionalEquipments objectAtIndex:index];
    
    //ŞİMDİ ÖDE REZ İSE "Ödenmiş" ve "Ödenecek" tutarları ayrı ayrı yazıyoruz, değilse ödenmiş tutar 0 oluyor
    if (_isPayNow)
    {
        cell.itemTotalPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",temp.paid.floatValue];
        cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",temp.difference.floatValue];
    }
    else
    {
        cell.itemTotalPriceLabel.text = @"0.00";
        if ([temp.materialNumber isEqualToString:@"HZM0031"])
        {
            if (!_isCarSelected)
                cell.equipmentPriceLabel.text = @"0.00";
            else
                cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",super.reservation.selectedCar.pricing.carSelectPrice.floatValue];
        }
        else
            cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",(temp.price.floatValue * temp.quantity)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0)
    {
        if (!_isCarSelected) {
            [self performSegueWithIdentifier:@"toCarSelectionVCSegue" sender:self];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Onay" message:
                                  [NSString stringWithFormat:@"%@ %@ modeli rezervasyonunuzdan çıkarmak istediğinize emin misiniz?",super.reservation.selectedCar.brandName,super.reservation.selectedCar.modelName]	 delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles: @"Evet",nil];
            [alert show];
        }
    }
}

#pragma mark - uialertview methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //NO
            break;
        case 1:
        {
            //YES
            NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
            NSArray *equipmentPredicateArray = [super.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
            
            if ([equipmentPredicateArray count] > 0)
            {
                AdditionalEquipment *temp = [AdditionalEquipment new];
                temp = [equipmentPredicateArray objectAtIndex:0];
                [temp setQuantity:0];
                if (_isPayNow) {
                    temp.difference = [[temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
                }
            }
            
            _isCarSelected = NO;
            [self recalculate];
            break;
        }
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!_isCarSelected)
        super.reservation.selectedCar = nil;
    
    if ([[segue identifier] isEqualToString:@"toCarSelectionVCSegue"]) {
        [(CarSelectionVC*)  [segue destinationViewController] setReservation:super.reservation];
        [(CarSelectionVC*)  [segue destinationViewController] setCarSelectionArray:_carSelectionArray];
    }
    
    if ([[segue identifier] isEqualToString:@"toAdditionalDriverVCSegue"])
        
    {
        [(AdditionalDriverVC*)segue.destinationViewController setReservation:self.reservation];
        for (AdditionalEquipment *tempEquipment in self.additionalEquipments) {
            if (tempEquipment.type == additionalDriver) {
                [(AdditionalDriverVC*)segue.destinationViewController setMyDriver:tempEquipment];
                [(AdditionalDriverVC*)segue.destinationViewController setReservation:self.reservation];
                break;
            }
        }
    }
    
    else if ([[segue identifier] isEqualToString:@"toEquipmentInfoSegue"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(280, 75);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        AdditionalEquipment *tempEquipment = [self.additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
        [(AdditionalEquipmentInfoVC *)segue.destinationViewController setInfoText:tempEquipment.materialInfo];
        
        self.myPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        self.myPopoverController.delegate = self;
        
    }
    else if ([segue.identifier isEqualToString:@"toOldReservationSummarySegue"])
    {
        [self prepareEquipmentForUpdate];
        [(OldReservationSummaryVC *)[segue destinationViewController] setReservation:super.reservation];
        [(OldReservationSummaryVC *)[segue destinationViewController] setChangeReservationPrice:_changeReservationPrice];
    }
}

- (void)prepareEquipmentForUpdate
{
    for (AdditionalEquipment *temp in super.additionalEquipments)
    {
        NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",temp.materialNumber];
        NSArray *equipmentPredicateArray = [super.reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
        
        if ([equipmentPredicateArray count] > 0)
        {
            if ([temp quantity] == 0)
            {
                [[equipmentPredicateArray objectAtIndex:0] setUpdateStatus:@"D"];
                for (int count = 1; count < [[equipmentPredicateArray objectAtIndex:0] quantity]; count++)
                {
                    temp.updateStatus = @"D";
                    [super.reservation.additionalEquipments addObject:temp];
                }
            }
            else
            {
                if (temp.quantity > [[equipmentPredicateArray objectAtIndex:0] quantity])
                {
                    [[equipmentPredicateArray objectAtIndex:0] setUpdateStatus:@"U"];
                    [[equipmentPredicateArray objectAtIndex:0] setPrice:temp.price];
                    
                    for (int count = 1; count < [temp quantity]; count++)
                    {
                        AdditionalEquipment *tempObj = [AdditionalEquipment new];
                        tempObj = [temp copy];
                        
                        if (count < [[equipmentPredicateArray objectAtIndex:0] quantity])
                            [tempObj setUpdateStatus:@"U"];
                        else
                            [tempObj setUpdateStatus:@"I"];
                        
                        [super.reservation.additionalEquipments addObject:tempObj];
                    }
                }
                else if (temp.quantity < [[equipmentPredicateArray objectAtIndex:0] quantity])
                {
                    [[equipmentPredicateArray objectAtIndex:0] setUpdateStatus:@"U"];
                    [[equipmentPredicateArray objectAtIndex:0] setPrice:temp.price];
                    
                    for (int count = 1; count < [[equipmentPredicateArray objectAtIndex:0] quantity]; count++)
                    {
                        AdditionalEquipment *tempObj = [AdditionalEquipment new];
                        tempObj = [temp copy];
                        
                        if (count < [temp quantity])
                            [tempObj setUpdateStatus:@"U"];
                        else
                            [tempObj setUpdateStatus:@"D"];
                        
                        [super.reservation.additionalEquipments addObject:tempObj];
                    }
                }
                else
                {
                    [[equipmentPredicateArray objectAtIndex:0] setUpdateStatus:@"U"];
                    [[equipmentPredicateArray objectAtIndex:0] setPrice:temp.price];
                    
                    for (int count = 1; count < temp.quantity; count++)
                    {
                        temp.updateStatus = @"U";
                        [super.reservation.additionalEquipments addObject:temp];
                    }
                }
            }
        }
        else
        {
            if (temp.quantity > 0)
            {
                for (int count = 0; count < temp.quantity; count++) {
                    temp.updateStatus = @"I";
                    [super.reservation.additionalEquipments addObject:temp];
                }
            }
        }
    }
}

@end
