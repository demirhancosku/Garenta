//
//  PaymentTableViewController.m
//  Garenta
//
//  Created by Alp Keser on 6/19/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "PaymentTableViewController.h"
#import "CreditCard.h"
#import "AdditionalEquipment.h"
#import "ZGARENTA_REZERVASYON_SRVRequestHandler.h"
#import "ZGARENTA_REZERVASYON_SRVServiceV0.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
@interface PaymentTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameOnCardTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationMonthTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *cvvTextField;
@property (weak, nonatomic) IBOutlet UITextField *garentaTlTextField;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property(strong,nonatomic)NSArray *requiredFields;
- (IBAction)reservationCompleteButtonPressed:(id)sender;
@end

@implementation PaymentTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [_totalPriceLabel setText:[NSString stringWithFormat:@"%@ TL",[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES]]];
    _requiredFields = [NSArray arrayWithObjects:_creditCardNumberTextField,_nameOnCardTextField,_expirationMonthTextField,_expirationYearTextField,_cvvTextField, nil];
    
    //temp for test
//    [_nameOnCardTextField setText:@"Yusuf Alp Keser"]; //Musteri ismi ile aynı olcak yoksa hata donuyor
//    [_creditCardNumberTextField  setText:@"4022774022774026"];
//    [_expirationYearTextField setText:@"2018"];
//    [_expirationMonthTextField setText:@"12"];
//    [_cvvTextField setText:@"000"];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObservers];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObservers];
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
    return 7;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self createReservation];
    }else{
        
    }
}
#pragma mark - custom methods

- (BOOL)checkRequiredFields{
    
    NSString *errorMessage;
    
    NSDateComponents *dateComponents =[[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:NSDate.date];
    
    for (UITextField *temTextField in _requiredFields) {
        if (temTextField.text.length == 0) {
            errorMessage = @"Lütfen tüm zorunlu alanları doldurunuz.";
        }
    }
    
    if (_creditCardNumberTextField.text.length < 19)
        errorMessage = @"Kredi kartı numaranız 16 hane olmalıdır, lütfen kontrol edin.";
    
    else if (_expirationMonthTextField.text.length < 2)
        errorMessage = @"Girmiş olduğunuz ay değeri 2 hane olmalıdır, lütfen kontrol edin.";
    
    else if (_expirationMonthTextField.text.integerValue > 12 || _expirationMonthTextField.text.integerValue == 0)
        errorMessage = @"Girmiş olduğunuz ay değeri geçerli formatta değildir, lütfen kontrol edin.";
    
    else if (_expirationYearTextField.text.length < 4)
        errorMessage = @"Girmiş olduğunuz yıl değeri 4 hane olmalıdır, lütfen kontrol edin.";
    
    else if (_expirationYearTextField.text.integerValue < dateComponents.year)
        errorMessage = @"Girmiş olduğunuz yıl değeri mevcut yıldan küçük olamaz, lütfen kontrol edin.";
    
    else if (_expirationYearTextField.text.integerValue == dateComponents.year && _expirationMonthTextField.text.integerValue < dateComponents.month)
        errorMessage = @"Girmiş olduğunuz son kullanma tarihini kontrol edin.";
    
    else if (_cvvTextField.text.length < 3)
        errorMessage = @"CVV numarası 3 hane olmalıdır, lütfen kontrol edin.";
    

    if (errorMessage != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:errorMessage delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        
        [alert show];
        return NO;
    }

    return YES;
}


/*
 
 -----------!BEWARE!----------
 
 */

- (void)createReservation{
    NSDateFormatter *dateFormatter =[NSDateFormatter new];
    [dateFormatter setDateFormat:@"hh:mm"];
    [ApplicationProperties configureReservationService];
    ReservationServiceV0 *aService = [ReservationServiceV0 new];
    IsInputV0 *isInput = [IsInputV0 new];
    [ApplicationProperties fillProperties:isInput];
    [isInput setAlisSubesi:_reservation.checkInOffice.mainOfficeCode];
    [isInput setBonus:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    [isInput setGarentaTl:[NSDecimalNumber decimalNumberWithString:@"0.0"]]; //free
    [isInput setGunSayisi:_reservation.selectedCarGroup.sampleCar.pricing.dayCount]; //available aractan donen gun sayisi*
    [isInput setMilesSmiles:[NSDecimalNumber decimalNumberWithString:@"0.0"]]; //
    [isInput setOdemeTuru:@"1"];//1,2,3 hemen ödeme sonra öde ön ödemeli iptal edilemez
    [isInput setParaBirimi:@"TRY"]; //TRY EUR USD GBP
    [isInput setRezBegda:_reservation.checkOutTime];
    [isInput setRezBegtime:[dateFormatter stringFromDate:_reservation.checkOutTime]];
    [isInput setRezEndda:[_reservation checkInTime]];
    [isInput setRezEndtime:[dateFormatter stringFromDate:_reservation.checkInTime]];
    [isInput setRezKanal:@"40"]; //Mobil 40
    [isInput setSatisBurosu:_reservation.checkOutOffice.mainOfficeCode];// checkout office
    [isInput setTeslimSubesi:_reservation.checkInOffice.mainOfficeCode];
    [isInput setToplamTutar:[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO]];
    [isInput setUsername:@" "];
    User *currentUser = (User*)[ApplicationProperties getUser];
    IsUserinfoV0 *isUserInfo = [IsUserinfoV0 new];
    [ApplicationProperties fillProperties:isUserInfo];
    [isUserInfo setSalesOrganization:@"3063"];//????fix
    [isUserInfo setDistributionChannel:@"33"];//???3063 fix
    [isUserInfo setDivision:@"65"];//???fix
    [isUserInfo setEhliyetTarihi:[NSDate date]];
    [isUserInfo setKanalturu:@"Z07"]; // sabit
    
    [isUserInfo setMiddlename:@" "];
    if (currentUser.isLoggedIn) {
        [isUserInfo setMusterino:currentUser.kunnr]; //kunnr loginse must
        [isUserInfo setBirthdate:[ NSDate date]];
        //birinden biri
    }else{
        [isUserInfo setLastname:currentUser.surname];
        [isUserInfo setBirthdate:[ currentUser birthday]];
        [isUserInfo setCinsiyet:[currentUser gender]];//???1 erkek 2 kadın
        [isUserInfo setMusterino:@" "]; //kunnr loginse must
        
        [isUserInfo setEmail:currentUser.email]; //zoeunlu
        [isUserInfo setFirstname:currentUser.name];
        //birinden biri
        [isUserInfo setTckn:currentUser.tckno];
        [isUserInfo setTelno:currentUser.mobile]; //no533
    }
    
    //nationalitye gore
    [isUserInfo setPasaportno:@" "];
    
    [isUserInfo setTelnoUlke:@"90"];//90
    [isUserInfo setUlke:@"TR"];//??? TR yada bos
    [isUserInfo setUyruk:@"TR"];//???? tr veya boş
    //buraya availdeki arac matnrsini cak
    IT_ARACLARV0 *itAracLine;
    NSMutableArray * itAraclar = [NSMutableArray new];
    for (Car *tempCar in _reservation.selectedCarGroup.cars) {
        itAracLine = [IT_ARACLARV0 new];
        [itAracLine setMatnr:tempCar.materialCode];
        [itAraclar addObject:itAracLine];
    }
    NSMutableArray *itEksurucu = [NSMutableArray new];
    NSMutableArray *itItem = [NSMutableArray new];
    IT_EKSURUCUV0 *itEksurucuLine;
    IT_ITEMSV0 *itemLine ;
    
    //Arac ekliyorum
    itemLine = [IT_ITEMSV0 new];
    [itemLine setAlisSubesi:_reservation.checkOutOffice.mainOfficeCode];
    
    [itemLine setAracRenk:@" "];//???renk kodu available aracta ff bilmnenmen?
    //TODO check addtional
    [itemLine setCKislastik:@" "];//??? X sadece arac satirinda olcak
    [itemLine setFiloSegment:_reservation.selectedCarGroup.segment];// segment kod
    [itemLine setFiyat:[NSDecimalNumber decimalNumberWithString:_reservation.selectedCarGroup.payLaterPrice]];
    [itemLine setFiyatKodu:@" "]; //avail aracta donudo
    [itemLine setKalemTipi:@" "]; //update ici create de bos 1:farkl tes cikis 2:farkli tes donus 3: sure uzat 4: kisaltma
    [itemLine setKampanyaId:@" "]; //et_rezervdeki id
    [itemLine setMiktar:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    [itemLine setParaBirimi:@"TRY"]; //konustuk bunu
    if (_reservation.selectedCar != nil) {
        //        [itemLine setPlakaNo:_reservation.selectedCar.plateNumber]; //plaka kullanılmiyor zaten donmuyor da
        [itemLine setAracGrubu:@" "];
        [itemLine setMalzemeNo:_reservation.selectedCar.materialCode]; //matnr
        [itemLine setJatoMarka:@" "]; //avail arac
        [itemLine setJatoModel:@" "];//avail arac
    }else{
        [itemLine setAracGrubu:_reservation.selectedCarGroup.groupCode];
        [itemLine setMalzemeNo:@" "]; //matnr
        [itemLine setJatoMarka:@" "]; //avail arac
        [itemLine setJatoModel:@" "];//avail arac
    }
    [itemLine setPlakaNo:@" "];
    [itemLine setRezBegda:_reservation.checkOutTime];//headerla ayni
    [itemLine setRezBegtime:[dateFormatter stringFromDate:_reservation.checkOutTime]];
    [itemLine setRezEndda:_reservation.checkInTime];
    [itemLine setRezEndtime:[dateFormatter stringFromDate:_reservation.checkInTime]];
    [itemLine setRezKalemNo:@" "]; //update icin create
    [itemLine setSasiNo:@" "]; // avail aractan
    [itemLine setSatisBurosu:_reservation.checkOutOffice.mainOfficeCode]; //chekout office
    [itemLine setTeslimSubesi:_reservation.checkInOffice.mainOfficeCode];
    [itemLine setUpdateStatu:@" "]; // kullanilmior
    [itItem addObject:itemLine];
    
    for (AdditionalEquipment *tempEquipment in _reservation.additionalEquipments) {
        for (int sayac = 0; sayac <tempEquipment.quantity; sayac++) {
            if (tempEquipment.type == additionalDriver) {
                itEksurucuLine = [IT_EKSURUCUV0 new];
                [itEksurucuLine setBirthdate:[NSDate date]];
                [itEksurucuLine setCinsiyet:@" "];//1 erkek 2 kadin
                [itEksurucuLine setEhliyetAlisyeri:@" "];
                [itEksurucuLine setEhliyetNo:@" "];
                [itEksurucuLine setEhliyetSinifi:@" "];
                [itEksurucuLine setEhliyetTarihi:[NSDate date]];
                [itEksurucuLine setEksurucuNo:@" "];//update icin create gereksiz
                [itEksurucuLine setFirstname:@" "];
                [itEksurucuLine setKalemNo:@" "];//update icin create gereksiz
                [itEksurucuLine setLastname:@" "];
                [itEksurucuLine setTckn:@" "];
                [itEksurucuLine setTelno:@" "];
                [itEksurucuLine setUlke:@" "];//digerse bos
                [itEksurucuLine setUyruk:@" "];//digerse bos
                [itEksurucuLine setUpdateStatu:@" "];//update icin create gereksiz
                [itEksurucu addObject:itEksurucuLine];
            }else{
                itemLine = [IT_ITEMSV0 new];
                [itemLine setAlisSubesi:@" "];
                [itemLine setAracGrubu:@" "];//sadece aracta
                [itemLine setAracRenk:@" "];//???renk kodu available aracta ff bilmnenmen?
                //TODO check addtional
                [itemLine setCKislastik:@" "];//??? X sadece arac satirinda olcak
                [itemLine setFiloSegment:@" "];// segment kod
                [itemLine setFiyat:tempEquipment.price];
                [itemLine setFiyatKodu:@" "]; //avail aracta donudo
                [itemLine setJatoMarka:@" "]; //avail arac
                [itemLine setJatoModel:@" "];//avail arac
                [itemLine setKalemTipi:@" "]; //update ici create de bos 1:farkl tes cikis 2:farkli tes donus 3: sure uzat 4: kisaltma
                [itemLine setKampanyaId:@" "]; //et_rezervdeki id
                [itemLine setMalzemeNo:tempEquipment.materialNumber]; //matnr
                [itemLine setMiktar:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
                [itemLine setParaBirimi:@"TRY"]; //konustuk bunu
                [itemLine setPlakaNo:@" "]; //sadece aracta aracı sectiyse
                [itemLine setRezBegda:_reservation.checkOutTime];//headerla ayni
                [itemLine setRezBegtime:[dateFormatter stringFromDate:_reservation.checkOutTime]];
                [itemLine setRezEndda:_reservation.checkInTime];
                [itemLine setRezEndtime:[dateFormatter stringFromDate:_reservation.checkInTime]];
                [itemLine setRezKalemNo:@" "]; //update icin create
                [itemLine setSasiNo:@" "]; // avail aractan
                [itemLine setSatisBurosu:@" "]; //chekout office
                [itemLine setTeslimSubesi:@" "];
                [itemLine setUpdateStatu:@" "]; // kullanilmior
                [itItem addObject:itemLine];
            }
        }
    }
    IT_FATURA_ADRESV0 *itFaturaAdresLine = [IT_FATURA_ADRESV0 new];
    [itFaturaAdresLine setAddrnumber:@" "];//???donen adreslerde var bu alan ordan alcan
    [itFaturaAdresLine setAdres:@" "];
    [itFaturaAdresLine setAdresKaydet:@" "];//????x yada bos
    [itFaturaAdresLine setAdresTanim:@" "];
    [itFaturaAdresLine setAyniAdres:@" "];//faturayla ayni adres
    [itFaturaAdresLine setFatTip:@" "];//???Bireysel mi 2-kurumsal mi
    [itFaturaAdresLine setFirmaAdi:@" "]; //2 ise
    [itFaturaAdresLine setFirstname:@" "];//1 ise
    [itFaturaAdresLine setIlcekod:@" "];
    [itFaturaAdresLine setIlkodu:@" "];
    [itFaturaAdresLine setLastname:@" "];//1 ise
    [itFaturaAdresLine setMiddlename:@" "];//1 ise
    [itFaturaAdresLine setPasaportno:@" "];//1 ise
    [itFaturaAdresLine setTckn:@" "];//1 ise
    [itFaturaAdresLine setUlke:@" "];//1 ise
    [itFaturaAdresLine setVergidairesi:@" "]; //2 ise
    [itFaturaAdresLine setVergino:@" "];//2 ise
    
    
    IT_SDREZERVV0 *sdRezervLine;
    NSMutableArray *itSdRezerv = [NSMutableArray new];
    for (ET_RESERVV0 *etReservLine in _reservation.etReserv) {
        sdRezervLine = [IT_SDREZERVV0 new];
        if ([etReservLine.Augru isEqualToString:@""]) {
            [sdRezervLine setAugru:@" "];
        }else{
            [sdRezervLine setAugru:etReservLine.Augru];
        }
        if ([etReservLine.BonusKazanir isEqualToString:@""]) {
            [sdRezervLine setBonusKazanir:@" "];
            
        }else{
            [sdRezervLine setBonusKazanir:etReservLine.BonusKazanir];
        }
        
        if ([etReservLine.FiyatKodu isEqualToString:@""]) {
            [sdRezervLine setFiyatKodu:@" "];
        }else{
            [sdRezervLine setFiyatKodu:etReservLine.FiyatKodu];
        }
        if ([etReservLine.GrnttlKazanir isEqualToString:@""]) {
            [sdRezervLine setGrnttlKazanir:@" "];
            
        }else{
            [sdRezervLine setGrnttlKazanir:etReservLine.GrnttlKazanir];
            
        }
        if ([etReservLine.GrupKodu isEqualToString:@""]) {
            [sdRezervLine setGrupKodu:@" "];
            
        }else{
            
            [sdRezervLine setGrupKodu:etReservLine.GrupKodu];
            
        }
        
        if ([etReservLine.Hdfsube isEqualToString:@""]) {
            [sdRezervLine setHdfsube:@" "];
            
        }else{
            [sdRezervLine setHdfsube:etReservLine.Hdfsube];
            
        }
        
        if ([etReservLine.Kunnr isEqualToString:@""]) {
            [sdRezervLine setKunnr:@" "];
        }else{
            [sdRezervLine setKunnr:etReservLine.Kunnr];
        }
        
        if ([etReservLine.Matnr isEqualToString:@""]) {
            [sdRezervLine setMatnr:@" "];
        }else{
            [sdRezervLine setMatnr:etReservLine.Matnr];
        }
        
        if ([etReservLine.MilKazanir isEqualToString:@""]) {
            [sdRezervLine setMilKazanir:@" "];
        }else{
            [sdRezervLine setMilKazanir:etReservLine.MilKazanir];
        }
        
        if ([etReservLine.RAuart isEqualToString:@""]) {
            [sdRezervLine setRAuart:@" "];
        }else{
            [sdRezervLine setRAuart:etReservLine.RAuart];
        }
        
        if ([etReservLine.RGjahr isEqualToString:@""]) {
            [sdRezervLine setRGjahr:@" "];
        }else{
            [sdRezervLine setRGjahr:etReservLine.RGjahr];
        }
        
        if ([etReservLine.RPosnr isEqualToString:@""]) {
            [sdRezervLine setRPosnr:@" "];
        }else{
            [sdRezervLine setRPosnr:etReservLine.RPosnr];
        }
        if ([etReservLine.RVbeln isEqualToString:@""]) {
            [sdRezervLine setRVbeln:@" "];
        }else{
            [sdRezervLine setRVbeln:etReservLine.RVbeln];
        }
        
        if ([etReservLine.Spart isEqualToString:@""]) {
            [sdRezervLine setSpart:@" "];
        }else{
            [sdRezervLine setSpart:etReservLine.Spart];
        }
        
        
        if ([etReservLine.Sube isEqualToString:@""]) {
            [sdRezervLine setSube:@" "];
        }else{
            [sdRezervLine setSube:etReservLine.Sube];
        }
        //humm bakalm bu datee
        [sdRezervLine setTarih:etReservLine.Tarih];
        [sdRezervLine setTutar:etReservLine.Tutar];
        if ([etReservLine.Vkorg isEqualToString:@""]) {
            [sdRezervLine setVkorg:@" "];
        }else{
            [sdRezervLine setVkorg:etReservLine.Vkorg];
        }
        
        if ([etReservLine.Vtweg isEqualToString:@""]) {
            [sdRezervLine setVtweg:@" "];
        }else{
            [sdRezervLine setVtweg:etReservLine.Vtweg];
        }
        
        [itSdRezerv addObject:sdRezervLine];
    }
    
    IT_TAHSILATV0 *itTahsilatLine = [IT_TAHSILATV0 new];
    [itTahsilatLine setAmount:[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES]];
    [itTahsilatLine setAy:_expirationMonthTextField.text];
    [itTahsilatLine setCompanyname:_nameOnCardTextField.text]; // adamin full ismi
    [itTahsilatLine setCustomerEmail:@" "];
    [itTahsilatLine setCustomerFullname:_nameOnCardTextField.text]; // adamin full ismi
    [itTahsilatLine setCustomerIp:[self getIPAddress]];//?
    [itTahsilatLine setGarentaTl:[NSDecimalNumber decimalNumberWithString:@"0.0"]]; //TODO: eklenecek
    [itTahsilatLine setGuvenlikkodu:_cvvTextField.text];
    [itTahsilatLine setIsPoint:@"X"]; //bonus ukardaki doluysa
    [itTahsilatLine setKartNumarasi:_creditCardNumberTextField.text];
    [itTahsilatLine setKartSahibi:_nameOnCardTextField.text];
    if ([[ApplicationProperties getUser] isLoggedIn]) {
        [itTahsilatLine setKunnr:[[ApplicationProperties getUser] kunnr]];
    }else{
        [itTahsilatLine setKunnr:@" "];
    }

    [itTahsilatLine setMerKey:@"  "]; // merchant safe key
    [itTahsilatLine setMusterionay:@" "]; //kk saklansin 10 kk saklanmasin 20
    [itTahsilatLine setOAwkey:@" "];
    [itTahsilatLine setOAwlog:@" "];
    [itTahsilatLine setOCode:@" "];
    [itTahsilatLine setOErrMessage:@" "];
    [itTahsilatLine setOIpt:@" "];
    [itTahsilatLine setOIpterr:@" "];
    [itTahsilatLine setOIpterrmes:@" "];
    [itTahsilatLine setOMessage:@" "];
    [itTahsilatLine setOMskayit:@" "];
    [itTahsilatLine setOPoint:@" "];
    [itTahsilatLine setOProv:@" "];
    [itTahsilatLine setOrderId:@" "];
    [itTahsilatLine setOSanal:@" "];
    [itTahsilatLine setOStatus:@" "];
    [itTahsilatLine setPoint:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    [itTahsilatLine setPointTutar:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    [itTahsilatLine setTahstip:@"K"]; //K kart cekim t teminat p provizyon
    [itTahsilatLine setVkbur:@" "];// bos crm cakmis
    [itTahsilatLine setYil:_expirationYearTextField.text];
    EsOutputV0 *esOutput = [EsOutputV0 new];
    [esOutput setAvail:@" "];
    [esOutput setEksurucuNo:@" "];
    [esOutput setFaturaMusteriNo:@" "];
    [esOutput setFtCikisBp:@" "];
    [esOutput setFtDonusBp:@" "];
    [esOutput setIsRegistered:@" "];
    [esOutput setMusterino:@" "];
    [esOutput setRezNo:@" "];
    [esOutput setTahsilDrm:@" "];
    ET_RETURNV0 *etReturnLine = [ET_RETURNV0 new];
    [etReturnLine setId:@" "];
    [etReturnLine setLogMsgNo:@"1"];
    [etReturnLine setLogNo:@"2"];
    [etReturnLine setMessage:@" "];
    [etReturnLine setMessageV1:@" "];
    [etReturnLine setMessageV2:@" "];
    [etReturnLine setMessageV3:@" "];
    [etReturnLine setMessageV4:@" "];
    [etReturnLine setNumber:@" "];
    [etReturnLine setType:@" "];
    [etReturnLine setParameter:@" "];
    [etReturnLine setRow:[NSNumber numberWithInt:1]];
    [etReturnLine setField:@" "];
    [etReturnLine setSystem:@" "];
    ET_KK_RETURNV0 *etKKReturnLine = [ET_KK_RETURNV0 new];
    [etKKReturnLine setOErrMessage:@" "];
    NSMutableArray *itFaturaAdres = [NSMutableArray new];
    NSMutableArray *itTahsilat = [NSMutableArray new];
    NSMutableArray *etReturn = [NSMutableArray new];
    [itFaturaAdres addObject:itFaturaAdresLine];
    [itTahsilat addObject:itTahsilatLine];
    [etReturn addObject:etReturnLine];
    [aService setIsInput:isInput];
    [aService setIsUserinfo:isUserInfo];
    [aService setIT_ARACLARSet:itAraclar];
    [aService setIT_EKSURUCUSet:itEksurucu];
    [aService setIT_FATURA_ADRESSet:itFaturaAdres];
    [aService setIT_ITEMSSet:itItem];
    [aService setIT_SDREZERVSet:itSdRezerv];
    [aService setIT_TAHSILATSet:itTahsilat];
    [aService setEvSubrc:[NSNumber numberWithInt:2]];
    [aService setEsOutput:esOutput];
    [aService setET_RETURNSet:etReturn];
    
    
    [aService setET_KK_RETURNSet:[NSMutableArray arrayWithObject:etKKReturnLine]];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[ZGARENTA_REZERVASYON_SRVRequestHandler uniqueInstance] createReservationService:aService];
    [[LoaderAnimationVC uniqueInstance] playAnimation:self.view];
}


- (void)parseReservationResponse:(NSNotification*)notification{
    ReservationServiceV0 *response = notification.userInfo[@"item"];
    UIAlertView *alert;
    if ([response.EvSubrc intValue]== 0) {
        [_reservation setReservationNumber:response.EsOutput.RezNo];
        alert = [[UIAlertView alloc] initWithTitle:@"Başarılı" message:[NSString stringWithFormat:@"%@ numaralı rezervasyonunuz başarıyla oluşturulmuştur.",_reservation.reservationNumber] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:@"Fahrettin/Ahmet hata alındı." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCreateReservationServiceCompletedNotification object:nil];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[LoaderAnimationVC uniqueInstance] stopAnimation];
        if ([response.EvSubrc intValue]== 0) {
            [self performSegueWithIdentifier:@"toReservationApprovalVCSegue" sender:self];
        }else{
            [alert show];
        }
    });
    
}

- (void)addObservers{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseReservationResponse:) name:kCreateReservationServiceCompletedNotification object:nil];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCreateReservationServiceCompletedNotification object:nil];
}

- (IBAction)reservationCompleteButtonPressed:(id)sender {
    if ([self checkRequiredFields])
    {
        [[self view] endEditing:YES];
        [self createReservation];
    }
//    }else{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uyarı" message:@"Lütfen zorunlu alanları doldurunuz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles: nil];
//        [alert show];
//    }
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
@end
