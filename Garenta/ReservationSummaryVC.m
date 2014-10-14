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
#import "SDReservObject.h"
#import "MBProgressHUD.h"

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
    
    _isTotalPressed =NO;
    
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
    
    const NSRange range = NSMakeRange(0,boldLenght);
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

#pragma mark - rezervasyon

/*
- (void)createReservationAtSAP {

    @try {
        SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_CREATE_REZERVASYON"];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDateFormatter *timeFormatter = [NSDateFormatter new];
        [timeFormatter setDateFormat:@"HH:mm"];
        
        // IS_INPUT
        
        NSArray *isInputColumns = @[@"REZ_NO", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"ODEME_TURU", @"GARENTA_TL", @"BONUS", @"MILES_SMILES", @"GUN_SAYISI", @"TOPLAM_TUTAR", @"C_PRIORITY", @"C_CORP_PRIORITY", @"REZ_KANAL", @"FT_CIKIS_IL", @"FT_CIKIS_ILCE", @"FT_CIKIS_ADRES", @"FT_DONUS_IL", @"FT_DONUS_ILCE", @"FT_DONUS_ADRES", @"PARA_BIRIMI", @"FT_MALIYET_TIPI", @"USERNAME", @"PUAN_TIPI", @"UCUS_SAATI", @"UCUS_NO", @"ODEME_BICIMI", @"FATURA_ACIKLAMA", @"EMAIL_CONFIRM", @"TELNO_CONFIRM"];
        
        NSString *isPriority = @"";
        
        if ([[ApplicationProperties getUser] isPriority]) {
            isPriority = @"X";
        }
        
        // satış burosunu onurla konuşcam
        NSArray *isInputValues = @[@"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode,  @"2", @"", @"", @"", [_reservation.selectedCarGroup.sampleCar.pricing.dayCount stringValue], [[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO] stringValue], isPriority, @"", @"40", @"", @"", @"", @"", @"", @"", @"TRY", @"", @"", @"", @"", @"", @"", @"", @"", @""];
        [handler addImportStructure:@"IS_INPUT" andColumns:isInputColumns andValues:isInputValues];
        
        // IS_USERINFO
        
        NSString *alertString = @"";
        
        @try {
            SAPJSONHandler *handler = [[SAPJSONHandler alloc] initConnectionURL:[ConnectionProperties getCRMHostName] andClient:[ConnectionProperties getCRMClient] andDestination:[ConnectionProperties getCRMDestination] andSystemNumber:[ConnectionProperties getCRMSystemNumber] andUserId:[ConnectionProperties getCRMUserId] andPassword:[ConnectionProperties getCRMPassword] andRFCName:@"ZNET_CREATE_REZERVASYON"];
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDateFormatter *timeFormatter = [NSDateFormatter new];
            [timeFormatter setDateFormat:@"HH:mm"];
            
            // IS_INPUT
            
            NSArray *isInputColumns = @[@"REZ_NO", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"ODEME_TURU", @"GARENTA_TL", @"BONUS", @"MILES_SMILES", @"GUN_SAYISI", @"TOPLAM_TUTAR", @"C_PRIORITY", @"C_CORP_PRIORITY", @"REZ_KANAL", @"FT_CIKIS_IL", @"FT_CIKIS_ILCE", @"FT_CIKIS_ADRES", @"FT_DONUS_IL", @"FT_DONUS_ILCE", @"FT_DONUS_ADRES", @"PARA_BIRIMI", @"FT_MALIYET_TIPI", @"USERNAME", @"PUAN_TIPI", @"UCUS_SAATI", @"UCUS_NO", @"ODEME_BICIMI", @"FATURA_ACIKLAMA", @"EMAIL_CONFIRM", @"TELNO_CONFIRM"];
            
            NSString *isPriority = @"";
            
            if ([[ApplicationProperties getUser] isPriority]) {
                isPriority = @"X";
            }
            
            // satış burosunu onurla konuşcam
            NSArray *isInputValues = @[@"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode,  @"2", @"", @"", @"", [_reservation.selectedCarGroup.sampleCar.pricing.dayCount stringValue], [[_reservation totalPriceWithCurrency:@"TRY" isPayNow:NO andGarentaTl:nil] stringValue], isPriority, @"", @"40", @"", @"", @"", @"", @"", @"", @"TRY", @"", @"", @"", @"", @"", @"", @"", @"", @""];
            [handler addImportStructure:@"IS_INPUT" andColumns:isInputColumns andValues:isInputValues];
            
            // IS_USERINFO
            
            NSArray *isUserInfoColumns;
            NSArray *isUserInfoValues;
            
            if ([[ApplicationProperties getUser] isLoggedIn]) {
                isUserInfoColumns = @[@"MUSTERINO"];
                isUserInfoValues = @[[[ApplicationProperties getUser] kunnr]];
            }
            else {
                
                isUserInfoColumns = @[@"MUSTERINO", @"CINSIYET", @"FIRSTNAME", @"LASTNAME", @"BIRTHDATE", @"TCKN", @"VERGINO", @"ADRESS", @"EMAIL", @"TELNO", @"UYRUK", @"ULKE", @"SALES_ORGANIZATION", @"DISTRIBUTION_CHANNEL", @"DIVISION", @"KANALTURU", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"EHLIYET_NO", @"EHLIYET_TARIHI", @"ILKODU", @"ILCEKOD", @"MIDDLENAME", @"PASAPORTNO", @"TK_KARTNO", @"TELNO_ULKE"];
                isUserInfoValues = @[@""];
                
                return;// Şimdilik
            }
            
            [handler addImportStructure:@"IS_USERINFO" andColumns:isUserInfoColumns andValues:isUserInfoValues];
            
            // IT_ARACLAR
            NSArray *itAraclarColumns = @[@"MATNR"];
            NSMutableArray *itAraclarValues = [NSMutableArray new];
            
            for (Car *tempCar in _reservation.selectedCarGroup.cars) {
                NSArray *arr = @[[tempCar materialCode]];
                [itAraclarValues addObject:arr];
            }
            
            [handler addTableForImport:@"IT_ARACLAR" andColumns:itAraclarColumns andValues:itAraclarValues];
            
            // IT_ITEMS
            NSArray *itItemsColumns = @[@"REZ_KALEM_NO", @"MALZEME_NO", @"MIKTAR", @"ARAC_GRUBU", @"ALIS_SUBESI", @"TESLIM_SUBESI", @"SATIS_BUROSU", @"KAMPANYA_ID", @"FIYAT", @"C_KISLASTIK", @"ARAC_RENK", @"SASI_NO", @"PLAKA_NO", @"JATO_MARKA", @"JATO_MODEL", @"FILO_SEGMENT", @"FIYAT_KODU", @"UPDATE_STATU", @"REZ_BEGDA", @"REZ_ENDDA", @"REZ_BEGTIME", @"REZ_ENDTIME", @"KALEM_TIPI", @"PARA_BIRIMI", @"IS_AYLIK", @"KURUM_BIREYSEL"];
            
            NSMutableArray *itItemsValues = [NSMutableArray new];
            
            // ARAÇ
            
            NSString *aracGrubu = @"";
            NSString *malzemeNo = @"";
            NSString *jatoMarka = @"";
            NSString *jatoModel = @"";
            
            if (_reservation.selectedCar != nil) {
                malzemeNo = _reservation.selectedCar.materialCode;
                jatoMarka = _reservation.selectedCar.brandId;
                jatoModel = _reservation.selectedCar.modelId;
            }
            else {
                aracGrubu = _reservation.selectedCarGroup.groupCode;
            }
            
            NSArray *vehicleLine = @[@"", malzemeNo, @"1", aracGrubu, _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", _reservation.selectedCarGroup.payLaterPrice, @"", @"", @"", @"", jatoMarka, jatoModel, _reservation.selectedCarGroup.segment, @"", @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
            
            [itItemsValues addObject:vehicleLine];
            
            // Ekipmanlar, Hizmetler
            
            for (AdditionalEquipment *tempEquipment in _reservation.additionalEquipments) {
                for (int count = 0; count < tempEquipment.quantity; count++) {
                    NSArray *equipmentLine = @[@"", tempEquipment.materialNumber, @"1", @"", _reservation.checkOutOffice.subOfficeCode, _reservation.checkInOffice.subOfficeCode, _reservation.checkOutOffice.subOfficeCode, @"", [tempEquipment.price stringValue], @"", @"", @"", @"", @"", @"", @"", @"", @"", [dateFormatter stringFromDate:_reservation.checkOutTime], [dateFormatter stringFromDate:_reservation.checkInTime], [timeFormatter stringFromDate:_reservation.checkOutTime], [timeFormatter stringFromDate:_reservation.checkInTime], @"", @"TRY", @"", @""];
                    
                    [itItemsValues addObject:equipmentLine];
                }
            }
        }
        
        [handler addTableForImport:@"IT_ITEMS" andColumns:itItemsColumns andValues:itItemsValues];

        
        // IT_EKSURUCU
        NSArray *itEkSurucuColumns = @[@"CINSIYET", @"FIRSTNAME", @"LASTNAME", @"BIRTHDATE", @"TCKN", @"TELNO", @"UYRUK", @"ULKE", @"EHLIYET_ALISYERI", @"EHLIYET_SINIFI", @"EHLIYET_NO", @"EHLIYET_TARIHI", @"EKSURUCU_NO", @"UPDATE_STATU", @"KALEM_NO"];
        
        NSMutableArray *itEkSurucuValues = [NSMutableArray new];
        
//        for (User *additionalDriver in _reservation.additionalDrivers) {
//            
//        }
        
        if ([itEkSurucuValues count] > 0) {
            [handler addTableForImport:@"IT_EKSURUCU" andColumns:itEkSurucuColumns andValues:itEkSurucuValues];
        }
        
        
//        IT_SDREZERVV0 *sdRezervLine;
//        NSMutableArray *itSdRezerv = [NSMutableArray new];
//        for (ET_RESERVV0 *etReservLine in _reservation.etReserv) {
//            sdRezervLine = [IT_SDREZERVV0 new];
//            if ([etReservLine.Augru isEqualToString:@""]) {
//                [sdRezervLine setAugru:@" "];
//            }else{
//                [sdRezervLine setAugru:etReservLine.Augru];
//            }
//            if ([etReservLine.BonusKazanir isEqualToString:@""]) {
//                [sdRezervLine setBonusKazanir:@" "];
//                
//            }else{
//                [sdRezervLine setBonusKazanir:etReservLine.BonusKazanir];
//            }
//            
//            if ([etReservLine.FiyatKodu isEqualToString:@""]) {
//                [sdRezervLine setFiyatKodu:@" "];
//            }else{
//                [sdRezervLine setFiyatKodu:etReservLine.FiyatKodu];
//            }
//            if ([etReservLine.GrnttlKazanir isEqualToString:@""]) {
//                [sdRezervLine setGrnttlKazanir:@" "];
//                
//            }else{
//                [sdRezervLine setGrnttlKazanir:etReservLine.GrnttlKazanir];
//                
//            }
//            if ([etReservLine.GrupKodu isEqualToString:@""]) {
//                [sdRezervLine setGrupKodu:@" "];
//                
//            }else{
//                
//                [sdRezervLine setGrupKodu:etReservLine.GrupKodu];
//                
//            }
//            
//            if ([etReservLine.Hdfsube isEqualToString:@""]) {
//                [sdRezervLine setHdfsube:@" "];
//                
//            }else{
//                [sdRezervLine setHdfsube:etReservLine.Hdfsube];
//                
//            }
//            
//            if ([etReservLine.Kunnr isEqualToString:@""]) {
//                [sdRezervLine setKunnr:@" "];
//            }else{
//                [sdRezervLine setKunnr:etReservLine.Kunnr];
//            }
//            
//            if ([etReservLine.Matnr isEqualToString:@""]) {
//                [sdRezervLine setMatnr:@" "];
//            }else{
//                [sdRezervLine setMatnr:etReservLine.Matnr];
//            }
//            
//            if ([etReservLine.MilKazanir isEqualToString:@""]) {
//                [sdRezervLine setMilKazanir:@" "];
//            }else{
//                [sdRezervLine setMilKazanir:etReservLine.MilKazanir];
//            }
//            
//            if ([etReservLine.RAuart isEqualToString:@""]) {
//                [sdRezervLine setRAuart:@" "];
//            }else{
//                [sdRezervLine setRAuart:etReservLine.RAuart];
//            }
//            
//            if ([etReservLine.RGjahr isEqualToString:@""]) {
//                [sdRezervLine setRGjahr:@" "];
//            }else{
//                [sdRezervLine setRGjahr:etReservLine.RGjahr];
//            }
//            
//            if ([etReservLine.RPosnr isEqualToString:@""]) {
//                [sdRezervLine setRPosnr:@" "];
//            }else{
//                [sdRezervLine setRPosnr:etReservLine.RPosnr];
//            }
//            if ([etReservLine.RVbeln isEqualToString:@""]) {
//                [sdRezervLine setRVbeln:@" "];
//            }else{
//                [sdRezervLine setRVbeln:etReservLine.RVbeln];
//            }
//            
//            if ([etReservLine.Spart isEqualToString:@""]) {
//                [sdRezervLine setSpart:@" "];
//            }else{
//                [sdRezervLine setSpart:etReservLine.Spart];
//            }
//            
//            
//            if ([etReservLine.Sube isEqualToString:@""]) {
//                [sdRezervLine setSube:@" "];
//            }else{
//                [sdRezervLine setSube:etReservLine.Sube];
//            }
//            //humm bakalm bu datee
//            [sdRezervLine setTarih:etReservLine.Tarih];
//            [sdRezervLine setTutar:etReservLine.Tutar];
//            if ([etReservLine.Vkorg isEqualToString:@""]) {
//                [sdRezervLine setVkorg:@" "];
//            }else{
//                [sdRezervLine setVkorg:etReservLine.Vkorg];
//            }
//            
//            if ([etReservLine.Vtweg isEqualToString:@""]) {
//                [sdRezervLine setVtweg:@" "];
//            }else{
//                [sdRezervLine setVtweg:etReservLine.Vtweg];
//            }
//            
//            [itSdRezerv addObject:sdRezervLine];
//        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}
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
            }
            
            if ([itEkSurucuValues count] > 0) {
                [handler addTableForImport:@"IT_EKSURUCU" andColumns:itEkSurucuColumns andValues:itEkSurucuValues];
            }
            
            // IT_SD Reserv
            
            NSArray *itSDReservColumns = @[@"SUBE", @"GRUP_KODU", @"FIYAT_KODU", @"TARIH", @"R_VBELN", @"R_POSNR", @"R_GJAHR", @"R_AUART", @"MATNR", @"KUNNR", @"HDFSUBE", @"AUGRU", @"VKORG", @"VTWEG", @"SPART", @"TUTAR", @"GRNTTL_KAZANIR", @"MIL_KAZANIR", @"BONUS_KAZANIR"];
            
            NSMutableArray *itSDReservValues = [NSMutableArray new];
            
            for (SDReservObject *tempObject in _reservation.etReserv) {
                if ([tempObject.office isEqualToString:_reservation.checkOutOffice.subOfficeCode] && [tempObject.groupCode isEqualToString:_reservation.selectedCarGroup.groupCode]) {
                    NSArray *arr = @[tempObject.office, tempObject.groupCode, tempObject.priceCode, tempObject.date, tempObject.rVbeln, tempObject.rPosnr, tempObject.RGjahr, tempObject.rAuart, tempObject.matnr, tempObject.kunnr, tempObject.destinationOffice, tempObject.augru, tempObject.vkorg, tempObject.vtweg, tempObject.spart, tempObject.price, tempObject.isGarentaTl, tempObject.isMiles, tempObject.isBonus];
                    [itSDReservValues addObject:arr];
                }
            }
            
            [handler addTableForImport:@"IT_SDREZERV" andColumns:itSDReservColumns andValues:itSDReservValues];
            
            [handler addTableForReturn:@"ET_RETURN"];
            [handler addTableForReturn:@"ET_KK_RETURN"];
            
            NSDictionary *response = [handler prepCall];
            
            if (response != nil) {
                NSDictionary *export = [response objectForKey:@"EXPORT"];
                
                NSString *subrc = [export valueForKey:@"EV_SUBRC"];
                
                if ([subrc isEqualToString:@"0"]) {
                    NSDictionary *esOutput = [export objectForKey:@"ZNET_INT_S007"];
                    
                    NSString *reservationNo = [esOutput valueForKey:@"REZ_NO"];
                    _reservation.reservationNumber = reservationNo;
                }
                else {
                    alertString = @"Rezervasyon yaratımı sırasında hata oluştu. Lütfen tekrar deneyiniz";
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![alertString isEqualToString:@""]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hata" message:alertString delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
                        [alert show];
                    }
                    else if (_reservation.reservationNumber != nil && ![_reservation.reservationNumber isEqualToString:@""]) {
                        [self performSegueWithIdentifier:@"toReservationApprovalVCSegue" sender:self];
                    }
                });
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isTotalPressed) {
        return 4;
    }
    return 3;
}

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
}




- (void)totalButtonPressed{
    if (_isTotalPressed) {
        _isTotalPressed = NO;
    }else{
        _isTotalPressed = YES;
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}





- (IBAction)payNowPressed:(id)sender {
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

