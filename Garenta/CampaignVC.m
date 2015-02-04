//
//  CampaignVCTableViewController.m
//  Garenta
//
//  Created by Kerem Balaban on 26.11.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "CampaignVC.h"
#import "CampaignCell.h"
#import "CampaignObject.h"
#import "EquipmentVC.h"
#import "Office.h"

@interface CampaignVC ()

@end

@implementation CampaignVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _officeList = [NSMutableArray new];
    _officeList = [_carGroup carGroupOffices];
    
    //ofis bazında kampanyaları dağıtıyoruz
    for (Office *tempOffice in _officeList)
    {
        tempOffice.campaignList = [NSMutableArray new];
        for (CampaignObject *temp in _carGroup.campaignsArray)
        {
            NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"campaignID==%@", temp.campaignID];
            NSArray *filterCampaignArr = [tempOffice.campaignList filteredArrayUsingPredicate:resultPredicate];
            
            if (filterCampaignArr.count == 0 || [temp.campaignPrice.salesOffice isEqualToString:[[[filterCampaignArr objectAtIndex:0] campaignPrice] salesOffice]])
            {
                NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"campaignScopeType==%i", temp.campaignScopeType];
                NSArray *filterCampaignScopeArr = [tempOffice.campaignList filteredArrayUsingPredicate:resultPredicate];
                
                if (filterCampaignScopeArr.count == 0) {
                    [tempOffice.campaignList addObject:temp];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _officeList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //    return _campaignIdArray.count;
    return [[[_officeList objectAtIndex:section] campaignList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CampaignCell *cell = [tableView dequeueReusableCellWithIdentifier:@"campaignCell"];
    if (cell == nil) {
        cell = [CampaignCell new];
    }
    
    cell.noCancellationButton.hidden = YES;
    //    cell.payLaterButton.hidden = YES;
    //    cell.payNowButton.hidden = YES;
    
    [cell.payNowButton addTarget:self action:@selector(payNowButtonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.payLaterButton addTarget:self action:@selector(payLaterButtonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noCancellationButton addTarget:self action:@selector(noCancellationButtonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //Önce normal fiyatlar yazılıyor (aylık fiyatlar varsa + KDV)
    NSString *payNowPrice;
    NSString *payLaterPrice;
    if (_reservation.etExpiry.count > 0) {
        payNowPrice = [NSString stringWithFormat:@"Şimdi Öde:\n%.02fTL + KDV",_carGroup.sampleCar.pricing.payNowPrice.floatValue];
        payLaterPrice = [NSString stringWithFormat:@"Sonra Öde:\n %.02fTL + KDV",_carGroup.sampleCar.pricing.payLaterPrice.floatValue];
    }
    else
    {
        payNowPrice = [NSString stringWithFormat:@"Şimdi Öde:\n %.02f TL",_carGroup.sampleCar.pricing.payNowPrice.floatValue];
        payLaterPrice = [NSString stringWithFormat:@"Sonra Öde:\n %.02f TL",_carGroup.sampleCar.pricing.payLaterPrice.floatValue];
    }
    
    
    [cell.payNowButton setTitle:payNowPrice forState:UIControlStateNormal];
    [cell.payLaterButton setTitle:payLaterPrice forState:UIControlStateNormal];
    
    CampaignObject *tempCampaign = [[[_officeList objectAtIndex:indexPath.section] campaignList] objectAtIndex:indexPath.row];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"campaignID==%@", tempCampaign.campaignID];
    NSArray *filterArr = [_carGroup.campaignsArray filteredArrayUsingPredicate:resultPredicate];
    
    // Şimdi öde, sonra öde yada ön ödemeli iptal edilemez fiyatları varsa o fiyatlar yazılıyor
    NSString *campaingPayNow;
    NSString *campaignPayLater;
    NSString *campaignPayFront;
    
    for (CampaignObject *tempObj in filterArr) {
        if (_reservation.etExpiry.count > 0 && [[[_officeList objectAtIndex:indexPath.section] mainOfficeCode] isEqualToString:tempObj.campaignPrice.salesOffice]) {
            campaingPayNow = [NSString stringWithFormat:@"Şimdi Öde:\n %.02fTL + KDV",tempObj.campaignPrice.payNowPrice.floatValue];
            campaignPayLater = [NSString stringWithFormat:@"Sonra Öde:\n %.02fTL + KDV",tempObj.campaignPrice.payLaterPrice.floatValue];
            campaignPayFront = [NSString stringWithFormat:@"%.02fTL + KDV ön ödemeli - iptal edilemez",tempObj.campaignPrice.payNowPrice.floatValue];
        }
        else if ([[[_officeList objectAtIndex:indexPath.section] mainOfficeCode] isEqualToString:tempObj.campaignPrice.salesOffice])
        {
            campaingPayNow = [NSString stringWithFormat:@"Şimdi Öde:\n %.02f TL",tempObj.campaignPrice.payNowPrice.floatValue];
            campaignPayLater = [NSString stringWithFormat:@"Sonra Öde:\n %.02f TL",tempObj.campaignPrice.payLaterPrice.floatValue];
            campaignPayFront = [NSString stringWithFormat:@"%.02f TL ön ödemeli - iptal edilemez",tempObj.campaignPrice.payNowPrice.floatValue];
        }
        
        
        if (tempObj.campaignReservationType == payNowReservation) {
            [cell.payNowButton setTitle:campaingPayNow forState:UIControlStateNormal];
        }
        if (tempObj.campaignReservationType == payLaterReservation) {
            [cell.payLaterButton setTitle:campaignPayLater forState:UIControlStateNormal];
        }
        if (tempObj.campaignReservationType == payFrontWithNoCancellation) {
            [cell.noCancellationButton setTitle:campaignPayFront forState:UIControlStateNormal];
            cell.noCancellationButton.hidden = NO;
        }
    }
    
    if (tempCampaign.campaignScopeType == vehicleModelCampaign) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"brandId==%@ AND modelId==%@",tempCampaign.campaignPrice.brandId,tempCampaign.campaignPrice.modelId];
        NSArray *filterArr = [_carGroup.cars filteredArrayUsingPredicate:resultPredicate];
        
        cell.campaignTextLabel.text = [NSString stringWithFormat:@"%@ %@ kampanyası",[[filterArr objectAtIndex:0]brandName],[[filterArr objectAtIndex:0]modelName]];
        cell.carImage.image = [[filterArr objectAtIndex:0] image];
    }
    if (tempCampaign.campaignScopeType == vehicleBrandCampaign) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"brandId==%@",tempCampaign.campaignPrice.brandId];
        NSArray *filterArr = [_carGroup.cars filteredArrayUsingPredicate:resultPredicate];
        
        cell.campaignTextLabel.text = [NSString stringWithFormat:@"%@ araç kampanyası",[[filterArr objectAtIndex:0]brandName]];
        cell.carImage.image = [[filterArr objectAtIndex:0] image];
    }
    if (tempCampaign.campaignScopeType == vehicleGroupCampaign) {
        cell.campaignTextLabel.text = [NSString stringWithFormat:@"%@ %@ ve benzeri kampanyası",_carGroup.sampleCar.brandName,_carGroup.sampleCar.modelName];
        
        cell.carImage.image = _carGroup.sampleCar.image;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont boldSystemFontOfSize:12];
    sectionHeader.textColor = [UIColor blackColor];
    
    sectionHeader.text = [[_officeList objectAtIndex:section] subOfficeName];
    return sectionHeader;
}

- (NSIndexPath *)findIndexPath:(UIButton*)button event:(UIEvent*)event
{
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:
                              [[[event touchesForView:button] anyObject]
                               locationInView:self.tableView]];
    
    return indexPath;
}

- (NSArray *)getFilteredArray:(CampaignObject *)tempCampaign
{
    // Şimdi öde, sonra öde yada ön ödemeli iptal edilemez fiyatları varsa o fiyatlar yazılıyor
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"campaignID==%@", tempCampaign.campaignID];
    NSArray *filterArr = [_carGroup.campaignsArray filteredArrayUsingPredicate:resultPredicate];
    
    return filterArr;
}

- (Car *)findSelectedCar:(CampaignObject *)campaign
{
    NSArray *filterArr = [NSArray new];
    if (campaign.campaignScopeType == vehicleModelCampaign) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"brandId==%@ AND modelId==%@",campaign.campaignPrice.brandId,campaign.campaignPrice.modelId];
        filterArr = [_carGroup.cars filteredArrayUsingPredicate:resultPredicate];
    }

    if (filterArr.count > 0)
        return [filterArr objectAtIndex:0];
    else
        return nil;
}

- (void)payNowButtonPressed:(UIButton*)button event:(UIEvent*)event
{
    NSIndexPath *indexPath = [self findIndexPath:button event:event];
    CampaignObject *tempCampaign = [[[_officeList objectAtIndex:indexPath.section] campaignList] objectAtIndex:indexPath.row];
    NSArray *filterArr = [self getFilteredArray:tempCampaign];
    
    // Seçilen çıkış ofisi atanır (Tüm şubelerde farklı şubeler seçilebildiği için)
    _reservation.checkOutOffice = [_officeList objectAtIndex:indexPath.section];
    _reservation.selectedCar = nil;
    
    // Şimdi öde, sonra öde yada ön ödemeli iptal edilemez fiyatları varsa o fiyatlar yazılıyor
    for (CampaignObject *temp in filterArr) {
        if (temp.campaignReservationType == payNowReservation)
        {
            if (temp.campaignScopeType == vehicleModelCampaign) {
                _reservation.selectedCar = [Car new];
                _reservation.selectedCar = [self findSelectedCar:tempCampaign];
                _reservation.selectedCar.pricing.carSelectPrice = temp.campaignPrice.carSelectPrice;
            }
            
            _reservation.campaignObject = temp;
            _reservation.selectedCarGroup.sampleCar.pricing.payNowPrice = tempCampaign.campaignPrice.payNowPrice;
        }
    }
    
    [self performSegueWithIdentifier:@"toAdditionalEquipmentSegue" sender:self];
}

- (void)payLaterButtonPressed:(UIButton*)button event:(UIEvent*)event
{
    NSIndexPath *indexPath = [self findIndexPath:button event:event];
    CampaignObject *tempCampaign = [[[_officeList objectAtIndex:indexPath.section] campaignList] objectAtIndex:indexPath.row];
    NSArray *filterArr = [self getFilteredArray:tempCampaign];
    
    // Seçilen çıkış ofisi atanır (Tüm şubelerde farklı şubeler seçilebildiği için)
    _reservation.checkOutOffice = [_officeList objectAtIndex:indexPath.section];
    _reservation.selectedCar = nil;
    _reservation.campaignButtonPressed = payLaterReservation;
    
    // Şimdi öde, sonra öde yada ön ödemeli iptal edilemez fiyatları varsa o fiyatlar yazılıyor
    for (CampaignObject *temp in filterArr) {
        if (temp.campaignReservationType == payLaterReservation)
        {
            if (temp.campaignScopeType == vehicleModelCampaign) {
                _reservation.selectedCar = [Car new];
                _reservation.selectedCar = [self findSelectedCar:tempCampaign];
                _reservation.selectedCar.pricing.carSelectPrice = temp.campaignPrice.carSelectPrice;
            }
            
            _reservation.campaignObject = temp;
            _reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice = tempCampaign.campaignPrice.payLaterPrice;
        }
    }

    [self performSegueWithIdentifier:@"toAdditionalEquipmentSegue" sender:self];
}

- (void)noCancellationButtonPressed:(UIButton*)button event:(UIEvent*)event
{
    NSIndexPath *indexPath = [self findIndexPath:button event:event];
    CampaignObject *tempCampaign = [[[_officeList objectAtIndex:indexPath.section] campaignList] objectAtIndex:indexPath.row];
    NSArray *filterArr = [self getFilteredArray:tempCampaign];
    
    // Seçilen çıkış ofisi atanır (Tüm şubelerde farklı şubeler seçilebildiği için)
    _reservation.checkOutOffice = [_officeList objectAtIndex:indexPath.section];
    _reservation.selectedCar = nil;
    
    // Şimdi öde, sonra öde yada ön ödemeli iptal edilemez fiyatları varsa o fiyatlar yazılıyor
    for (CampaignObject *temp in filterArr) {
        if (temp.campaignReservationType == payFrontWithNoCancellation)
        {
            if (temp.campaignScopeType == vehicleModelCampaign) {
                _reservation.selectedCar = [Car new];
                _reservation.selectedCar = [self findSelectedCar:tempCampaign];
                _reservation.selectedCar.pricing.carSelectPrice = temp.campaignPrice.carSelectPrice;
            }

            _reservation.campaignObject = temp;
            _reservation.selectedCarGroup.sampleCar.pricing.payNowPrice = tempCampaign.campaignPrice.payNowPrice;
        }
    }

    [self performSegueWithIdentifier:@"toAdditionalEquipmentSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toAdditionalEquipmentSegue"]) {
        User *tempUser = [ApplicationProperties getUser];
        
        EquipmentVC *additionalEquipmentsVC = (EquipmentVC*)segue.destinationViewController;
        [additionalEquipmentsVC setIsYoungDriver:[CarGroup checkYoungDriverAddition:_carGroup andBirthday:tempUser.birthday andLicenseDate:tempUser.driversLicenseDate]];
        [additionalEquipmentsVC setIsCampaign:YES];
        [additionalEquipmentsVC setReservation:_reservation];
    }
}

@end
