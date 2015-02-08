//
//  UpsellDownsellCarSelectionVC.m
//  Garenta
//
//  Created by Kerem Balaban on 5.12.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "UpsellDownsellCarSelectionVC.h"
#import "AdditionalEquipment.h"
#import "OldReservationGarentaPointTableVC.h"

@interface UpsellDownsellCarSelectionVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(assign, nonatomic)int selectedIndex;
@end

@implementation UpsellDownsellCarSelectionVC

static NSString *cellIdentifier;
@synthesize carSelectionArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectedIndex = 0;
    
    carSelectionArray = [NSMutableArray new];
    for (CarGroup *tempCar in _cars) {
        if ([tempCar.groupCode isEqualToString:_reservation.upsellCarGroup.groupCode]) {
            [carSelectionArray addObject:tempCar];
        }
    }
    
    //kış lastiği array'de varmı bakıyoruz
    NSPredicate *winterTire = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0014"];
    NSArray *filterResult = [_reservation.additionalEquipments filteredArrayUsingPredicate:winterTire];
    
    // kış lastiği varsa ve seçilmişse, araçlar içinden kış lastiği özelliği olmayanları çıkartıyoruz.
    if (filterResult.count > 0) {
        AdditionalEquipment *temp = [filterResult objectAtIndex:0];
        NSMutableArray *tempArr = [carSelectionArray copy];
        if (temp.quantity > 0) {
            for (CarGroup *tempCar in tempArr) {
                if (![tempCar.sampleCar.winterTire isEqualToString:@"X"]) {
                    [carSelectionArray removeObject:tempCar];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  carSelectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarSelectionCell" forIndexPath:indexPath];
    CarGroup *car = [carSelectionArray objectAtIndex:indexPath.row];
    UILabel *brandModelName = (UILabel*)[cell viewWithTag:1];
    [brandModelName setText:[NSString stringWithFormat:@"%@ %@ - %@",car.sampleCar.brandName,car.sampleCar.modelName,car.sampleCar.colorName]];
    [(UILabel*)[cell viewWithTag:2] setText:[NSString stringWithFormat:@" %.02f TL",car.sampleCar.pricing.carSelectPrice.floatValue]];
    
    UILabel *detailText = (UILabel*)[cell viewWithTag:4];
    
    if ([car.sampleCar.winterTire isEqualToString:@"X"])
        [detailText setText:@"Kış lastiği mevcut"];
    else
        [detailText setText:@""];
    
    UIImageView *carImage = (UIImageView*)[cell viewWithTag:3];
    carImage.image = car.sampleCar.image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.row;
    Car *car = [[carSelectionArray objectAtIndex:_selectedIndex] sampleCar];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Onay" message:
                              [NSString stringWithFormat:@"%@ %@ - (%@) modeli rezervasyonunuza eklemek istedidiğinizden emin misiniz?",car.brandName,car.modelName,car.colorName] delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles: @"Evet",nil];
        [alert show];
    });
}

#pragma mark - uialertview methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //NO
            break;
        case 1:
            [_reservation setUpsellSelectedCar:[[carSelectionArray objectAtIndex:_selectedIndex] sampleCar]];
            
            // 08.02.2015 Ata Cengiz
            [self performSegueWithIdentifier:@"toOldReservationGarentaPointSegue" sender:self];
            // 08.02.2015 Ata Cengiz
            
            break;
        default:
            break;
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 08.02.2015 Ata Cengiz
    if ([segue.identifier isEqualToString:@"toOldReservationGarentaPointSegue"]) {
        [(OldReservationGarentaPointTableVC *)[segue destinationViewController] setAdditionalEquipments:_additionalEquipments];
        [(OldReservationGarentaPointTableVC *)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationGarentaPointTableVC *)[segue destinationViewController] setTotalPrice:_totalPrice];
        [(OldReservationGarentaPointTableVC *)[segue destinationViewController] setIsYoungDriver:_isYoungDriver];
    }
    // 08.02.2015 Ata Cengiz
}

@end
