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
    }];
    [[ZGARENTA_EKHIZMET_SRVRequestHandler uniqueInstance] loadAdditionalEquipmentService:aService expand:YES];
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}
@end
