//
//  OldReservationUpsellDownsellVCViewController.m
//  Garenta
//
//  Created by Kerem Balaban on 6.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationUpsellDownsellVC.h"
#import "OldReservationSummaryVC.h"

@interface OldReservationUpsellDownsellVC ()

@property (strong,nonatomic) IBOutlet UISegmentedControl *upsellDownsellSegment;
@property (strong,nonatomic) IBOutlet UITableView *tableVC;


- (IBAction)changeSegmentValue:(id)sender;
@end

@implementation OldReservationUpsellDownsellVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_reservation.downsellList.count == 0)
        [_upsellDownsellSegment setEnabled:NO forSegmentAtIndex:1];
    else if (_reservation.upsellList.count == 0)
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
        return _reservation.upsellList.count;
    else
        return _reservation.downsellList.count;
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
        copyArray = [_reservation.upsellList copy];
    else
        copyArray = [_reservation.downsellList copy];
    
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
        tempCarGroup = [_reservation.upsellList objectAtIndex:indexPath.row];
        alertString = [NSString stringWithFormat:@"%@ aracınızın grubu yükseltilerek, %@ aracına değişim yapılacaktır, onaylıyor musunuz?",_reservation.selectedCarGroup.sampleCar.materialName,tempCarGroup.sampleCar.materialName];
    }
    else
    {
        tempCarGroup = [_reservation.downsellList objectAtIndex:indexPath.row];
        alertString = [NSString stringWithFormat:@"%@ aracınızın grubu düşürülerek, %@ aracına değişim yapılacaktır, onaylıyor musunuz?",_reservation.selectedCarGroup.sampleCar.materialName,tempCarGroup.sampleCar.materialName];
    }
    
    _reservation.upsellCarGroup = tempCarGroup;
    _reservation.upsellSelectedCar = [Car new];
    _reservation.upsellSelectedCar = tempCarGroup.sampleCar;

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:alertString delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Onaylıyorum", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self performSegueWithIdentifier:@"toOldReservationSummarySegue" sender:self];
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
        
        [(OldReservationSummaryVC *)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationSummaryVC *)[segue destinationViewController] setTotalPrice:_totalPrice];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
