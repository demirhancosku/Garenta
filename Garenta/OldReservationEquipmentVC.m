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
#import "OldReservationGarentaPointTableVC.h"
#import "AdditionalDriverVC.h"
#import "CarSelectionVC.h"
#import "ETExpiryObject.h"

@interface OldReservationEquipmentVC () <WYPopoverControllerDelegate>

@property (strong,nonatomic)WYPopoverController *myPopoverController;
@property (weak, nonatomic) IBOutlet UITableView *additionalEquipmentsTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTextLabel;
@property BOOL isPayNow;
@end

@implementation OldReservationEquipmentVC

- (void)viewDidLoad {
    
    super.carSelectionArray = [NSMutableArray new];
    
    // ŞİMDİ ÖDE-SONRA ÖDE REZERVASYON?
    if ([super.reservation.paymentType isEqualToString:@"2"] || [super.reservation.paymentType isEqualToString:@"6"])
        _isPayNow = NO;
    else
        _isPayNow = YES;
    
    // REZERVASYON YARATILDIĞI ESNADA ARAÇ SEÇİLMİŞSE -YES
    if (super.reservation.selectedCar)
        _isCarSelected = YES;
    else
        _isCarSelected = NO;
    
    [self findOldReservationEquipments];
    [self getCarSelectionPrice];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"carSelected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [self checkWinterTyre];
        [self calculateCarSelectedPrice];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"additionalDriverAdded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        [self addYoungDriver];
        [self recalculate];
    }];
}

- (void)addYoungDriver
{
    NSPredicate *youngDriverPredicate = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0007"];
    NSPredicate *maxSecure = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0012"];
    
    AdditionalEquipment *temp = self.reservation.additionalDrivers.lastObject;
    
    // eklenen ek sürücü için genç sürücü gereklimi
    if (temp.isAdditionalYoungDriver)
    {
        NSArray *filterResult;
        filterResult = [super.additionalEquipments filteredArrayUsingPredicate:youngDriverPredicate];
        
        // eğer daha önce bir "genç sürücü" eklendiyse, ek sürücüden kaynaklı "genç sürücü" için 1 arttırılır
        if (filterResult.count > 0)
        {
            AdditionalEquipment *tempEqui = [filterResult objectAtIndex:0];
            [tempEqui setQuantity:tempEqui.quantity + 1];
            [tempEqui setMaxQuantity:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",tempEqui.quantity]]];
        }
        // eğer daha önce "genç sürücü" eklenmediyse, ek sürücüden dolayı "genç sürücü" hizmeti eklenir.
        else
        {
            NSArray *youngDriverFilter;
            NSArray *maxSecureFilter;
            youngDriverFilter = [super.additionalEquipmentsFullList filteredArrayUsingPredicate:youngDriverPredicate];
            maxSecureFilter = [super.additionalEquipments filteredArrayUsingPredicate:maxSecure];
            
            if (youngDriverFilter.count > 0)
            {
                AdditionalEquipment *tempYoungDriverEqui = [youngDriverFilter objectAtIndex:0];
                AdditionalEquipment *tempSecureEqui = [maxSecureFilter objectAtIndex:0];
                
                // eğer daha önce max.güvence himeti eklenmediyse 1 eklenir
                if (tempSecureEqui.quantity == 0)
                {
                    [super.additionalEquipments removeObject:tempSecureEqui];
                    
                    tempSecureEqui.quantity = 1;
                    tempSecureEqui.isRequired = YES;
                    [super.additionalEquipments insertObject:tempSecureEqui atIndex:0];
                }
                else if (tempSecureEqui.quantity > 0 && !tempSecureEqui.isRequired)
                {
                    [super.additionalEquipments removeObject:tempSecureEqui];
                    tempSecureEqui.isRequired = YES;
                    [super.additionalEquipments insertObject:tempSecureEqui atIndex:0];
                }
                
                [tempYoungDriverEqui setIsRequired:YES];
                [tempYoungDriverEqui setQuantity:1];
                [tempYoungDriverEqui setMaxQuantity:[NSDecimalNumber decimalNumberWithString:@"1"]];
                [super.additionalEquipments insertObject:tempYoungDriverEqui atIndex:0];
                
                [self showAlertForYoungDriver];
            }
        }
    }
}

- (void)showAlertForYoungDriver
{
    NSArray *filterResult;
    NSPredicate *youngDriverPredicate;
    youngDriverPredicate = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0007"];
    filterResult = [super.additionalEquipments filteredArrayUsingPredicate:youngDriverPredicate];
    
    if (filterResult.count > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Genç sürücü seçtiğiniz için maksimum güvence hizmeti de eklenmiştir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)checkWinterTyre
{
    if ([super.reservation.selectedCar.winterTire isEqualToString:@"X"])
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0014"];
        NSArray *filterArray = [super.additionalEquipments filteredArrayUsingPredicate:predicate];
        
        if (filterArray.count > 0) {
            [[filterArray objectAtIndex:0] setQuantity:1];
            [[filterArray objectAtIndex:0] setIsRequired:YES];
        }
    }
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
            
            if (super.reservation.etExpiry.count > 0) {
                temp.difference = [[temp.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
            }
            else{
                temp.difference = [[temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
            }
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
        if ([super.carSelectionArray count] == 0) {
            [super.carSelectionArray addObject:tempCar];
        }
        else {
            BOOL isNewModelId = YES;
            
            for (int i = 0; i < [super.carSelectionArray count]; i++) {
                if ([[[super.carSelectionArray objectAtIndex:i] modelId] isEqualToString:tempCar.modelId]) {
                    isNewModelId = NO;
                    break;
                }
            }
            
            if (isNewModelId) {
                [super.carSelectionArray addObject:tempCar];
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
        if (_isPayNow)
            total = total + temp.difference.floatValue;
        else
            if (super.reservation.etExpiry.count > 0) {
                total = total + ([temp.monthlyPrice floatValue] * temp.quantity);
            }else{
                total = total + ([temp.price floatValue] * temp.quantity);
            }
    }
    
    if (_isPayNow)
    {
        total = total + super.reservation.changeReservationDifference.floatValue;
    }
    else
    {
        if (super.reservation.etExpiry.count > 0) {
            for (ETExpiryObject *tempObj in super.reservation.etExpiry) {
                if (![tempObj.carGroup isEqualToString:@""]) {
                    total = total + [[tempObj totalPrice] floatValue] + super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice.floatValue;
                    
                    break;
                }
            }
        }
        else{
            total = total + super.reservation.changeReservationDifference.floatValue + super.reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice.floatValue;
        }
    }
    
    // ARAÇ SEÇİLMİŞ VE GRUBA REZERVASYONSA
    if (_isCarSelected && [super.reservation.reservationType isEqualToString:@"20"])
        total = total + super.reservation.selectedCar.pricing.carSelectPrice.floatValue;
    
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
    AdditionalEquipment *additionalEquipment = [super.additionalEquipments objectAtIndex:[(UIButton*)sender tag]];
    if (additionalEquipment.type == additionalDriver) {
        
        int newValue = [additionalEquipment quantity] + 1;
        [additionalEquipment setQuantity:newValue];
        
        if (_isPayNow)
        {
            if (additionalEquipment.paid == nil) {
                additionalEquipment.paid = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            
            if (super.reservation.etExpiry.count > 0 || additionalEquipment.monthlyPrice.floatValue > 0) {
                additionalEquipment.difference = [[additionalEquipment.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
            }else{
                additionalEquipment.difference = [[additionalEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
            }
        }
        [self performSegueWithIdentifier:@"toAdditionalDriverVCSegue" sender:sender];
    }
    else
    {
        if ([[additionalEquipment materialNumber] isEqualToString:@"HZM0012"]) {
            
            for (AdditionalEquipment *temp in super.additionalEquipments) {
                if (([[temp materialNumber] isEqualToString:@"HZM0011"] || [[temp materialNumber] isEqualToString:@"HZM0024"] || [[temp materialNumber] isEqualToString:@"HZM0009"] || [[temp materialNumber] isEqualToString:@"HZM0006"]) && [temp quantity] == 1) {
                    [temp setQuantity:0];
                    if (_isPayNow) {
                        
                        if (super.reservation.etExpiry.count > 0 || temp.monthlyPrice.floatValue > 0) {
                            temp.difference = [[temp.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
                        }
                        else{
                            temp.difference = [[temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
                        }
                    }
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
            
            if (super.reservation.etExpiry.count > 0 || additionalEquipment.monthlyPrice.floatValue > 0) {
                additionalEquipment.difference = [[additionalEquipment.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
            }else{
                additionalEquipment.difference = [[additionalEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
            }
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
        
        if (super.reservation.etExpiry.count > 0) {
            additionalEquipment.difference = [[additionalEquipment.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
        }else{
            additionalEquipment.difference = [[additionalEquipment.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",additionalEquipment.quantity]]] decimalNumberBySubtracting:additionalEquipment.paid];
        }
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
    
    cell.priceLabel.text = @"0.00 TL";
    cell.carPayLaterLabel.text = @"0.00 TL";
    
    if (_isCarSelected)
    {
        [cell.selectButton setImage:[UIImage imageNamed:@"ticked_button.png"] forState:UIControlStateNormal];
        [cell.selectButton setHidden:NO];
        
        // 13.02.2015 Ata Cengiz
        if (super.reservation.isContract) {
            [[cell carLabel] setText:[NSString stringWithFormat:@"%@ %@",super.reservation.selectedCar.brandName, super.reservation.selectedCar.modelName]];
        }
        else {
            [[cell carLabel] setText:[NSString stringWithFormat:@"%@ %@ - %@",super.reservation.selectedCar.brandName, super.reservation.selectedCar.modelName,super.reservation.selectedCar.colorName]];
        }
        // 13.02.2015 Ata Cengiz
    }
    else
    {
        [cell.selectButton setImage:[UIImage imageNamed:@"unticked_button.png"] forState:UIControlStateNormal];
        [cell.selectButton setHidden:YES];
        
        if ([super.carSelectionArray count] == 0)
            [[cell carLabel] setText:@""];
        else
        {
            Car *car = [super.carSelectionArray objectAtIndex:0];
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
            {
                for (ETExpiryObject *tempObj in super.reservation.etExpiry) {
                    if (![tempObj.carGroup isEqualToString:@""]) {
                        [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",(super.reservation.changeReservationDifference.floatValue + [[tempObj totalPrice] floatValue])]];
                        
                        break;
                    }
                }
            }
            else
                [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",(super.reservation.changeReservationDifference.floatValue + super.reservation.selectedCar.pricing.carSelectPrice.floatValue)]];
        }
        else
        {
            if (super.reservation.etExpiry.count > 0){
                for (ETExpiryObject *tempObj in super.reservation.etExpiry) {
                    if (![tempObj.carGroup isEqualToString:@""]) {
                        [[cell carPayLaterLabel] setText:[NSString stringWithFormat:@"%.02f",([[tempObj totalPrice] floatValue] - [super.reservation.selectedCarGroup.sampleCar.pricing.payNowPrice floatValue])]];
                        
                        break;
                    }
                }
            }
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
                if (super.reservation.etExpiry.count > 0) {
                    cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",(temp.monthlyPrice.floatValue * temp.quantity)];
                }else{
                    cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",(temp.price.floatValue * temp.quantity)];
                }
        }
        else
            if (super.reservation.etExpiry.count > 0) {
                cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",(temp.monthlyPrice.floatValue * temp.quantity)];
            }else{
                cell.equipmentPriceLabel.text = [NSString stringWithFormat:@"%.02f TL",(temp.price.floatValue * temp.quantity)];
            }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0 && !super.reservation.isContract)
    {
        if (!_isCarSelected) {
            [self performSegueWithIdentifier:@"toCarSelectionVCSegue" sender:self];
        }else{
            if (super.reservation.campaignObject.campaignScopeType != vehicleModelCampaign ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Onay" message:
                                      [NSString stringWithFormat:@"%@ %@ modeli rezervasyonunuzdan çıkarmak istediğinize emin misiniz?",super.reservation.selectedCar.brandName,super.reservation.selectedCar.modelName]	 delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles: @"Evet",nil];
                [alert show];
            }
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
                    if (super.reservation.etExpiry.count > 0) {
                        temp.difference = [[temp.monthlyPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
                    }else{
                        temp.difference = [[temp.price decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",temp.quantity]]] decimalNumberBySubtracting:temp.paid];
                    }
                    
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
        [(CarSelectionVC*)  [segue destinationViewController] setCarSelectionArray:super.carSelectionArray];
    }
    
    if ([[segue identifier] isEqualToString:@"toAdditionalDriverVCSegue"])
        
    {
        [(AdditionalDriverVC*)segue.destinationViewController setReservation:self.reservation];
        for (AdditionalEquipment *tempEquipment in self.additionalEquipments) {
            if (tempEquipment.type == additionalDriver) {
                [(AdditionalDriverVC*)segue.destinationViewController setMyDriver:tempEquipment];
                [(AdditionalDriverVC*)segue.destinationViewController setReservation:self.reservation];
                [(AdditionalDriverVC*)segue.destinationViewController setAdditionalEquipments:super.additionalEquipments];
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
    else if ([segue.identifier isEqualToString:@"toOldReservationGarentaPointSegue"]) {
        
        if (super.reservation.isContract) {
            for (AdditionalEquipment *tempEquip in super.reservation.additionalEquipments) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"materialNumber=%@", tempEquip.materialNumber];
                NSArray *predicateResult = [self.additionalEquipments filteredArrayUsingPredicate:predicate];
                
                if (predicateResult.count > 0) {
                    AdditionalEquipment *equipment = (AdditionalEquipment *)predicateResult[0];
                    tempEquip.difference = equipment.difference;
                }
            }
        }
        else {
            [self prepareEquipmentForUpdate];
        }
        
        [(OldReservationGarentaPointTableVC *)[segue destinationViewController] setReservation:super.reservation];
        
        // Ata Cengiz 09.02.2015
        if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
            [(OldReservationGarentaPointTableVC *)[segue destinationViewController] setChangeReservationPrice:[super.reservation totalPriceWithCurrency:@"TRY" isPayNow:NO andGarentaTl:@"0" andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:YES andReservation:super.reservation]];
        }
        else {
            [(OldReservationGarentaPointTableVC *)[segue destinationViewController] setChangeReservationPrice:_changeReservationPrice];
        }
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
                    [[equipmentPredicateArray objectAtIndex:0] setMonthlyPrice:temp.monthlyPrice];
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
                    [[equipmentPredicateArray objectAtIndex:0] setMonthlyPrice:temp.monthlyPrice];
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
                    [[equipmentPredicateArray objectAtIndex:0] setMonthlyPrice:temp.monthlyPrice];
                    
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
