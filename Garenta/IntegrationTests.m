//
//  IntegrationTests.m
//  Garenta
//
//  Created by Alp Keser on 5/5/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZGARENTA_OFIS_SRVRequestHandler.h"
#import "ZGARENTA_OFIS_SRVServiceV0.h"
#import "ZGARENTA_ARAC_SRVServiceV0.h"
#import "ZGARENTA_ARAC_SRVRequestHandler.h"
#import "ZGARENTA_EKHIZMET_SRVRequestHandler.h"
#import "ZGARENTA_EKHIZMET_SRVServiceV0.h"
#import "ZGARENTA_versiyon_srvRequestHandler.h"
#import "ZGARENTA_versiyon_srvServiceV0.h"
#import "ZGARENTA_REZERVASYON_SRVRequestHandler.h"
#import "ZGARENTA_REZERVASYON_SRVServiceV0.h"
#import "CarGroup.h"
@interface IntegrationTests : XCTestCase

@end

@implementation IntegrationTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)versionCheckTest{
    
}


- (void)testAvailableCarsIntegrationCheck{
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HH:mm"];
    [ApplicationProperties configureCarService];
    AvailCarServiceV0 *availableCarService = [AvailCarServiceV0 new];
    [availableCarService setImppMsube:@" "];
    NSMutableArray *someOffices = [NSMutableArray new];
    IMPT_MSUBEV0 *anOffice =[IMPT_MSUBEV0 new];
    [anOffice setMsube:@"3071"];
    [someOffices addObject:anOffice];
    anOffice = [IMPT_MSUBEV0 new];
    //    [anOffice setMsube:@"3073"];
    //    [someOffices addObject:anOffice];
    [availableCarService setIMPT_MSUBESet:someOffices];
    [availableCarService setImppBegda:[NSDate date]];
    [availableCarService setExppSubrc:[NSNumber numberWithInt:0]];
    [availableCarService setImppBeguz:[dateFormatter stringFromDate:[NSDate date]]];
    [availableCarService setImppEnduz:[dateFormatter stringFromDate:[NSDate date]]];
    [availableCarService setImppEndda:[NSDate date]];
    [availableCarService setImppFikod:@" "]; //???
    [availableCarService setImppUname:@" "];  //bu ne lan
    [availableCarService setImppHdfsube:@"3071"];
    [availableCarService setImppKdgrp:@" "]; //bu ne be
    [availableCarService setExpKkgiris:@" "];
    User *user =[ApplicationProperties getUser];
    if ([ user isLoggedIn]) {
        [availableCarService setImppKunnr:[user kunnr]];
        [availableCarService setImppEhdat:[user driversLicenseDate]];
        [availableCarService setImppGbdat:[user birthday]];
    }else{
        [availableCarService setImppKunnr:@" "];
        [availableCarService setImppEhdat:[NSDate dateWithTimeIntervalSince1970:0]];
        [availableCarService setImppGbdat:[NSDate dateWithTimeIntervalSince1970:0]];
    }
    if (availableCarService.IMPT_MSUBESet.count == 1 && [(IMPT_MSUBEV0*)[availableCarService.IMPT_MSUBESet objectAtIndex:0] Msube] == nil) {
        
        [availableCarService setImppSehir:@"34"];
    }else{
        [availableCarService setImppSehir:@"00"];
    }
    //    [availableCarService setImppUname:@"AALPK"]; why
    [availableCarService setImppWaers:@"TRY"]; //probably they dont check
    [availableCarService setImppLangu:@"T"];   //probably they dont check
    [availableCarService setImppLand:@"TR"];   //probably they dont check
    
    
    NSMutableArray *carsImport =[[NSMutableArray alloc] init];
    ET_ARACLISTEV0 *dummyCar = [[ET_ARACLISTEV0  alloc] init];
    [dummyCar setAracsayi:[NSNumber numberWithInt:0]];
    [dummyCar setAcilirTavan:@"of"];
    [dummyCar setAnarenktx:@" "];
    [dummyCar setAux:@" "];
    [dummyCar setBagajHacmi:@" "];
    [dummyCar setBeygirGucu:@" "];
    [dummyCar setBluetooth:@" "];
    [dummyCar setCamTavan:@" "];
    [dummyCar setCekis:@" "];
    [dummyCar setCruiseKontrol:@" "];
    [dummyCar setDeriDoseme:@" "];
    [dummyCar setDjitalKlima:@" "];
    [dummyCar setEsp:@" "];
    [dummyCar setGencSrcEhl:@" "];
    [dummyCar setGencSrcYas:@" "];
    [dummyCar setGeriGorusKam:@" "];
    [dummyCar setGrpkod:@" "];
    [dummyCar setGrpkodtx:@" "];
    [dummyCar setGrubaRez:@" "];
    [dummyCar setHandsFree:@" "];
    [dummyCar setHsube:@" "];
    [dummyCar setHsubetx:@" "];
    [dummyCar setIsitmaliKoltuk:@" "];
    [dummyCar setIsofix:@" "];
    [dummyCar setKapiSayisi:@" "];
    [dummyCar setKasaTipi:@" "];
    [dummyCar setKasaTipiId:@" "];
    [dummyCar setKisLastik:@" "];
    [dummyCar setMaktx:@" "];
    [dummyCar setMarka:@" "];
    [dummyCar setMarkaId:@" "];
    [dummyCar setMatnr:@" "];
    [dummyCar setMinEhliyet:@" "];
    [dummyCar setMinYas:@" "];
    [dummyCar setModel:@" "];
    [dummyCar setModelId:@" "];
    [dummyCar setModelYili:@" "];
    [dummyCar setMotorHacmi:@" "];
    [dummyCar setMsube:@" "];
    [dummyCar setMsubetx:@" "];
    [dummyCar setNavigasyon:@" "];
    [dummyCar setOrtYakitTuketim:@" "];
    [dummyCar setParkSensoruArka:@" "];
    [dummyCar setParkSensoruOn:@" "];
    [dummyCar setPlakayaRez:@" "];
    [dummyCar setRenk:@" "];
    [dummyCar setRenktx:@" "];
    [dummyCar setRgbkodu:@" "];
    [dummyCar setSanzimanTipi:@" "];
    [dummyCar setSanzimanTipiId:@" "];
    [dummyCar setSegment:@" "];
    [dummyCar setSegmenttx:@" "];
    [dummyCar setSehir:@" "];
    [dummyCar setSifirYuzHiz:@" "];
    [dummyCar setStartStop:@" "];
    [dummyCar setTrdonanim:@" "];
    [dummyCar setTrmodel:@" "];
    [dummyCar setTrversiyon:@" "];
    [dummyCar setVitrinres:@" "];
    [dummyCar setXenonFar:@" "];
    [dummyCar setYagmurSensoru:@" "];
    [dummyCar setYakitTipi:@" "];
    [dummyCar setYakitTipiId:@" "];
    [dummyCar setYolcuSayisi:@" "];
    [dummyCar setZresim135:@" "];
    [dummyCar setZresim180:@" "];
    [dummyCar setZresim315:@" "];
    [dummyCar setZresim45:@" "];
    [dummyCar setZresim90:@" "];
    [dummyCar setAbs:@" "];
    [dummyCar setAugru:@" "];
    
    
    [carsImport addObject:dummyCar];
    NSMutableArray *priceImport = [NSMutableArray new];
    ET_FIYATV0 *dummyFiyat = [ET_FIYATV0 new];
    [dummyFiyat setSimdiOdeFiyatEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSimdiOdeFiyatGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSimdiOdeFiyatTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSimdiOdeFiyatUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSonraOdeFiyatEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSonraOdeFiyatGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setSonraOdeFiyatTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat  setSonraOdeFiyatUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracGrubu:@" "];
    [dummyFiyat setAracSecimFarkEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracSecimFarkGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracSecimFarkTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAracSecimFarkUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setAylikFiyatKod:@" "]; //aylik fiyat kodu varsa liste fiyat kdvsiz
    [dummyFiyat setBuFiyataSon:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setBuKampSon:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setCikisSube:@" "];
    [dummyFiyat setFreeGun:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setGunSayisi:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setIl:@" "];
    [dummyFiyat setKampanyaId:@" "];
    [dummyFiyat setKampanyaKapsam:@" "];
    [dummyFiyat setKampanyaOran:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTanim:@" "];
    [dummyFiyat setKampanyaTutarEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTutarGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTutarTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKampanyaTutarUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKanalTuru:@" "];
    [dummyFiyat setKasaTip:@" "];
    [dummyFiyat setKazancEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat  setKazancGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat  setKazancTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKazancUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvliToplamTutarUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setKdvTutarUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatEur:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatGbp:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatTry:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setListeFiyatUsd:[NSDecimalNumber decimalNumberWithString:@"0"]];
    [dummyFiyat setMarkaId:@" "];
    [dummyFiyat setModelId:@" "];
    [dummyFiyat setRezTuru:@" "];
    [dummyFiyat setSanzTip:@" "];
    [dummyFiyat setYakitTip:@" "];
    [dummyFiyat setAracSecim:@" "];
    [dummyFiyat setParoKazanir:@" "];
    [dummyFiyat setParafKazanir:@" "];
    [dummyFiyat setBonusKazanir:@" "];
    [dummyFiyat setMilKazanir:@" "];
    [priceImport addObject:dummyFiyat];
    [availableCarService setET_FIYATSet:priceImport];
    
    
    __block BOOL waitingForBlock = YES;
    
    [availableCarService setET_ARACLISTESet:carsImport];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kCreateAvailCarServiceCompletedNotification object:nil queue:operationQueue usingBlock:^(NSNotification *note){
        waitingForBlock = NO;
        XCTAssertNil([note userInfo][kServerResponseError] , @"Available cars no response");
        
        AvailCarServiceV0 *availServiceResponse = (AvailCarServiceV0*)[[note userInfo] objectForKey:kResponseItem];
        NSMutableArray *availableCarGroups = [CarGroup getCarGroupsFromServiceResponse:availServiceResponse withOffices:nil];
        
        
        
    }];
    
    [[ZGARENTA_ARAC_SRVRequestHandler uniqueInstance] createAvailCarService:availableCarService];
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    
}

- (void)testAdditionalEquipmentService{
    [ApplicationProperties configureAdditionalEquipmentService];
    AdditionalEquipmentServiceV0 *aService = [[AdditionalEquipmentServiceV0 alloc] init];
    NSDateFormatter *dateformater = [NSDateFormatter new];
    [dateformater setDateFormat:@"HH:mm"];
    [aService setImppBegda:[NSDate date]];
    [aService setImppBeguz:@"09:00"];
    [aService setImppEnduz:@"09:00"];
    [aService setImppEndda:[NSDate date]];
    [aService setImppFikod:@" "];
    [aService setImppGrpkod:@"A2"];
    [aService setImppMsube:@"3071"];
    [aService setImppDsube:@" "];
    [aService setImppLangu:@"T"];
    [aService setImppMarkaid:@" "];
    [aService setImppModelid:@" "];
    [aService setImppKampid:@" "];
    [aService setImppSozno:@" "];
    [aService setImppRezno:@" "];
    
    __block BOOL waitingForBlock = YES;
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoadAdditionalEquipmentServiceCompletedNotification object:nil queue:operationQueue usingBlock:^(NSNotification *notification){
        waitingForBlock = NO;
        XCTAssertNil([notification userInfo][kServerResponseError] , @"Error");
        XCTAssertNotNil([notification userInfo][kResponseItem] , @"Additional equipment service no response");
        AdditionalEquipmentServiceV0 *response = [notification userInfo][kResponseItem];
    }];
        [[ZGARENTA_EKHIZMET_SRVRequestHandler uniqueInstance] loadAdditionalEquipmentService:aService expand:YES];
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testVersionService{
    [ApplicationProperties configureVersionService];
    VersiyonServiceV0 *aService = [VersiyonServiceV0 new];
    [aService setIVers:[NSString stringWithFormat:@"%.01f",[ApplicationProperties getAppVersion]]];
    [aService setIAppName:@"rezApp"];
    __block BOOL waitingForBlock = YES;
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoadVersiyonServiceCompletedNotification object:nil queue:operationQueue usingBlock:^(NSNotification *notification){
        waitingForBlock = NO;
        XCTAssertNil([notification userInfo][kServerResponseError] , @"Error");
        XCTAssertNotNil([notification userInfo][kResponseItems] , @"Version service no response");
        
    }];
    [[ZGARENTA_versiyon_srvRequestHandler uniqueInstance] loadVersiyonService:aService];
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testReservationService{
    [ApplicationProperties configureReservationService];
    ReservationServiceV0 *aService = [ReservationServiceV0 new];
    IsInputV0 *isInput = [IsInputV0 new];
    [isInput setAlisSubesi:@"3071"];
    [isInput setBonus:[NSDecimalNumber decimalNumberWithString:@"0.0"]];// yok
    [isInput setCCorpPriority:@" "];//X coorp priorityse x
    [isInput setCPriority:@" "];//X priority
    [isInput setFtCikisAdres:@"Greenpark hotel"];// free text
    [isInput setFtCikisIl:@"34"]; //plaka
    [isInput setFtCikisIlce:@"Bostanci"]; //ilce citykod crmden donen
    [isInput setFtDonusAdres:@"Miracle Hotel"]; //freetext
    [isInput setFtDonusIl:@"34"];
    [isInput setFtDonusIlce:@"Kurtkoy"];
    [isInput setFtMaliyetTipi:@" "];//???// masraf yansitilcak alinmiycak canlida yok
    [isInput setGarentaTl:[NSDecimalNumber decimalNumberWithString:@"0.0"]]; //free
    [isInput setGunSayisi:[NSNumber numberWithDouble:3]]; //available aractan donen gun sayisi*
    [isInput setMilesSmiles:[NSDecimalNumber decimalNumberWithString:@"0.0"]]; //
    [isInput setOdemeTuru:@"K"];//1,2,3 hemen ödeme sonra öde ön ödemeli iptal edilemez
    [isInput setParaBirimi:@"TRY"]; //TRY EUR USD GBP
    [isInput setPuanTipi:@" "];//?? M ıse mıl G ıse garenta tl
    [isInput setRezBegda:[NSDate date]];
    [isInput setRezBegtime:@"09:00"];
    [isInput setRezEndda:[NSDate date]];
    [isInput setRezEndtime:@"17:00"];
    [isInput setRezKanal:@"40"]; //Mobil 40
    [isInput setRezNo:@" "];
    [isInput setSatisBurosu:@" "];// checkout office
    [isInput setTeslimSubesi:@"3071"];
    [isInput setToplamTutar:[NSDecimalNumber decimalNumberWithString:@"50.0"]];
    [isInput setUsername:@" "];
    
    IsUserinfoV0 *isUserInfo = [IsUserinfoV0 new];
    [isUserInfo setAdress:@"Zorunlu mu bu adres"]; //il ilce adres zorunlu
    [isUserInfo setBirthdate:[NSDate date]];
    [isUserInfo setCinsiyet:@"1"];//???1 erkek 2 kadın
    [isUserInfo setSalesOrganization:@"3063"];//????
    [isUserInfo setDistributionChannel:@"33"];//???3063 fix
    [isUserInfo setDivision:@"65"];//???33 fix
    [isUserInfo setEhliyetAlisyeri:@"Mugla"];//free zorunlu?
    [isUserInfo setEhliyetNo:@"2351"];//free zorunlu?
    [isUserInfo setEhliyetSinifi:@"B2"];//combo sabit siteden bak
    [isUserInfo setEhliyetTarihi:[NSDate date]];
    [isUserInfo setEmail:@"kerembalaban@gmail.com"]; //zoeunlu
    [isUserInfo setFirstname:@"Alp"];
    [isUserInfo setIlcekod:@"34"];//ilce kod rfcsiden alcak
    [isUserInfo setIlkodu:@"34"];
    [isUserInfo setKanalturu:@"Z07"]; // sabit
    [isUserInfo setLastname:@"Keser"];
    [isUserInfo setMiddlename:@"Yusuf"];
    [isUserInfo setMusterino:@" "]; //kunnr loginse must
    //birinden biri
    [isUserInfo setPasaportno:@"U01723537"];
    [isUserInfo setTckn:@"46558353458"];
    
    [isUserInfo setTelno:@"05337768554"]; //no533
    [isUserInfo setTelnoUlke:@" "];//90
    [isUserInfo setTkKartno:@"tk921"];//???tk almıyoruz
    [isUserInfo setUlke:@"Tr"];//??? TR yada bos
    [isUserInfo setUyruk:@"TR"];//???? tr veya boş
    [isUserInfo setVergino:@"028393"]; //free text siniri 11
    
    //buraya availdeki arac matnrsini hepsini cak
    IT_ARACLARV0 *itAracLine = [IT_ARACLARV0 new];
    [itAracLine setMatnr:@"J034943043"];
    
    IT_EKSURUCUV0 *itEksurucuLine = [IT_EKSURUCUV0 new];
    [itEksurucuLine setBirthdate:[NSDate date]];
    [itEksurucuLine setCinsiyet:@"1"];//1 erkek 2 kadin
    [itEksurucuLine setEhliyetAlisyeri:@"Bodrum"];
    [itEksurucuLine setEhliyetNo:@"1234"];
    [itEksurucuLine setEhliyetSinifi:@"B"];
    [itEksurucuLine setEhliyetTarihi:[NSDate date]];
    [itEksurucuLine setEksurucuNo:@" "];//update icin create gereksiz
    [itEksurucuLine setFirstname:@"Ata"];
    [itEksurucuLine setKalemNo:@"0020"];//update icin create gereksiz
    [itEksurucuLine setLastname:@"Cengiz"];
    [itEksurucuLine setTckn:@"35678900987"];
    [itEksurucuLine setTelno:@"02939209202"];
    [itEksurucuLine setUlke:@"TR"];//digerse bos
    [itEksurucuLine setUyruk:@"TR"];//digerse bos
    [itEksurucuLine setUpdateStatu:@"x"];//update icin create gereksiz
    
    IT_FATURA_ADRESV0 *itFaturaAdresLine = [IT_FATURA_ADRESV0 new];
    [itFaturaAdresLine setAddrnumber:@"01"];//???donen adreslerde var bu alan ordan alcan
    [itFaturaAdresLine setAdres:@"adressss"];
    [itFaturaAdresLine setAdresKaydet:@"X"];//????x yada bos
    [itFaturaAdresLine setAdresTanim:@"Adres Tanım"];
    [itFaturaAdresLine setAyniAdres:@"X"];//faturayla ayni adres
    [itFaturaAdresLine setFatTip:@"1"];//???Bireysel mi 2-kurumsal mi
    [itFaturaAdresLine setFirmaAdi:@"Firma Adı"]; //2 ise
    [itFaturaAdresLine setFirstname:@"Alp"];//1 ise
    [itFaturaAdresLine setIlcekod:@"01"];
    [itFaturaAdresLine setIlkodu:@"34"];
    [itFaturaAdresLine setLastname:@"Keser"];//1 ise
    [itFaturaAdresLine setMiddlename:@"Yusuf"];//1 ise
    [itFaturaAdresLine setPasaportno:@"U0171"];//1 ise
    [itFaturaAdresLine setTckn:@"4785889058"];//1 ise
    [itFaturaAdresLine setUlke:@"TR"];//1 ise
    [itFaturaAdresLine setVergidairesi:@"Goztepe VD"]; //2 ise
    [itFaturaAdresLine setVergino:@"923948"];//2 ise
    
    IT_ITEMSV0 *itemLine = [IT_ITEMSV0 new];
    [itemLine setAlisSubesi:@"3071"];
    [itemLine setAracGrubu:@"A2"];//sadece aracta
    [itemLine setAracRenk:@" "];//???renk kodu available aracta ff bilmnenmen?
    [itemLine setCKislastik:@" "];//??? X sadece arac satirinda olcak
    [itemLine setFiloSegment:@" "];// segment kod
    [itemLine setFiyat:[NSDecimalNumber decimalNumberWithString:@"10.0"]];
    [itemLine setFiyatKodu:@"L1"]; //avail aracta donudo
    [itemLine setJatoMarka:@"Mercedes"]; //avail arac
    [itemLine setJatoModel:@"C Serisi"];//avail arac
    [itemLine setKalemTipi:@"A"]; //update ici create de bos 1:farkl tes cikis 2:farkli tes donus 3: sure uzat 4: kisaltma
    [itemLine setKampanyaId:@"z"]; //et_rezervdeki id
    [itemLine setMalzemeNo:@"3054"]; //matnr sadece arac secerse
    [itemLine setMiktar:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
    [itemLine setParaBirimi:@"TRY"]; //konustuk bunu
    [itemLine setPlakaNo:@"34ak9038"]; //sadece aracta aracı sectiyse
    [itemLine setRezBegda:[NSDate date]];//headerla ayni
    [itemLine setRezBegtime:@"09:00"];
    [itemLine setRezEndda:[NSDate date]];
    [itemLine setRezEndtime:@"17:00"];
    [itemLine setRezKalemNo:@"1"]; //update icin create
    [itemLine setSasiNo:@"ERTYU1234567890"]; // avail aractan
    [itemLine setSatisBurosu:@"SB"]; //chekout office
    [itemLine setTeslimSubesi:@"3071"];
    [itemLine setUpdateStatu:@"x"]; // kullanilmior
    
    IT_SDREZERVV0 *sdRezervLine = [IT_SDREZERVV0 new];
    [sdRezervLine setAugru:@"1"];
    [sdRezervLine setBonusKazanir:@"X"];
    [sdRezervLine setFiyatKodu:@"L1"];
    [sdRezervLine setGrnttlKazanir:@"1"];
    [sdRezervLine setGrupKodu:@"A2"];
    [sdRezervLine setHdfsube:@"3071"];
    [sdRezervLine setKunnr:@"12345"];
    [sdRezervLine setMatnr:@"J2345678"];
    [sdRezervLine setMilKazanir:@"T"];
    [sdRezervLine setRAuart:@" "];
    [sdRezervLine setRGjahr:@"2014"];
    [sdRezervLine setRPosnr:@"10"];
    [sdRezervLine setRVbeln:@"0123456789"];
    [sdRezervLine setSpart:@"T"];
    [sdRezervLine setSube:@"3071"];
    [sdRezervLine setTarih:[NSDate date]];
    [sdRezervLine setTutar:[NSDecimalNumber decimalNumberWithString:@"30.0"]];
    [sdRezervLine setVkorg:@"1011"];
    [sdRezervLine setVtweg:@"23"];
    
    IT_TAHSILATV0 *itTahsilatLine = [IT_TAHSILATV0 new];
    [itTahsilatLine setAmount:[NSDecimalNumber decimalNumberWithString:@"10.0"]];
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
    
    
    NSMutableArray * itAraclar = [NSMutableArray new];
    NSMutableArray *itEksurucu = [NSMutableArray new];
    NSMutableArray *itFaturaAdres = [NSMutableArray new];
    NSMutableArray *itItem = [NSMutableArray new];
    NSMutableArray *itSdRezerv = [NSMutableArray new];
    NSMutableArray *itTahsilat = [NSMutableArray new];
    NSMutableArray *etReturn = [NSMutableArray new];
    
    
    [itAraclar addObject:itAracLine];
    [itEksurucu addObject:itEksurucuLine];
    [itFaturaAdres addObject:itFaturaAdresLine];
    [itItem addObject:itemLine];
    [itSdRezerv addObject:sdRezervLine];
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
    
    __block BOOL waitingForBlock = YES;
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [[NSNotificationCenter defaultCenter] addObserverForName:kCreateReservationServiceCompletedNotification object:nil queue:operationQueue usingBlock:^(NSNotification *notification){
        waitingForBlock = NO;
        XCTAssertNil([notification userInfo][kServerResponseError] , @"Error");
        XCTAssertNotNil([notification userInfo][kResponseItem] , @"Reservation service no response");
    }];
    [[ZGARENTA_REZERVASYON_SRVRequestHandler uniqueInstance] createReservationService:aService];
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    
    
    
    
}





@end
