//
//  CarSelectionVC.m
//  Garenta
//
//  Created by Alp Keser on 6/16/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "CarSelectionVC.h"

@interface CarSelectionVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(assign, nonatomic)int selectedIndex;
@end

@implementation CarSelectionVC
static NSString *cellIdentifier;
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
    // Do any additional setup after loading the view.
//    CarSelectionCell
//    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CarSelectionCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _reservation.selectedCarGroup.cars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarSelectionCell" forIndexPath:indexPath];
    Car *car = [_reservation.selectedCarGroup.cars objectAtIndex:indexPath.row];
    UILabel *brandModelName = (UILabel*)[cell viewWithTag:1];
    [brandModelName setText:[NSString stringWithFormat:@"%@ %@",car.brandName,car.modelName]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.row;
    Car *car = [_reservation.selectedCarGroup.cars objectAtIndex:_selectedIndex];
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
           //YES
            [_reservation setSelectedCar:[_reservation.selectedCarGroup.cars objectAtIndex:_selectedIndex]];
            [[self navigationController] popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"carSelected" object:nil];
            break;
        default:
            break;
    }
}

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
