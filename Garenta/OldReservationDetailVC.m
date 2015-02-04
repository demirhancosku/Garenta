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
#import "ReplacementVehicleObject.h"
#import "OldReservationUpsellDownsellVC.h"
#import "OldReservationPaymentVC.h"
#import "ETExpiryObject.h"

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
    
    //İPTAL VE REZ.TAMAMLANDI STATÜSÜNDEKİLERE İŞLEM YAPTIRMIYORUZ.
    if ([_reservation.reservationStatuId isEqualToString:@"E0008"] || [_reservation.reservationStatuId isEqualToString:@"E0009"] || [_reservation.reservationStatuId isEqualToString:@"E0010"]) {
        
        self.navigationItem.rightBarButtonItem = nil;
    }
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
    UIActionSheet *sheet;
    
    if ([[_reservation paymentType] isEqualToString:@"2"] || [[_reservation paymentType] isEqualToString:@"6"])
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Lütfen yapmak istediğiniz işlemi seçiniz." delegate:self cancelButtonTitle:@"Geri" destructiveButtonTitle:@"Ödeme Yap" otherButtonTitles:@"Araç Değişikliği",@"Rezervasyon Güncelleme",@"Rezervasyon İptal", nil];
        sheet.tag = 1;
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Lütfen yapmak istediğiniz işlemi seçiniz." delegate:self cancelButtonTitle:@"Geri" destructiveButtonTitle:nil otherButtonTitles:@"Araç Değişikliği", @"Rezervasyon Güncelleme", @"Rezervasyon İptal", nil];
        sheet.tag = 0;
    }
    
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
    UILabel *totalPriceLabel;
    
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
            totalPriceLabel = (UILabel*)[aCell viewWithTag:2];
            
            if ([_reservation.reservationStatuId isEqualToString:@"E0009"]) {
                [totalPriceLabel setText:@"İade Edilmiş Tutar:"];
            }
            else
            {
                //normal şonra öde yada aylık şonra öde
                if ([_reservation.paymentType isEqualToString:@"2"] || [_reservation.paymentType isEqualToString:@"6"])
                    [totalPriceLabel setText:@"Tahsil Edilecek Tutar:"];
                else
                    [totalPriceLabel setText:@"Tahsil Edilmiş Tutar:"];
                
            }
            
            totalPrice = (UILabel*)[aCell viewWithTag:1];
            [totalPrice setText:[NSString stringWithFormat:@"%.02f",_reservation.documentTotalPrice.floatValue]];
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
    _reservation.upsellCarGroup = nil;
    _reservation.upsellSelectedCar = nil;
    
    if ([segue.identifier isEqualToString:@"toOldReservationSearchSegue"])
    {
        [(OldReservationSearchVC *)[segue destinationViewController] setOldCheckInTime:_oldCheckInTime];
        [(OldReservationSearchVC *)[segue destinationViewController] setOldCheckOutTime:_oldCheckOutTime];
        [(OldReservationDetailVC*) [segue destinationViewController] setOldCheckInOffice:_reservation.checkInOffice];
        [(OldReservationDetailVC*) [segue destinationViewController] setOldCheckOutOffice:_reservation.checkOutOffice];
        [(OldReservationSearchVC *)[segue destinationViewController] setReservation:_reservation];
    }
    
    if ([segue.identifier isEqualToString:@"toUpsellDownsellSegue"])
    {
        [self sortUpsellDownsellList];
        [(OldReservationUpsellDownsellVC *)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationUpsellDownsellVC *)[segue destinationViewController] setTotalPrice:[NSString stringWithFormat:@"%.02f",_reservation.documentTotalPrice.floatValue]];
    }
    
    if ([segue.identifier isEqualToString:@"toPaymentSeguePayNow"]) {
        [(OldReservationPaymentVC *)[segue destinationViewController] setReservation:_reservation];
        [(OldReservationPaymentVC *)[segue destinationViewController] setChangeReservationPrice:_reservation.documentTotalPrice];
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

- (void)sortUpsellDownsellList
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sampleCar.pricing.payNowPrice"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [_reservation.upsellList sortUsingDescriptors:sortDescriptors];
    [_reservation.downsellList sortUsingDescriptors:sortDescriptors];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reservationUpdated" object:nil];
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
    if (actionSheet.tag == 0)
    {
        switch (buttonIndex) {
            case 0: //araç değişikliği
                [self changeVehicle];
                break;
            case 1: // rezervasyon güncelleme
                [self changeReservation];
                break;
            case 2: // rezervasyon iptal
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    if ([self isDocumentCanBeCancelled]) {
                        [self getFineAndRefundPrice]; //belgeyi iptal ederken iade ve ceza tutarlarını çağırır.
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
                break;
            }
            default:
                break;
        }
    }
    else
    {
        switch (buttonIndex)
        {
            case 0: //Ödeme Yap
                [self getPayment];
                break;
            case 1:  //araç değişikliği
                [self changeVehicle];
                break;
            case 2: // rezervasyon güncelleme
                [self changeReservation];
                break;
            case 3: // rezervasyon iptal
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    if ([self isDocumentCanBeCancelled]) {
                        [self getFineAndRefundPrice]; //belgeyi iptal ederken iade ve ceza tutarlarını çağırır.
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
                break;
            }
            default:
                break;
        }
    }
}

- (BOOL)isDocumentCanBeCancelled
{
    NSString *alertString = @"";
    @try
    {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_REZERVASYON_LIST"];
        
        [handler addImportParameter:@"IV_REZ_NO" andValue:_reservation.reservationNumber];
        [handler addTableForReturn:@"ET_REZ_LIST"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            NSDictionary *rezList = [tables objectForKey:@"ZNET_INT_019"];
            
            if (rezList.count == 0) {
                
                alertString = @"Seçmiş olduğunuz rezervasyona ait sözleşme bulunmaktadır, iptal edilemez.";
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                    [alert show];
                });
                return NO;
            }
            else{
                return YES;
            }
        }
        else
        {
            alertString = @"İptal sırasında bir sorun oluşmuştur lütfen tekrar deneyiniz.";
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            });
            return NO;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally{
        
    }
}

- (void)getPayment
{
    [self performSegueWithIdentifier:@"toPaymentSeguePayNow" sender:self];
}

- (void)changeVehicle
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self getUpsellDownsellList:@""];
//        [self getUpsellDownsellList:@"U"];
//        [self getUpsellDownsellList:@"D"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (_reservation.upsellList.count > 0 || _reservation.downsellList.count > 0) {
                [self performSegueWithIdentifier:@"toUpsellDownsellSegue" sender:self];
            }
        });
    });
}


- (void)getUpsellDownsellList:(NSString *)upsell_downsell
{
    NSString *alertString = @"";
    @try
    {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getR3HostName] andClient:[ConnectionProperties getR3Client] andDestination:[ConnectionProperties getR3Destination] andSystemNumber:[ConnectionProperties getR3SystemNumber] andUserId:[ConnectionProperties getR3UserId] andPassword:[ConnectionProperties getR3Password] andRFCName:@"ZSD_KDK_FIY_RFC_UP_DOWN_SELL"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        NSArray *isInputColumns = @[@"UPSELL_DOWNSELL", @"REZERVASYON_NO", @"SOZLESME_NO", @"IMPP_LANGU", @"IMPP_LAND", @"IMPP_UNAME", @"IMPP_KDGRP", @"IMPP_BEGDA", @"IMPP_ENDDA", @"IMPP_BEGUZ", @"IMPP_ENDUZ"];
        
        NSArray *isInputValues = @[upsell_downsell, _reservation.reservationNumber, @"", @"T", @"", @"", @"40", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime]];
        
        [handler addImportStructure:@"INPUT" andColumns:isInputColumns andValues:isInputValues];
        [handler addTableForReturn:@"ET_ARACLISTE"];
        [handler addTableForReturn:@"ET_FIYAT"];
        [handler addTableForReturn:@"ET_RETURN"];
        [handler addTableForReturn:@"ET_EXPIRY"];
        
        NSDictionary *response = [handler prepCall];
        
        if (response != nil)
        {
            NSDictionary *tables = [response objectForKey:@"TABLES"];
            NSDictionary *returnList = [tables valueForKey:@"BAPIRET2"];
            
            if (returnList.count > 0)
            {
                for (NSDictionary *temp in returnList) {
                    alertString = [temp valueForKey:@"MESSAGE"];
                }
            }
            else
            {
                NSDictionary *tables = [response objectForKey:@"TABLES"];
                NSDictionary *carList = [tables objectForKey:@"ZPM_S_ARACLISTE"];
                NSDictionary *priceList = [tables objectForKey:@"ZSD_KDK_S_FIY_RFC_UDS_FIYAT"];
                // AYLIK İÇİN TAKSİT TABLOSU
                NSDictionary *etExpiry = [tables objectForKey:@"ZSD_KDK_AYLIK_TAKSIT_ST"];
                
                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
//                if (!_reservation.etExpiry){
                    _reservation.etExpiry = [NSMutableArray new];
//                }
                
                for (NSDictionary *tempDict in etExpiry) {
                    ETExpiryObject *tempObject = [ETExpiryObject new];
                    
                    [tempObject setCarGroup:[tempDict valueForKey:@"ARAC_GRUBU"]];
                    [tempObject setBeginDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_BASI"]]];
                    [tempObject setEndDate:[dateFormatter dateFromString:[tempDict valueForKey:@"DONEM_SONU"]]];
                    [tempObject setCampaignID:[tempDict valueForKey:@"KAMPANYA_ID"]];
                    [tempObject setBrandID:[tempDict valueForKey:@"MARKA_ID"]];
                    [tempObject setModelID:[tempDict valueForKey:@"MODEL_ID"]];
                    [tempObject setIsPaid:[tempDict valueForKey:@"ODENDI"]];
                    [tempObject setCurrency:[tempDict valueForKey:@"PARA_BIRIMI"]];
                    [tempObject setMaterialNo:[tempDict valueForKey:@"MALZEME"]];
                    [tempObject setTotalPrice:[NSDecimalNumber decimalNumberWithString:[tempDict valueForKey:@"TUTAR"]]];
                    
                    [_reservation.etExpiry addObject:tempObject];
                }
                
//                if ([upsell_downsell isEqualToString:@"U"])
//                    _reservation.upsellList = [NSMutableArray new];
//                else
//                    _reservation.downsellList = [NSMutableArray new];
                _reservation.upsellList = [NSMutableArray new];
                _reservation.downsellList = [NSMutableArray new];
                
                for (NSDictionary *tempDict in carList)
                {
                    Car *tempCar = [Car new];
                    Price *tempCarPrice = [Price new];
                    CarGroup *tempCarGroup = [CarGroup new];
                    tempCarGroup.cars = [NSMutableArray new];
                    
                    [tempCar setMaterialCode:[tempDict valueForKey:@"MATNR"]];
                    [tempCar setMaterialName:[tempDict valueForKey:@"MAKTX"]];
                    [tempCar setWinterTire:[tempDict valueForKey:@"KIS_LASTIK"]];
                    [tempCar setColorCode:[tempDict valueForKey:@"RENK"]];
                    [tempCar setColorName:[tempDict valueForKey:@"RENKTX"]];
                    [tempCar setBrandId:[tempDict valueForKey:@"MARKA_ID"]];
                    [tempCar setBrandName:[tempDict valueForKey:@"MARKA"]];
                    [tempCar setModelId:[tempDict valueForKey:@"MODEL_ID"]];
                    [tempCar setModelName:[tempDict valueForKey:@"MODEL"]];
                    [tempCar setModelYear:[tempDict valueForKey:@"MODEL_YILI"]];
                    [tempCar setSalesOffice:[tempDict valueForKey:@"MSUBE"]];
                    
                    NSString *imagePath = [tempDict valueForKey:@"ZRESIM_315"];
                    imagePath = [imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    NSURL *imageUrl = [NSURL URLWithString:imagePath];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                    UIImage *carImage = [UIImage imageWithData:imageData];
                    tempCar.image = carImage;
                    
                    if (tempCar.image == nil) {
                        [tempCar setImage:[UIImage imageNamed:@"sample_car.png"]];
                    }
                    
                    [tempCar setDoorNumber:[tempDict valueForKey:@"KAPI_SAYISI"]];
                    [tempCar setPassangerNumber:[tempDict valueForKey:@"YOLCU_SAYISI"]];
                    [tempCar setOfficeCode:[tempDict valueForKey:@"ASUBE"]];
                    
                    [tempCarGroup setGroupCode:[tempDict valueForKey:@"GRPKOD"]];
                    [tempCarGroup setGroupName:[tempDict valueForKey:@"GRPKODTX"]];
                    [tempCarGroup setTransmissonId:[tempDict valueForKey:@"SANZIMAN_TIPI_ID"]];
                    [tempCarGroup setTransmissonName:[tempDict valueForKey:@"SANZIMAN_TIPI"]];
                    [tempCarGroup setFuelId:[tempDict valueForKey:@"YAKIT_TIPI_ID"]];
                    [tempCarGroup setFuelName:[tempDict valueForKey:@"YAKIT_TIPI"]];
                    [tempCarGroup setBodyId:[tempDict valueForKey:@"KASA_TIPI_ID"]];
                    [tempCarGroup setBodyName:[tempDict valueForKey:@"KASA_TIPI"]];
                    [tempCarGroup setSegment:[tempDict valueForKey:@"SEGMENT"]];
                    [tempCarGroup setSegmentName:[tempDict valueForKey:@"SEGMENTTX"]];
                    
                    [tempCarGroup setMinAge:[[tempDict valueForKey:@"MIN_YAS"] integerValue]];
                    [tempCarGroup setMinDriverLicense:[[tempDict valueForKey:@"MIN_EHLIYET"] integerValue]];
                    [tempCarGroup setMinYoungDriverAge:[[tempDict valueForKey:@"GENC_SRC_YAS"] integerValue]];
                    [tempCarGroup setMinYoungDriverLicense:[[tempDict valueForKey:@"GENC_SRC_EHL"] integerValue]];
                    
                    for (NSDictionary *tempPriceDict in priceList)
                    {
                        if ([[tempPriceDict valueForKey:@"ARAC_GRUBU"] isEqualToString:tempCarGroup.groupCode] && [[tempPriceDict valueForKey:@"MARKA_ID"] isEqualToString:tempCar.brandId] && [[tempPriceDict valueForKey:@"MODEL_ID"] isEqualToString:tempCar.modelId])
                        {
                            
                            [tempCarPrice setPayLaterPrice:[NSDecimalNumber decimalNumberWithString:[tempPriceDict valueForKey:@"SONRA_ODE_FIYAT_TRY"]]];
                            [tempCarPrice setPayNowPrice:[NSDecimalNumber decimalNumberWithString:[tempPriceDict valueForKey:@"SIMDI_ODE_FIYAT_TRY"]]];
                            [tempCarPrice setDocumentCarPrice:[NSDecimalNumber decimalNumberWithString:[tempPriceDict valueForKey:@"UDS_BELGE_FIYATI"]]];
                            [tempCarPrice setCarSelectPrice:[NSDecimalNumber decimalNumberWithString:[tempPriceDict valueForKey:@"ARAC_SECIM_FARK_TRY"]]];
                            upsell_downsell = [tempPriceDict valueForKey:@"UP_DOWN"];
                            
                            [tempCar setPricing:tempCarPrice];
                            
                            break;
                        }
                    }
                    
                    if ([[tempDict valueForKey:@"VITRINRES"] isEqualToString:@"X"])
                        tempCar.isForShown = YES;
                    
                    [tempCarGroup setSampleCar:tempCar];
                    [tempCarGroup.cars addObject:tempCar];
                    
                    if ([upsell_downsell isEqualToString:@"U"])
                        [_reservation.upsellList addObject:tempCarGroup];
                    else
                        [_reservation.downsellList addObject:tempCarGroup];
                }
            }
        }
        else
        {
            alertString = @"Araç Listesi alınırken problem oluşmuştur, lütfen tekrar deneyiniz.";
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![alertString isEqualToString:@""])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Üzgünüz" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                [alert show];
            }
        });
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
