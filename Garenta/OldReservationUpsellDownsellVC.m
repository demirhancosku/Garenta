//
//  OldReservationUpsellDownsellVCViewController.m
//  Garenta
//
//  Created by Kerem Balaban on 6.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationUpsellDownsellVC.h"
#import "OldReservationSummaryVC.h"
#import "UpsellDownsellCarSelectionVC.h"
#import "AdditionalEquipment.h"

@interface OldReservationUpsellDownsellVC ()

@property (strong,nonatomic) IBOutlet UISegmentedControl *upsellDownsellSegment;
@property (strong,nonatomic) IBOutlet UITableView *tableVC;


- (IBAction)changeSegmentValue:(id)sender;
@end

@implementation OldReservationUpsellDownsellVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _downsellList = [NSMutableArray new];
    _upsellList = [NSMutableArray new];
    
    for (CarGroup *tempGroup in _reservation.upsellList) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupCode==%@",tempGroup.groupCode];
        NSArray *arr = [_upsellList filteredArrayUsingPredicate:predicate];
        
        if (arr.count == 0 && tempGroup.sampleCar.isForShown) {
            [_upsellList addObject:tempGroup];
        }
    }
    
    for (CarGroup *tempGroup in _reservation.downsellList)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupCode==%@",tempGroup.groupCode];
        NSArray *arr = [_downsellList filteredArrayUsingPredicate:predicate];
        
        if (arr.count == 0 && tempGroup.sampleCar.isForShown) {
            [_downsellList addObject:tempGroup];
        }
    }
    
    if (_reservation.downsellList.count == 0)
        [_upsellDownsellSegment setEnabled:NO forSegmentAtIndex:1];
    else if (_downsellList.count == 0)
    {
        [_upsellDownsellSegment setEnabled:NO forSegmentAtIndex:0];
        [_upsellDownsellSegment setSelectedSegmentIndex:1];
    }
}

- (IBAction)changeSegmentValue:(id)sender
{
    [_tableVC reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_upsellDownsellSegment selectedSegmentIndex] == 0)
        return _upsellList.count;
    else
        return _downsellList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIImageView *carImage;
    UILabel *segmentLabel;
    UILabel *modelNameLabel;
    UILabel *payNowLabel;
    UILabel *payLaterLabel;
    UILabel *fuelLabel;
    UILabel *transmissionLabel;
    UILabel *passangerLabel;
    UILabel *doorNumberLabel;
    
    NSMutableArray *copyArray = [NSMutableArray new];
    
    if ([_upsellDownsellSegment selectedSegmentIndex] == 0)
        copyArray = [_upsellList copy];
    else
        copyArray = [_downsellList copy];
    
    CarGroup *temp = [copyArray objectAtIndex:indexPath.row];
    
    NSDecimalNumber *payNowDifference = [temp.sampleCar.pricing.payNowPrice decimalNumberBySubtracting:temp.sampleCar.pricing.documentCarPrice];
    
    NSDecimalNumber *payLaterDifference = [temp.sampleCar.pricing.payLaterPrice decimalNumberBySubtracting:temp.sampleCar.pricing.documentCarPrice];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upsellDownsellCell"];
    
    carImage = (UIImageView*)[cell viewWithTag:1];
    [carImage setImage:temp.sampleCar.image];
    
    modelNameLabel = (UILabel*)[cell viewWithTag:2];
    [modelNameLabel setText:temp.sampleCar.materialName];
    
    payNowLabel = (UILabel*)[cell viewWithTag:3];
    [payNowLabel setText:[NSString stringWithFormat:@"%.02f",payNowDifference.floatValue]];
    
    if ([_reservation.paymentType isEqualToString:@"2"])
    {
        payLaterLabel = (UILabel*)[cell viewWithTag:4];
        [payLaterLabel setText:[NSString stringWithFormat:@"%.02f",payLaterDifference.floatValue]];
    }
    else
    {
        payLaterLabel = (UILabel*)[cell viewWithTag:4];
        [payLaterLabel setText:@"-"];
    }
    
    fuelLabel = (UILabel*)[cell viewWithTag:5];
    [fuelLabel setText:temp.fuelName];
    
    transmissionLabel = (UILabel*)[cell viewWithTag:6];
    [transmissionLabel setText:temp.transmissonName];
  
    passangerLabel = (UILabel*)[cell viewWithTag:7];
    [passangerLabel setText:temp.sampleCar.passangerNumber];
    
    doorNumberLabel = (UILabel*)[cell viewWithTag:8];
    [doorNumberLabel setText:temp.sampleCar.doorNumber];
    
    segmentLabel = (UILabel*)[cell viewWithTag:9];
    [segmentLabel setText:temp.segmentName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarGroup *tempCarGroup = [CarGroup new];
    NSString *alertString;
    if ([_upsellDownsellSegment selectedSegmentIndex] == 0)
    {
        tempCarGroup = [_upsellList objectAtIndex:indexPath.row];
        alertString = [NSString stringWithFormat:@"Rezervasyonunuza ait araç grubu yükseltilerek, %@ ve benzeri (%@) grubuna değişim yapılacaktır, onaylıyor musunuz?",tempCarGroup.sampleCar.materialName,tempCarGroup.segmentName];
        
//        alertString = [NSString stringWithFormat:@"%@ () aracınızın grubu yükseltilerek, %@ (%@) aracına değişim yapılacaktır, onaylıyor musunuz?",_reservation.selectedCarGroup.sampleCar.materialName,tempCarGroup.sampleCar.materialName,tempCarGroup.segmentName];
    }
    else
    {
        tempCarGroup = [_downsellList objectAtIndex:indexPath.row];
        alertString = [NSString stringWithFormat:@"Rezervasyonunuza ait araç grubu düşürülerek, %@ ve benzeri (%@) grubuna değişim yapılacaktır, onaylıyor musunuz?",tempCarGroup.sampleCar.materialName,tempCarGroup.segmentName];
        
//        alertString = [NSString stringWithFormat:@"%@ aracınızın grubu düşürülerek, %@ aracına değişim yapılacaktır, onaylıyor musunuz?",_reservation.selectedCarGroup.sampleCar.materialName,tempCarGroup.sampleCar.materialName];
    }
    
    _reservation.upsellCarGroup = tempCarGroup;
//    if ([_reservation.reservationType isEqualToString:@"10"]) {
//        _reservation.upsellSelectedCar = [Car new];
//        _reservation.upsellSelectedCar = tempCarGroup.sampleCar;
//    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Aracınızı seçmek ister misiniz?" delegate:self cancelButtonTitle:@"Gruba Rezervasyon" otherButtonTitles:@"Araca Rezervasyon", nil];
    
    alert.tag = 2;
    [alert show];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Onaylıyorum", nil];
//    
//    alert.tag = 1;
//    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 1)
    {

    }
    
    if (alertView.tag == 2) {
        //gruba upsell/downsell
        if (buttonIndex == 0) {
            [_reservation setUpsellSelectedCar:nil];
            [self performSegueWithIdentifier:@"toOldReservationSummarySegue" sender:self];
        }
        //araca upsell/downsell
        else if (buttonIndex == 1){
            [_reservation setUpsellSelectedCar:nil];
            [self performSegueWithIdentifier:@"toCarSelectionVCSegue" sender:self];
        }
    }
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toOldReservationSummarySegue"])
    {
        if([_upsellDownsellSegment selectedSegmentIndex] == 0)
            [_reservation setUpdateStatus:@"UPS"];
        else
            [_reservation setUpdateStatus:@"DWS"];
        
//        // araca rezervasyon yaratılmış ve upsell/downsell yapılarak gruba tercih edilirse
//        if ([_reservation.reservationType isEqualToString:@"10"]) {
//            [self deleteCarSelection];
//        }
        
        [(OldReservationSummaryVC *)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationSummaryVC *)[segue destinationViewController] setTotalPrice:_totalPrice];
    }
    
    if ([segue.identifier isEqualToString:@"toCarSelectionVCSegue"])
    {
        if([_upsellDownsellSegment selectedSegmentIndex] == 0){
            [_reservation setUpdateStatus:@"UPS"];
            [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setCars:_reservation.upsellList];
        }
        else{
            [_reservation setUpdateStatus:@"DWS"];
            [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setCars:_reservation.downsellList];
        }
        
        [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setAdditionalEquipments:_reservation.additionalEquipments];
        [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setReservation:_reservation];
        [(UpsellDownsellCarSelectionVC *)[segue destinationViewController] setTotalPrice:_totalPrice];
    }
}

// araca rezervasyon upsell yada downsell yapılarak gruba çevrilmişse araç seçim farkı silinir ve tutarı toplam tutardan çıkartılır.
- (void)deleteCarSelection
{
    NSPredicate *equipmentPredicate = [NSPredicate predicateWithFormat:@"materialNumber=%@",@"HZM0031"];
    NSArray *equipmentPredicateArray = [_reservation.additionalEquipments filteredArrayUsingPredicate:equipmentPredicate];
    
    if (equipmentPredicateArray.count > 0) {
        AdditionalEquipment *temp = [equipmentPredicateArray objectAtIndex:0];
        temp.updateStatus = @"D";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
