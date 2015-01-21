//
//  ReservationScopePopoverVC.m
//  Garenta
//
//  Created by Alp Keser on 6/27/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "ReservationScopePopoverVC.h"
#import "AdditionalEquipment.h"
#import "ETExpiryObject.h"

@implementation ReservationScopePopoverVC
@synthesize reservation,textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareScopeInformation];
}

- (void)prepareScopeInformation
{
    // Ata burda rez createle aynı mantıkda gösermek lazım, orda da önce grubuu sonra seçimi gösteriyoruz
    //upsell/downsell araç grubu
    if (reservation.upsellCarGroup)
    {
        if ([reservation.paymentType isEqualToString:@"2"] || [reservation.paymentType isEqualToString:@"6"])
        {
            [textView setText:[NSString stringWithFormat:@"- %@ ve benzeri - %.02f TL\n",reservation.upsellCarGroup.sampleCar.materialName,reservation.upsellCarGroup.sampleCar.pricing.payLaterPrice.floatValue]];
        }
        else
        {
            [textView setText:[NSString stringWithFormat:@"- %@ ve benzeri - %.02f TL\n",reservation.upsellCarGroup.sampleCar.materialName,reservation.upsellCarGroup.sampleCar.pricing.payNowPrice.floatValue]];
        }
        // Burda upsell ve downsell'de seçilen aracın fiyatı var ama araç seçim farkı yok
        if (reservation.upsellSelectedCar) {
            [textView setText:[NSString stringWithFormat:@"%@- %@ %@ Araç seçim ücreti - %.02f TL\n", textView.text, reservation.upsellSelectedCar.brandName, reservation.upsellSelectedCar.modelName, reservation.upsellSelectedCar.pricing.carSelectPrice.floatValue]];
        }
    }
    else
    {
        NSString *string;
        if (reservation.selectedCar) {
            string = reservation.selectedCar.materialName;
        }
        else{
            string = [NSString stringWithFormat:@"%@ ve benzeri",reservation.selectedCarGroup.sampleCar.materialName];
        }
        
        if (reservation.changeReservationDifference == nil)
            reservation.changeReservationDifference = [NSDecimalNumber decimalNumberWithString:@"0"];
        
        // şimdi öde, ön ödemeli iptal edilemez (aylık ve normal)
        if ([reservation.paymentType isEqualToString:@"1"] || [reservation.paymentType isEqualToString:@"3"] || [reservation.paymentType isEqualToString:@"8"] || [reservation.paymentType isEqualToString:@"9"] || reservation.paymentType == nil)
        {
            // normal aylık
            if (reservation.selectedCarGroup.sampleCar.pricing.priceWithKDV.floatValue > 0 && !reservation.campaignObject)
            {
                [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",string,[reservation.selectedCarGroup.sampleCar.pricing.priceWithKDV decimalNumberByAdding:reservation.changeReservationDifference].floatValue]];
            }
            // aylık kampanyalı
            else if (reservation.campaignObject.campaignPrice.priceWithKDV.floatValue > 0 && reservation.campaignObject)
            {
                [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",string,[reservation.campaignObject.campaignPrice.priceWithKDV decimalNumberByAdding:reservation.changeReservationDifference].floatValue]];
            }
            else
                [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",string,[reservation.selectedCarGroup.sampleCar.pricing.payNowPrice decimalNumberByAdding:reservation.changeReservationDifference].floatValue]];
        }
        // sonra öde (aylık ve normal)
        else
        {
            if (reservation.selectedCarGroup.sampleCar.pricing.priceWithKDV.floatValue > 0) {
                [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",string,[reservation.selectedCarGroup.sampleCar.pricing.priceWithKDV decimalNumberByAdding:reservation.changeReservationDifference].floatValue]];
            }
            else
                [textView setText:[NSString stringWithFormat:@"- %@ ve benzeri - %.02f TL\n",string,[reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice decimalNumberByAdding:reservation.changeReservationDifference].floatValue]];
        }
        
        if (reservation.selectedCar) {
            [textView setText:[NSString stringWithFormat:@"%@- %@ %@ Araç seçim ücreti - %.02f TL\n", textView.text, reservation.selectedCar.brandName, reservation.selectedCar.modelName, reservation.selectedCar.pricing.carSelectPrice.floatValue]];
        }
    }
    
    // REZERVASYONDAKİ EK ÜRÜNLER
    for (AdditionalEquipment *temp in reservation.additionalEquipments)
    {
        if (temp.quantity > 0 && ![temp.updateStatus isEqualToString:@"D"] && ![temp.materialNumber isEqualToString:@"HZM0031"])
        {
            [textView setText:[NSString stringWithFormat:@"%@- %@ (%i adet) - %.02f TL\n",textView.text, temp.materialDescription,temp.quantity,(temp.price.floatValue * temp.quantity)]];
        }
    }

    // Aylıksa ödeme planını yazıcaz
    if (reservation.etExpiry.count > 0) {
        [textView setText:[NSString stringWithFormat:@"%@ \n Ödeme Planı (Araç + Ek Ürün)", textView.text]];
        
        int count = 1;
        
        NSString *brandID = @"";
        NSString *modelID = @"";
        
        if (reservation.selectedCar != nil) {
            brandID = reservation.selectedCar.brandId;
            modelID = reservation.selectedCar.modelId;
        }
        else {
            brandID = reservation.selectedCarGroup.sampleCar.brandId;
            modelID = reservation.selectedCarGroup.sampleCar.modelId;
        }
        
        for (ETExpiryObject *tempObject in reservation.etExpiry)
        {
            NSString *campaignScopeType = @"";
            
            if (reservation.campaignObject.campaignScopeType == payNowReservation) {
                campaignScopeType = @"ZR2";
            }
            else if (reservation.campaignObject.campaignScopeType == payLaterReservation){
                campaignScopeType = @"ZR1";
            }
            else if (reservation.campaignObject.campaignScopeType == payFrontWithNoCancellation){
                campaignScopeType = @"ZR3";
            }
            
            if (reservation.campaignObject)
            {
                if ([tempObject.carGroup isEqualToString:reservation.selectedCarGroup.groupCode] && [tempObject.brandID isEqualToString:brandID] && [tempObject.modelID isEqualToString:modelID] && [tempObject.campaignID isEqualToString:reservation.campaignObject.campaignID] && [tempObject.campaignScopeType isEqualToString:campaignScopeType])
                {
                    NSDecimalNumber *equipmentMonthlyPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                    NSDecimalNumber *documentMonthlyTotalPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                    
                    for (AdditionalEquipment *temp in reservation.additionalEquipments)
                    {
                        if (temp.quantity > 0 && ![temp.updateStatus isEqualToString:@"D"])
                        {
                            equipmentMonthlyPrice = [equipmentMonthlyPrice decimalNumberByAdding:temp.monthlyPrice];
                        }
                    }

                    documentMonthlyTotalPrice = [tempObject.totalPrice decimalNumberByAdding:equipmentMonthlyPrice];
                    
                    [textView setText:[NSString stringWithFormat:@"%@\n%i. Taksit - %@ %@", textView.text, count, documentMonthlyTotalPrice.stringValue, tempObject.currency]];
                    
                    count++;
                }
            }
            else
            {
                if ([tempObject.carGroup isEqualToString:reservation.selectedCarGroup.groupCode] && [tempObject.brandID isEqualToString:brandID] && [tempObject.modelID isEqualToString:modelID] && [tempObject.campaignID isEqualToString:campaignScopeType])
                {
                    NSDecimalNumber *equipmentMonthlyPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                    NSDecimalNumber *documentMonthlyTotalPrice = [NSDecimalNumber decimalNumberWithString:@"0"];
                    
                    // alınan ek ürünklerin aylık taksitleri toplanıyor
                    for (AdditionalEquipment *temp in reservation.additionalEquipments)
                    {
                        if (temp.quantity > 0 && ![temp.updateStatus isEqualToString:@"D"])
                        {
                            equipmentMonthlyPrice = [equipmentMonthlyPrice decimalNumberByAdding:temp.monthlyPrice];
                        }
                    }
                    
                    documentMonthlyTotalPrice = [tempObject.totalPrice decimalNumberByAdding:equipmentMonthlyPrice];
 
                    [textView setText:[NSString stringWithFormat:@"%@\n%i. Taksit - %@ %@", textView.text, count, documentMonthlyTotalPrice.stringValue, tempObject.currency]];
                    
                    count++;
                }
            }
        }
        
        if (count > 1) {
            [textView setText:[NSString stringWithFormat:@"%@\nToplam Tutar - %.02f TL", textView.text, [[reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"" andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:NO andReservation:reservation] floatValue]]];
        }
    }
    if ([[ApplicationProperties getUser] isLoggedIn] && [[[ApplicationProperties getUser] partnerType] isEqualToString:@"K"]) {
        [textView setText:[NSString stringWithFormat:@"%@ \n Ödeme Planı", textView.text]];
        
        BOOL isPayNow = NO;
        
        if (![reservation.paymentType isEqualToString:@"2"] || ![reservation.paymentType isEqualToString:@"6"]) {
            isPayNow = YES;
        }
        
        NSDecimalNumber *corparatePayment = [reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:@"" andIsMontlyRent:NO andIsCorparatePayment:YES andIsPersonalPayment:NO andReservation:reservation];
        NSDecimalNumber *personalPayment = [reservation totalPriceWithCurrency:@"TRY" isPayNow:isPayNow andGarentaTl:@"" andIsMontlyRent:NO andIsCorparatePayment:NO andIsPersonalPayment:YES andReservation:reservation];
        
        [textView setText:[NSString stringWithFormat:@"%@ \n Firma Tarafından Ödenicek Tutar - %.02f TL", textView.text, corparatePayment.floatValue]];
        [textView setText:[NSString stringWithFormat:@"%@ \n Personel Tarafından Ödenicek Tutar - %.02f TL", textView.text, personalPayment.floatValue]];
    }
}

@end
