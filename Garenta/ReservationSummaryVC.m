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
#import "ReservationApprovalVC.h"
#import "ReservationScopePopoverVC.h"

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
@property (weak, nonatomic) IBOutlet UILabel *checkOutOfficeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *checkOutTimeLablel;//dd.MM.yyyy/hh:mm
//@property (weak, nonatomic) IBOutlet UILabel *checkInOfficeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *checkInTimeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
//@property (weak, nonatomic) IBOutlet UIButton *payNowButton;
//@property (weak, nonatomic) IBOutlet UIButton *payLaterButton;//xxxx.xx TL


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
    //preping ui
    _isTotalPressed =NO;
    //model marka label
    
    const CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    UIColor *foregroundColor = [UIColor lightGrayColor];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              boldFont, NSFontAttributeName, nil];
    NSString *brandModelString;
    int boldLenght = 0;
    if (_reservation.selectedCar) {
        brandModelString = [NSString stringWithFormat:@"%@ %@",_reservation.selectedCar.brandName,_reservation.selectedCar.modelName];
        boldLenght = brandModelString.length;
    }else{
        brandModelString = [NSString stringWithFormat:@"%@ %@",_reservation.selectedCarGroup.sampleCar.brandName, _reservation.selectedCarGroup.sampleCar.modelName];
        boldLenght = brandModelString.length;
        brandModelString = [NSString stringWithFormat:@"%@ yada benzeri",brandModelString];
    }
    
    const NSRange range = NSMakeRange(0,boldLenght); // range of " 2012/10/14 ". Ideally this should not be hardcoded
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:brandModelString
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        [_brandModelLabel setAttributedText:attributedText];
    
    [_carImageView setImage:_reservation.selectedCarGroup.sampleCar
     .image];
    [_fuelLabel setText:_reservation.selectedCarGroup.fuelName];
    [_transmissionLabel setText:_reservation.selectedCarGroup.transmissonName];
    [_acLabel setText:@"Klima"];
    [_passangerNumberLabel setText:_reservation.selectedCarGroup.sampleCar.passangerNumber];
    [_doorCountLabel setText:_reservation.selectedCarGroup.sampleCar.doorNumber];
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



#pragma mark - custom methods



/*
 
 -----------!BEWARE!----------
 
 */

- (void)createReservation{
    NSDateFormatter *dateFormatter =[NSDateFormatter new];
    [dateFormatter setDateFormat:@"HH:mm"];
    [ApplicationProperties configureReservationService];
    ReservationServiceV0 *aService = [ReservationServiceV0 new];
    IsInputV0 *isInput = [IsInputV0 new];
    [ApplicationProperties fillProperties:isInput];
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
    [isInput setToplamTutar:[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO andGarentaTl:@"0"]];
    [isInput setUsername:@" "];
    User *currentUser = (User*)[ApplicationProperties getUser];
    IsUserinfoV0 *isUserInfo = [IsUserinfoV0 new];
    [ApplicationProperties fillProperties:isUserInfo];
    [isUserInfo setAdress:@" "]; //il ilce adres zorunlu
    [isUserInfo setSalesOrganization:@"3063"];//????fix
    [isUserInfo setDistributionChannel:@"33"];//???3063 fix
    [isUserInfo setDivision:@"65"];//???fix
    [isUserInfo setEhliyetAlisyeri:@" "];//free zorunlu?
    [isUserInfo setEhliyetNo:@" "];//free zorunlu?
    [isUserInfo setEhliyetSinifi:@" "];//combo sabit siteden bak
    [isUserInfo setEhliyetTarihi:[NSDate date]];
    [isUserInfo setIlcekod:@" "];//ilce kod rfcsiden alcak
    [isUserInfo setIlkodu:@" "];
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
    [isUserInfo setTkKartno:@" "];//???tk almıyoruz
    [isUserInfo setUlke:@"TR"];//??? TR yada bos
    [isUserInfo setUyruk:@"TR"];//???? tr veya boş
    [isUserInfo setVergino:@" "]; //free text siniri 11
    [isUserInfo setInboundcallid:@" "];
    [isUserInfo setCalluser:@" "];
    [isUserInfo setArayan:@" "];
    
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
    UILabel *checkOutOffice;
    UILabel *checkInOffice;
    UILabel *checkOutTime;
    UILabel *checkInTime;
    UILabel *totalPrice;
    UIButton *payNowButton;
    UIButton *payLaterButton;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM.yyy/HH:mm"];
    if (!_isTotalPressed) {
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                
                checkOutOffice = (UILabel*)[aCell viewWithTag:1];
                [checkOutOffice setText:_reservation.checkOutOffice.mainOfficeName];
                
                checkOutTime = (UILabel*)[aCell viewWithTag:2];
                [checkOutTime setText:[dateFormatter stringFromDate:_reservation.checkOutTime]];
                
                checkInOffice = (UILabel*)[aCell viewWithTag:3];
                [checkInOffice setText:_reservation.checkInOffice.mainOfficeName];
                
                checkInTime = (UILabel*)[aCell viewWithTag:4];
                [checkInTime setText:[dateFormatter stringFromDate:_reservation.checkInTime]];
                
                break;
            case 1:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
                break;
            case 2:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"totalPaymentCell" forIndexPath:indexPath];
                totalPrice = (UILabel*)[aCell viewWithTag:1];
                [totalPrice setText:[NSString stringWithFormat:@"%@",[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"0"]]];
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"officeDateCell" forIndexPath:indexPath];
                
                checkOutOffice = (UILabel*)[aCell viewWithTag:1];
                [checkOutOffice setText:_reservation.checkOutOffice.mainOfficeName];
                
                checkOutTime = (UILabel*)[aCell viewWithTag:2];
                [checkOutTime setText:[dateFormatter stringFromDate:_reservation.checkOutTime]];
                
                checkInOffice = (UILabel*)[aCell viewWithTag:3];
                [checkInOffice setText:_reservation.checkInOffice.mainOfficeName];
                
                checkInTime = (UILabel*)[aCell viewWithTag:4];
                [checkInTime setText:[dateFormatter stringFromDate:_reservation.checkInTime]];
                
                break;
            case 1:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"serviceScopeCell" forIndexPath:indexPath];
                break;
            case 2:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"detailPayNowLaterCell" forIndexPath:indexPath];
                break;
            case 3:
                aCell = [tableView dequeueReusableCellWithIdentifier:@"payNowLaterButtonsCell" forIndexPath:indexPath];
                payNowButton = (UIButton*)[aCell viewWithTag:1];
                payLaterButton = (UIButton*)[aCell viewWithTag:2];
                [payNowButton setTitle:[NSString stringWithFormat:@"%@ TL",[_reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"0"]] forState:UIControlStateNormal];
                [payLaterButton setTitle:[NSString stringWithFormat:@"%@ TL",[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO andGarentaTl:@"0"]] forState:UIControlStateNormal];
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
            [self performSegueWithIdentifier:@"toPopoverVCSegue" sender:(UITableViewCell*)[_tableView cellForRowAtIndexPath:indexPath]];
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
    if ([[segue identifier] isEqualToString:@"toReservationApprovalVCSegue"]) {
        [(ReservationApprovalVC*)[segue destinationViewController] setReservation:_reservation];
    }
    
    if ([segue.identifier isEqualToString:@"toPopoverVCSegue"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.preferredContentSize = CGSizeMake(280, 280);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        [(ReservationScopePopoverVC *)[segue destinationViewController] setReservation:_reservation];
        
        popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        popoverController.delegate = self;
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

- (void)addObservers{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseReservationResponse:) name:kCreateReservationServiceCompletedNotification object:nil];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCreateReservationServiceCompletedNotification object:nil];
}

- (void)sendMailToCRM:(NSString*)errMsg{
    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    
    NSString *body = @"&body=Rezervasyon yaratırken hata aldım!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
}
@end

