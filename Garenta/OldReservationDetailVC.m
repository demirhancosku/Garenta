//
//  OldReservationDetailVC.m
//  Garenta
//
//  Created by Kerem Balaban on 16.10.2014.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "OldReservationDetailVC.h"
#import "MBProgressHUD.h"
#import "ReservationScopePopoverVC.h"
#import "ClassicSearchVC.h"
#import "OldReservationSearchVC.h"

@interface OldReservationDetailVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *brandModelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UILabel *fuelLabel;
@property (weak, nonatomic) IBOutlet UILabel *transmissionLabel;
@property (weak, nonatomic) IBOutlet UILabel *acLabel;
@property (weak, nonatomic) IBOutlet UILabel *passangerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *doorCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkOutOfficeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *processButton;

-(IBAction)processButtonPressed:(id)sender;

@end

@implementation OldReservationDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *brandModelString;
    if (_reservation.selectedCar) {
        brandModelString = [NSString stringWithFormat:@"%@ %@",_reservation.selectedCar.brandName,_reservation.selectedCar.modelName];
    }else{
        brandModelString = [NSString stringWithFormat:@"%@ %@ ve benzeri",_reservation.selectedCarGroup.sampleCar.brandName, _reservation.selectedCarGroup.sampleCar.modelName];
    }
    
    [_brandModelLabel setText:brandModelString];
    
    [_carImageView setImage:_reservation.selectedCarGroup.sampleCar.image];
    [_fuelLabel setText:_reservation.selectedCarGroup.fuelName];
    [_transmissionLabel setText:_reservation.selectedCarGroup.transmissonName];
    [_acLabel setText:@"Klima"];
    [_passangerNumberLabel setText:_reservation.selectedCarGroup.sampleCar.passangerNumber];
    [_doorCountLabel setText:_reservation.selectedCarGroup.sampleCar.doorNumber];
    
}

- (IBAction)processButtonPressed:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Lütfen yapmak istediğiniz işlemi seçiniz." delegate:self cancelButtonTitle:@"Geri" destructiveButtonTitle:@"Araç Değişikliği" otherButtonTitles:@"Rezervasyon Güncelleme",@"Rezervasyon İptal", nil];
    
    [sheet showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *aCell;
    UILabel *checkOutOffice;
    UILabel *checkInOffice;
    UILabel *checkOutTime;
    UILabel *checkInTime;
    UILabel *totalPrice;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM.yyy / HH:mm"];
    switch (indexPath.row) {
        case 0:
            aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
            
            checkOutOffice = (UILabel*)[aCell viewWithTag:1];
            [checkOutOffice setText:_reservation.checkOutOffice.subOfficeName];
            
            checkOutTime = (UILabel*)[aCell viewWithTag:2];
            [checkOutTime setText:[dateFormatter stringFromDate:_reservation.checkOutTime]];
            
            checkInOffice = (UILabel*)[aCell viewWithTag:3];
            [checkInOffice setText:_reservation.checkInOffice.subOfficeName];
            
            checkInTime = (UILabel*)[aCell viewWithTag:4];
            [checkInTime setText:[dateFormatter stringFromDate:_reservation.checkInTime]];
            
            break;
        case 1:
            aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
            break;
        case 2:
            aCell = [tableView dequeueReusableCellWithIdentifier:@"totalPaymentCell" forIndexPath:indexPath];
            totalPrice = (UILabel*)[aCell viewWithTag:1];
            [totalPrice setText:[NSString stringWithFormat:@"%.02f",_totalPrice.floatValue]];
            break;
        default:
            break;
    }
    
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:
            //popover
            [self performSegueWithIdentifier:@"toDetailPopoverVCSegue" sender:(UITableViewCell*)[_tableView cellForRowAtIndexPath:indexPath]];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            return 92;
            break;
        case 1:
            return 35;
            break;
        case 2:
            return 50;
            break;
        default:
            return 60;
            break;
    }
    
    return 60;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toOldReservationSearchSegue"])
    {
        [(OldReservationSearchVC *)[segue destinationViewController] setReservation:_reservation];
    }
    
    if ([segue.identifier isEqualToString:@"toDetailPopoverVCSegue"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(280, 280);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        [(ReservationScopePopoverVC *)[segue destinationViewController] setReservation:_reservation];
        
        popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        popoverController.delegate = self;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 0:
            if (buttonIndex == 1)
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                   [self cancelReservation];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
            }
            break;
        case 1:
            if (buttonIndex == 0)
                [[self navigationController] popViewControllerAnimated:YES];
            break;
        case 2:
            break;
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: //araç değişikliği
            break;
        case 1: // rezervasyon güncelleme
            [self changeReservation];
            break;
        case 2: // rezervasyon iptal
            [self getFineAndRefundPrice]; //belgeyi iptal ederken iade ve ceza tutarlarını çağırır.
            break;
        default:
            break;
    }
}

- (void)changeReservation
{
    [self performSegueWithIdentifier:@"toOldReservationSearchSegue" sender:self];
}

// REZERVASYON BELGESİNİ İPTAL EDER
- (void)cancelReservation
{
    NSString *alertString = @"";
    BOOL isOk = NO;
    
    @try
    {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_CANCEL_REZERVASYON"];
        
        [handler addImportParameter:@"IV_REZ_NO" andValue:_reservation.reservationNumber];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            NSString *subrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([subrc isEqualToString:@"0"])
            {
                alertString = [NSString stringWithFormat:@"%@ numaralı rezervasyonunuz başarıyla iptal edilmiştir.",_reservation.reservationNumber];
                isOk = YES;
            }
            else
            {
                alertString = @"Rezervasyonunuz iptal edilirken sorun oluşmuştur, lütfen tekrar deneyiniz.";
            }
        }
        else
        {
            alertString = @"Rezervasyonunuz iptal edilirken sorun oluşmuştur, lütfen tekrar deneyiniz.";
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isOk)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Başarılı" message:alertString delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            }
        });
    }
}

// CEZA VE İADE TUTARINI ÇEKER, EĞER KULLANICI ONAYLIYORSA "cancelReservation" METODU ÇAĞIRILIR.
- (void)getFineAndRefundPrice
{
    NSString *alertString = @"";
    BOOL isOk = NO;
    
    @try
    {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_IPTAL_CEZA_TUTAR"];
        
        [handler addImportParameter:@"IV_REZ_NO" andValue:_reservation.reservationNumber];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            NSDictionary *export = [response objectForKey:@"EXPORT"];
            NSString *subrc = [export valueForKey:@"EV_SUBRC"];
            
            if ([subrc isEqualToString:@"0"])
            {
                NSString *finePrice = [export valueForKey:@"EV_CEZA_TUTAR"];
                NSString *refundPrice = [export valueForKey:@"EV_IADE_TUTAR"];
                
                alertString = [NSString stringWithFormat:@"Ödemeniz gereken ceza tutarı: %.02f TL, İade edilecek tutar: %.02f TL",finePrice.floatValue,refundPrice.floatValue];
                
                isOk = YES;
            }
            else
            {
                alertString = @"İptal sırasında bir sorun oluşmuştur lütfen tekrar deneyiniz.";
            }
        }
        else
        {
            alertString = @"İptal sırasında bir sorun oluşmuştur lütfen tekrar deneyiniz.";
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isOk)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"İptal işlemini onaylıyor musunuz?" message:alertString delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Evet",nil];
                alert.tag = 0;
                [alert show];
            }
        });
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
