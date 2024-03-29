//
//  CarGroupTableVC.m
//  Garenta
//
//  Created by Alp Keser on 5/15/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "CarGroupTableVC.h"
#import "CarGroupTableViewCell.h"
#import "CarGroupManagerViewController.h"
@interface CarGroupTableVC ()

@end

@implementation CarGroupTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self.tableView registerClass:[CarGroupTableViewCell class] forCellReuseIdentifier:@"CarGroupDetailCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return _activeCarGroup.carGroupOffices.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarGroupDetailCell"];
    if (cell == nil) {
        cell = [CarGroupTableViewCell new];
    }
    
    [[cell officeNameLabel] setText:[(Office*)[_activeCarGroup.carGroupOffices objectAtIndex:indexPath.row] subOfficeName]];
    
    NSString *salesOffice = [(Office*)[_activeCarGroup.carGroupOffices objectAtIndex:indexPath.row] mainOfficeCode];
    
    if (self.isMontlyRent) {
        [[cell payLaterPriceLabel] setText:[NSString stringWithFormat:@"%.02fTL + KDV",_activeCarGroup.payNowPrice.floatValue]];
        [[cell payLaterPriceLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11]];
    }
    else {
        //burda tümü seçildiğinde şubeye göre fiyatları yazıyoruz
        if (_activeCarGroup.cars.count > 0) {
            for (Car *tempCar in _activeCarGroup.cars) {
                if ([tempCar.salesOffice isEqualToString:salesOffice]) {
                    [[cell payLaterPriceLabel] setText:[NSString stringWithFormat:@"%.02f TL",tempCar.pricing.payNowPrice.floatValue]];
                    
                    break;
                }
            }
        }
        else{
            [[cell payLaterPriceLabel] setText:[NSString stringWithFormat:@"%.02f TL",_activeCarGroup.payNowPrice.floatValue]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    User *tempUser = [ApplicationProperties getUser];
    if ([self checkIsCarGroupAvailable:tempUser.birthday andLicenseDate:tempUser.driversLicenseDate])
    {
        // kampanyayla gidince bozuluyo
        _activeCarGroup.sampleCar.pricing.payNowPrice = [NSDecimalNumber decimalNumberWithString:_activeCarGroup.payNowPrice];
        _activeCarGroup.sampleCar.pricing.payLaterPrice = [NSDecimalNumber decimalNumberWithString:_activeCarGroup.payLaterPrice];
        
        [_delegate carGroupSelected:_activeCarGroup withOffice:[[_activeCarGroup carGroupOffices] objectAtIndex:indexPath.row] ];
    }
}

- (BOOL)checkIsCarGroupAvailable:(NSDate *)birthday andLicenseDate:(NSDate *)licenseDate;
{
    if (![CarGroup isCarGroupAvailableByAge:_activeCarGroup andBirthday:birthday andLicenseDate:licenseDate])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:[NSString stringWithFormat:@"Seçilen araç grubuna rezervasyon yapılamaz. (Min.Genç Sürücü yaşı: %li - Min.Genç Sürücü Ehliyet Yılı: %li)",(long)_activeCarGroup.minYoungDriverAge,(long)_activeCarGroup.minYoungDriverLicense] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return NO;
    }
    
    return YES;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
