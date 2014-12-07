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
    // upsell/downsell seçilmiş araç
    if (reservation.upsellSelectedCar)
    {
        if ([reservation.paymentType isEqualToString:@"1"])
        {
            [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",reservation.upsellSelectedCar.materialName,reservation.upsellSelectedCar.pricing.payNowPrice.floatValue]];
        }
        else
        {
            [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",reservation.selectedCar.materialName,reservation.upsellSelectedCar.pricing.payLaterPrice.floatValue]];
        }
    }
    
    //upsell/downsell araç grubu
    else if (reservation.upsellCarGroup)
    {
        if ([reservation.paymentType isEqualToString:@"1"])
        {
            [textView setText:[NSString stringWithFormat:@"- %@ ve benzeri - %.02f TL\n",reservation.upsellCarGroup.sampleCar.materialName,reservation.upsellCarGroup.sampleCar.pricing.payNowPrice.floatValue]];
        }
        else
        {
            [textView setText:[NSString stringWithFormat:@"- %@ ve benzeri - %.02f TL\n",reservation.upsellCarGroup.sampleCar.materialName,reservation.upsellCarGroup.sampleCar.pricing.payLaterPrice.floatValue]];
        }
    }
// AATAC 29.11.2014 28 Kasımdaki 5. madde kapsamında değişiklik lol :D
//    // normal rezervasyon seçilmiş araç
//    else if (reservation.selectedCar) {
//        if ([reservation.paymentType isEqualToString:@"1"])
//        {
//            [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",reservation.selectedCar.materialName,reservation.selectedCar.pricing.payNowPrice.floatValue]];
//        }
//        else
//        {
//            [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",reservation.selectedCar.materialName,reservation.selectedCar.pricing.payLaterPrice.floatValue]];
//        }
//    }
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
        
        if ([reservation.paymentType isEqualToString:@"1"] || reservation.paymentType == nil)
        {
            if (reservation.selectedCarGroup.sampleCar.pricing.priceWithKDV.floatValue > 0) {
                [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",string,[reservation.selectedCarGroup.sampleCar.pricing.priceWithKDV decimalNumberByAdding:reservation.changeReservationDifference].floatValue]];
            }
            else
                [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",string,[reservation.selectedCarGroup.sampleCar.pricing.payNowPrice decimalNumberByAdding:reservation.changeReservationDifference].floatValue]];
        }
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
        if (temp.quantity > 0 && ![temp.updateStatus isEqualToString:@"D"])
        {
            [textView setText:[NSString stringWithFormat:@"%@- %@ (%i adet) - %.02f TL\n",textView.text, temp.materialDescription,temp.quantity,(temp.price.floatValue * temp.quantity)]];
        }
    }

    // Aylıksa ödeme planını yazıcaz
    if (reservation.etExpiry.count > 0) {
        [textView setText:[NSString stringWithFormat:@"%@ \n Ödeme Planı", textView.text]];
        
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
        
        for (ETExpiryObject *tempObject in reservation.etExpiry) {
            if ([tempObject.carGroup isEqualToString:reservation.selectedCarGroup.groupCode] && [tempObject.brandID isEqualToString:brandID] && [tempObject.modelID isEqualToString:modelID]) {
                [textView setText:[NSString stringWithFormat:@"%@\n%i. Taksit - %@ %@ (Araç)", textView.text, count, tempObject.totalPrice.stringValue, tempObject.currency]];
                
                if (count == 1) {
                    [textView setText:[NSString stringWithFormat:@"%@ + Alınmış Ek Ürünler",textView.text]];
                }
                
                count++;
            }
        }
        
        if (count > 1) {
            [textView setText:[NSString stringWithFormat:@"%@\nToplam Tutar - %.02f TL", textView.text, [[reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"" andIsMontlyRent:NO] floatValue]]];
        }
    }
}

@end
