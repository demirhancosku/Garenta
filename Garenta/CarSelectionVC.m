//
//  CarSelectionVC.m
//  Garenta
//
//  Created by Alp Keser on 6/16/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "CarSelectionVC.h"
#import "AdditionalEquipment.h"

@interface CarSelectionVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(assign, nonatomic)int selectedIndex;
@end

@implementation CarSelectionVC
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

    //kış lastiği array'de varmı bakıyoruz
    NSPredicate *winterTire = [NSPredicate predicateWithFormat:@"materialNumber = %@",@"HZM0014"];
    NSArray *filterResult = [_additionalEquipments filteredArrayUsingPredicate:winterTire];
    
    // kış lastiği varsa ve seçilmişse, araçlar içinden kış lastiği özelliği olmayanları çıkartıyoruz.
    if (filterResult.count > 0) {
        AdditionalEquipment *temp = [filterResult objectAtIndex:0];
        NSMutableArray *tempArr = [carSelectionArray copy];
        if (temp.quantity > 0) {
            for (Car *tempCar in tempArr) {
                if (![tempCar.winterTire isEqualToString:@"X"]) {
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
    Car *car = [carSelectionArray objectAtIndex:indexPath.row];
    UILabel *brandModelName = (UILabel*)[cell viewWithTag:1];
    [brandModelName setText:[NSString stringWithFormat:@"%@ %@ - %@",car.brandName,car.modelName,car.colorName]];
    [(UILabel*)[cell viewWithTag:2] setText:[NSString stringWithFormat:@" %.02f TL",car.pricing.carSelectPrice.floatValue]];
    
    UILabel *detailText = (UILabel*)[cell viewWithTag:4];
    
    if ([car.winterTire isEqualToString:@"X"])
        [detailText setText:@"Kış lastiği mevcut"];
    else
        [detailText setText:@""];

    UIImageView *carImage = (UIImageView*)[cell viewWithTag:3];
    carImage.image = car.image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.row;
    Car *car = [carSelectionArray objectAtIndex:_selectedIndex];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Onay" message:
                          [NSString stringWithFormat:@"%@ %@ modeli rezervasyonunuza eklemek istedidiğinizden emin misiniz?",car.brandName,car.modelName]	 delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles: @"Evet",nil];
    [alert show];
}

#pragma mark - uialertview methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //NO
            break;
            case 1:
            [_reservation setSelectedCar:[carSelectionArray objectAtIndex:_selectedIndex]];
            [[self navigationController] popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"carSelected" object:nil];
            break;
        default:
            break;
    }
}

@end
