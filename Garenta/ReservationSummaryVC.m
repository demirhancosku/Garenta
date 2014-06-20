//
//  ReservationSummaryVC.m

//  Garenta

//
//  Created by Alp Keser on 6/9/14.    //  Copyright (c) 2014 Kerem Balaban. All rights reserved.
#import "ReservationSummaryVC.h"
#import "ZGARENTA_REZERVASYON_SRVRequestHandler.h"
#import "ZGARENTA_REZERVASYON_SRVServiceV0.h"
#import "PaymentTableViewController.h"
#import "AdditionalEquipment.h"

@interface ReservationSummaryVC ()

- (IBAction)payLaterButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *brandModelLabel;

@property (weak, nonatomic) IBOutlet UIImageView *carImageView;

@property (weak, nonatomic) IBOutlet UILabel *fuelLabel;

@property (weak, nonatomic) IBOutlet UILabel *transmissionLabel;

@property (weak, nonatomic) IBOutlet UILabel *acLabel;

@property (weak, nonatomic) IBOutlet UILabel *passangerNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *doorCountLabel;

@property (assign,nonatomic) BOOL isTotalPressed;

- (IBAction)payNowPressed:(id)sender;

- (IBAction)payLaterPressed:(id)sender;

@end



@implementation ReservationSummaryVC



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
    _isTotalPressed =NO;
    //    const CGFloat fontSize = 13;
    //    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    //    UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    //    UIColor *foregroundColor = [UIColor lightGrayColor];
    //
    //    // Create the attributes
    //    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
    //                           boldFont, NSFontAttributeName,
    //                           foregroundColor, NSForegroundColorAttributeName, nil];
    //    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
    //                              regularFont, NSFontAttributeName, nil];
    //    const NSRange range = NSMakeRange(8,12); // range of " 2012/10/14 ". Ideally this should not be hardcoded
    //
    //    // Create the attributed string (text + attributes)
    //    NSMutableAttributedString *attributedText =
    //    [[NSMutableAttributedString alloc] initWithString:@"osman ve digerleri rulez"
    //                                           attributes:attrs];
    //    [attributedText setAttributes:subAttrs range:range];
    //
    //    // Set it in our UILabel and we are done!
    //    [_brandModelLabel setAttributedText:attributedText];
    //rest
    [_carImageView setImage:_reservation.selectedCarGroup.sampleCar
     .image];
}



- (void)didReceiveMemoryWarning

{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - custom methods



/*
 
 -----------!BEWARE!----------
 
 */

- (void)createReservation{
    NSDateFormatter *dateFormatter =[NSDateFormatter new];
    [dateFormatter setDateFormat:@"hh:mm"];
    [ApplicationProperties configureReservationService];
    ReservationServiceV0 *aService = [ReservationServiceV0 new];
    IsInputV0 *isInput = [IsInputV0 new];
    [isInput setAlisSubesi:_reservation.checkInOffice.mainOfficeCode];
    [isInput setBonus:[NSDecimalNumber decimalNumberWithString:@"0.0"]];// yok
    [isInput setCCorpPriority:@" "];//X coorp priorityse x
    [isInput setCPriority:@" "];//X priority
    [isInput setFtCikisAdres:@" "];// free text
    [isInput setFtCikisIl:@" "]; //plaka
    [isInput setFtCikisIlce:@" "]; //ilce citykod crmden donen
    [isInput setFtDonusAdres:@" "]; //freetext
    [isInput setFtDonusIl:@" "];
    [isInput setFtDonusIlce:@" "];
    [isInput setFtMaliyetTipi:@" "];//???// masraf yansitilcak alinmiycak canlida yok
    [isInput setGarentaTl:[NSDecimalNumber decimalNumberWithString:@"0.0"]]; //free
    [isInput setGunSayisi:_reservation.selectedCarGroup.sampleCar.pricing.dayCount]; //available aractan donen gun sayisi*
    [isInput setMilesSmiles:[NSDecimalNumber decimalNumberWithString:@"0.0"]]; //
    [isInput setOdemeTuru:@"2"];//1,2,3 hemen ödeme sonra öde ön ödemeli iptal edilemez
    [isInput setParaBirimi:@"TRY"]; //TRY EUR USD GBP
    [isInput setPuanTipi:@" "];//?? M ıse mıl G ıse garenta tl
    [isInput setRezBegda:_reservation.checkOutTime];
    [isInput setRezBegtime:[dateFormatter stringFromDate:_reservation.checkOutTime]];
    [isInput setRezEndda:[_reservation checkInTime]];
    [isInput setRezEndtime:[dateFormatter stringFromDate:_reservation.checkInTime]];
    [isInput setRezKanal:@"40"]; //Mobil 40
    [isInput setRezNo:@" "];
    [isInput setSatisBurosu:_reservation.checkOutOffice.mainOfficeCode];// checkout office
    [isInput setTeslimSubesi:_reservation.checkInOffice.mainOfficeCode];
    [isInput setToplamTutar:[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO]];
    [isInput setUsername:@" "];
    User *currentUser = (User*)[ApplicationProperties getUser];
    IsUserinfoV0 *isUserInfo = [IsUserinfoV0 new];
    [isUserInfo setAdress:@" "]; //il ilce adres zorunlu
    [isUserInfo setBirthdate:[ currentUser birthday]];
    [isUserInfo setCinsiyet:[currentUser gender]];//???1 erkek 2 kadın
    [isUserInfo setSalesOrganization:@"3063"];//????fix
    [isUserInfo setDistributionChannel:@"33"];//???3063 fix
    [isUserInfo setDivision:@"65"];//???fix
    [isUserInfo setEhliyetAlisyeri:@" "];//free zorunlu?
    [isUserInfo setEhliyetNo:@" "];//free zorunlu?
    [isUserInfo setEhliyetSinifi:@" "];//combo sabit siteden bak
    [isUserInfo setEhliyetTarihi:[NSDate date]];
    [isUserInfo setEmail:currentUser.email]; //zoeunlu
    [isUserInfo setFirstname:currentUser.name];
    [isUserInfo setIlcekod:@" "];//ilce kod rfcsiden alcak
    [isUserInfo setIlkodu:@" "];
    [isUserInfo setKanalturu:@"Z07"]; // sabit
    [isUserInfo setLastname:currentUser.surname];
    [isUserInfo setMiddlename:@" "];
    [isUserInfo setMusterino:@" "]; //kunnr loginse must
    //birinden biri
    //nationalitye gore
    [isUserInfo setPasaportno:@" "];
    [isUserInfo setTckn:currentUser.tckno];
    [isUserInfo setTelno:currentUser.mobile]; //no533
    [isUserInfo setTelnoUlke:@"90"];//90
    [isUserInfo setTkKartno:@" "];//???tk almıyoruz
    [isUserInfo setUlke:@"TR"];//??? TR yada bos
    [isUserInfo setUyruk:@"TR"];//???? tr veya boş
    [isUserInfo setVergino:@" "]; //free text siniri 11
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
                [itemLine setAlisSubesi:_reservation.checkOutOffice.mainOfficeCode];
                [itemLine setAracGrubu:_reservation.selectedCarGroup.groupCode];//sadece aracta
                [itemLine setAracRenk:@" "];//???renk kodu available aracta ff bilmnenmen?
                //TODO check addtional
                [itemLine setCKislastik:@" "];//??? X sadece arac satirinda olcak
                [itemLine setFiloSegment:_reservation.selectedCarGroup.segment];// segment kod
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
                [itemLine setSatisBurosu:_reservation.checkOutOffice.mainOfficeCode]; //chekout office
                [itemLine setTeslimSubesi:_reservation.checkInOffice.mainOfficeCode];
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
    //Arac ekliyorum
    itemLine = [IT_ITEMSV0 new];
    [itemLine setAlisSubesi:_reservation.checkOutOffice.mainOfficeCode];
    [itemLine setAracGrubu:_reservation.selectedCarGroup.groupCode];//sadece aracta
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
        [itemLine setMalzemeNo:_reservation.selectedCar.materialCode]; //matnr
        [itemLine setJatoMarka:@" "]; //avail arac
        [itemLine setJatoModel:@" "];//avail arac
    }
    [itemLine setRezBegda:_reservation.checkOutTime];//headerla ayni
    [itemLine setRezBegtime:[dateFormatter stringFromDate:_reservation.checkOutTime]];
    [itemLine setRezEndda:_reservation.checkInTime];
    [itemLine setRezEndtime:[dateFormatter stringFromDate:_reservation.checkInTime]];
    [itemLine setRezKalemNo:@" "]; //update icin create
    [itemLine setSasiNo:@" "]; // avail aractan
    [itemLine setSatisBurosu:_reservation.checkOutOffice.mainOfficeCode]; //chekout office
    [itemLine setTeslimSubesi:_reservation.checkInOffice.mainOfficeCode];
    [itemLine setUpdateStatu:@" "]; // kullanilmior
    IT_SDREZERVV0 *sdRezervLine;
    NSMutableArray *itSdRezerv = [NSMutableArray new];
    for (ET_RESERVV0 *etReservLine in _reservation.etReserv) {
        sdRezervLine = [IT_SDREZERVV0 new];
        [sdRezervLine setAugru:etReservLine.Augru];
        [sdRezervLine setBonusKazanir:etReservLine.BonusKazanir];
        [sdRezervLine setFiyatKodu:etReservLine.FiyatKodu];
        [sdRezervLine setGrnttlKazanir:etReservLine.GrnttlKazanir];
        [sdRezervLine setGrupKodu:etReservLine.GrupKodu];
        [sdRezervLine setHdfsube:etReservLine.Hdfsube];
        [sdRezervLine setKunnr:etReservLine.Kunnr];
        [sdRezervLine setMatnr:etReservLine.Matnr];
        [sdRezervLine setMilKazanir:etReservLine.MilKazanir];
        [sdRezervLine setRAuart:etReservLine.RAuart];
        [sdRezervLine setRGjahr:etReservLine.RGjahr];
        [sdRezervLine setRPosnr:etReservLine.RPosnr];
        [sdRezervLine setRVbeln:etReservLine.RVbeln];
        [sdRezervLine setSpart:etReservLine.Spart];
        [sdRezervLine setSube:etReservLine.Sube];
        [sdRezervLine setTarih:etReservLine.Tarih];
        [sdRezervLine setTutar:etReservLine.Tutar];
        [sdRezervLine setVkorg:etReservLine.Vkorg];
        [sdRezervLine setVtweg:etReservLine.Vtweg];
        [itSdRezerv addObject:sdRezervLine];
    }
    IT_TAHSILATV0 *itTahsilatLine = [IT_TAHSILATV0 new];
    [itTahsilatLine setAmount:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    [itTahsilatLine setAy:@"10"];
    [itTahsilatLine setCompanyname:@"CompName"]; // adamin full ismi
    [itTahsilatLine setCustomerEmail:@"alp@alp.com"];
    [itTahsilatLine setCustomerFullname:@"Yusuf Alp Keser"]; // adamin full ismi
    [itTahsilatLine setCustomerIp:@"10.90.30.12"];
    [itTahsilatLine setGarentaTl:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    [itTahsilatLine setGuvenlikkodu:@"344"];
    [itTahsilatLine setIsPoint:@"X"]; //bonus ukardaki doluysa
    [itTahsilatLine setKartNumarasi:@"4565467645646764"];
    [itTahsilatLine setKartSahibi:@"Yusuf Alp Keser"];
    [itTahsilatLine setKunnr:@"1234567890"];
    [itTahsilatLine setMerKey:@"123"]; // merchant safe key
    [itTahsilatLine setMusterionay:@"X"]; //kk saklansin 10 kk saklanmasin 20
    [itTahsilatLine setOAwkey:@" "];
    [itTahsilatLine setOAwlog:@" "];
    [itTahsilatLine setOCode:@" "];
    [itTahsilatLine setOErrMessage:@"Err msg "];
    [itTahsilatLine setOIpt:@"O"];
    [itTahsilatLine setOIpterr:@"1"];
    [itTahsilatLine setOIpterrmes:@"a"];
    [itTahsilatLine setOMessage:@"Message"];
    [itTahsilatLine setOMskayit:@"a"];
    [itTahsilatLine setOPoint:@" "];
    [itTahsilatLine setOProv:@"x"];
    [itTahsilatLine setOrderId:@"12"];
    [itTahsilatLine setOSanal:@"X"];
    [itTahsilatLine setOStatus:@"s"];
    [itTahsilatLine setPoint:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    [itTahsilatLine setPointTutar:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    [itTahsilatLine setTahstip:@"1"]; //K kart cekim t teminat p provizyon
    [itTahsilatLine setVkbur:@"1023"];// bos crm cakmis
    [itTahsilatLine setYil:@"2014"];
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
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[NSNotificationCenter defaultCenter] addObserverForName:kCreateReservationServiceCompletedNotification object:nil queue:operationQueue usingBlock:^(NSNotification *notification){
        //handle req
    }];
    [[ZGARENTA_REZERVASYON_SRVRequestHandler uniqueInstance] createReservationService:aService];
}



#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isTotalPressed) {
        return 4;
    }
    return 3;
}



// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:

// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *aCell;
    if (!_isTotalPressed) {
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                break;
            case 1:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
                break;
            case 2:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"totalPaymentCell" forIndexPath:indexPath];
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                break;
            case 1:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
                break;
            case 2:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"detailPayNowLaterCell" forIndexPath:indexPath];
                break;
            case 3:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"payNowLaterButtonsCell" forIndexPath:indexPath];
                break;
            default:
                break;
        }
    }
    return aCell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
     UITableViewCell *aCell = [tableView cellForRowAtIndexPath:indexPath];
     if (aCell.tag) {
     <#statements#>
     }
     */
    if (!_isTotalPressed) {
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
    }else{
        switch (indexPath.row) {
            case 0:
                return 92;
                break;
            case 1:
                return 35;
                break;
            case 2:
                return 35;
                break;
            case 3:
                return 50;
                break;
            default:
                return 60;
                break;
        }
    }
    return 60;
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:
            //popover
            break;
        case 2:
            [self totalButtonPressed];
            break;
        default:
            break;
    }
}



#pragma mark - Navigation



// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender

{
    if ([[segue identifier] isEqualToString:@"toPaymentVCSegue"]) {
        [(PaymentTableViewController*)[segue destinationViewController] setReservation:_reservation];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (void)totalButtonPressed{
    if (_isTotalPressed) {
        _isTotalPressed = NO;
    }else{
        _isTotalPressed = YES;
    }
    //    [_tableView reloadData];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}





- (IBAction)payNowPressed:(id)sender {
    //nav to payment
    [self performSegueWithIdentifier:@"toPaymentVCSegue" sender:self];
}



- (IBAction)payLaterPressed:(id)sender {
    [self createReservation];
}

@end

