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
    
    // normal rezervasyon seçilmiş araç
    else if (reservation.selectedCar) {
        if ([reservation.paymentType isEqualToString:@"1"])
        {
            [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",reservation.selectedCar.materialName,reservation.selectedCar.pricing.payNowPrice.floatValue]];
        }
        else
        {
            [textView setText:[NSString stringWithFormat:@"- %@ - %.02f TL\n",reservation.selectedCar.materialName,reservation.selectedCar.pricing.payLaterPrice.floatValue]];
        }
    }
    else
    {
        if ([reservation.paymentType isEqualToString:@"1"])
        {
            [textView setText:[NSString stringWithFormat:@"- %@ ve benzeri - %.02f TL\n",reservation.selectedCarGroup.sampleCar.materialName,reservation.selectedCarGroup.sampleCar.pricing.payNowPrice.floatValue]];
        }
        else
        {
            [textView setText:[NSString stringWithFormat:@"- %@ ve benzeri - %.02f TL\n",reservation.selectedCarGroup.sampleCar.materialName,reservation.selectedCarGroup.sampleCar.pricing.payLaterPrice.floatValue]];
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
        
        for (ETExpiryObject *tempObject in reservation.etExpiry) {
            if ([tempObject.carGroup isEqualToString:reservation.selectedCarGroup.groupCode]) {
                [textView setText:[NSString stringWithFormat:@"%@\n%i. Taksit - %@ %@", textView.text, count, tempObject.totalPrice.stringValue, tempObject.currency]];
                count++;
            }
        }
        
        if (count > 1) {
            [textView setText:[NSString stringWithFormat:@"%@\nToplam Tutar - %.02f TL", textView.text, [[reservation totalPriceWithCurrency:@"TRY" isPayNow:YES andGarentaTl:@"" andIsMontlyRent:NO] floatValue]]];
        }
    }
}

@end
