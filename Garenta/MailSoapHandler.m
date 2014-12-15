//
//  MailSoapHandler.m
//  Garenta
//
//  Created by Ata Cengiz on 31/10/14.
//  Copyright (c) 2014 Kerem Balaban. All rights reserved.
//

#import "MailSoapHandler.h"

@implementation MailSoapHandler

+ (BOOL)sendMessage:(NSString *)message toMail:(NSString *)mail withFirstname:(NSString *)firstname andLastname:(NSString *)lastname {
    NSURL *connectionURL = [NSURL URLWithString:@"http://mobil.garenta.com.tr/hgs/Asmx/SendMail.asmx"];
    
    NSString *signature = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">";
    NSString *openHeader = @"<soapenv:Header/>";
    NSString *openBody = @"<soapenv:Body>";
    NSString *openFunction = @"<tem:SendConfirmationMail>";
    NSString *mailAdress = [NSString stringWithFormat:@"<tem:email>%@</tem:email>", mail];
    NSString *firstName = [NSString stringWithFormat:@"<tem:firstName>%@</tem:firstName>", firstname];
    NSString *lastName = [NSString stringWithFormat:@"<tem:lastName>%@</tem:lastName>", lastname];
    NSString *generatedCode = [NSString stringWithFormat:@"<tem:code>%@</tem:code>", message];
    NSString *closeFunction = @"</tem:SendConfirmationMail>";
    NSString *closeBody = @"</soapenv:Body>";
    NSString *closeHeader = @"</soapenv:Envelope>";
    
    NSString *soapMsg = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", signature, openHeader, openBody, openFunction, mailAdress, firstName, lastName,generatedCode, closeFunction, closeBody, closeHeader];
    NSMutableURLRequest *soapReq = [NSMutableURLRequest requestWithURL:connectionURL];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu" , (unsigned long)[soapMsg length]];
    [soapReq addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [soapReq addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [soapReq setHTTPMethod:@"POST"];
    [soapReq setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:soapReq returningResponse:&response error:&error];
    
    if (error == nil && data != nil && [data length] > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)sendLostPasswordMessage:(NSString *)message toMail:(NSString *)mail {
    NSURL *connectionURL = [NSURL URLWithString:@"http://mobil.garenta.com.tr/hgs/Asmx/SendMail.asmx"];
    
    NSString *signature = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">";
    NSString *openHeader = @"<soapenv:Header/>";
    NSString *openBody = @"<soapenv:Body>";
    NSString *openFunction = @"<tem:SendNewPassword>";
    NSString *mailAdress = [NSString stringWithFormat:@"<tem:email>%@</tem:email>", mail];
    NSString *generatedCode = [NSString stringWithFormat:@"<tem:code>%@</tem:code>", message];
    NSString *closeFunction = @"</tem:SendNewPassword>";
    NSString *closeBody = @"</soapenv:Body>";
    NSString *closeHeader = @"</soapenv:Envelope>";
    
    NSString *soapMsg = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", signature, openHeader, openBody, openFunction, mailAdress,generatedCode, closeFunction, closeBody, closeHeader];
    NSMutableURLRequest *soapReq = [NSMutableURLRequest requestWithURL:connectionURL];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu" , (unsigned long)[soapMsg length]];
    [soapReq addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [soapReq addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [soapReq setHTTPMethod:@"POST"];
    [soapReq setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:soapReq returningResponse:&response error:&error];
    
    if (error == nil && data != nil && [data length] > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)sendReservationInfoMessage:(Reservation *)reservation toMail:(NSString *)mail withFullName:(NSString *)customerFullName withTotalPrice:(NSString *)totalPrice withReservationNumber:(NSString *)reservationNo withPaymentType:(NSString *)paymentType
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString *checkOutDate = [dateFormatter stringFromDate:reservation.checkOutTime];
    NSString *checkInDate = [dateFormatter stringFromDate:reservation.checkInTime];
    
    NSString *checkOutTime = [timeFormatter stringFromDate:reservation.checkOutTime];
    NSString *checkInTime = [timeFormatter stringFromDate:reservation.checkInTime];
    
    NSString *checkOutDateTime = [NSString stringWithFormat:@"%@T%@",checkOutDate,checkOutTime];
    NSString *checkInDateTime = [NSString stringWithFormat:@"%@T%@",checkInDate,checkInTime];
    
    NSString *reservationType = @"";
    NSString *brandName = @"";
    NSString *modelName = @"";
    NSString *documentPayType = @"";
    
    if (reservation.selectedCar)
    {
        reservationType = @"10";
        brandName = reservation.selectedCar.brandName;
        modelName = reservation.selectedCar.modelName;
    }
    else if (reservation.upsellSelectedCar)
    {
        reservationType = @"10";
        brandName = reservation.upsellSelectedCar.brandName;
        modelName = reservation.upsellSelectedCar.modelName;
    }
    else if (reservation.upsellCarGroup)
    {
        reservationType = @"20";
        brandName = reservation.upsellCarGroup.sampleCar.brandName;
        modelName = reservation.upsellCarGroup.sampleCar.modelName;
    }
    else if (reservation.selectedCarGroup)
    {
        reservationType = @"20";
        brandName = reservation.selectedCarGroup.sampleCar.brandName;
        modelName = reservation.selectedCarGroup.sampleCar.modelName;
    }
    
    if ([paymentType isEqualToString:@"1"] || [paymentType isEqualToString:@"8"]) {
        documentPayType = @"0";
    }
    else if ([paymentType isEqualToString:@"2"] || [paymentType isEqualToString:@"6"]) {
        documentPayType = @"1";
    }
    else{
        documentPayType = @"2";
    }
    
    
    NSURL *connectionURL = [NSURL URLWithString:@"http://mobil.garenta.com.tr/hgs/Asmx/SendMail.asmx"];
    NSString *signature = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">";
    NSString *openHeader = @"<soapenv:Header/>";
    NSString *openBody = @"<soapenv:Body>";
    NSString *openFunction = @"<tem:Rezervation>";
    NSString *mailAdress = [NSString stringWithFormat:@"<tem:mailAdres>%@</tem:mailAdres>", mail];
    NSString *fullName = [NSString stringWithFormat:@"<tem:fullName>%@</tem:fullName>", customerFullName];
    NSString *reservationCode = [NSString stringWithFormat:@"<tem:reservationCode>%@</tem:reservationCode>", reservationNo];
    NSString *pickUpLocation = [NSString stringWithFormat:@"<tem:pickUpLocation>%@</tem:pickUpLocation>", reservation.checkOutOffice.subOfficeName];
    NSString *pickUpDate     = [NSString stringWithFormat:@"<tem:pickUpDate>%@</tem:pickUpDate>",checkOutDateTime];
    NSString *deliveryLocation = [NSString stringWithFormat:@"<tem:deliveryLocation>%@</tem:deliveryLocation>", reservation.checkInOffice.subOfficeName];
    NSString *deliveryDate = [NSString stringWithFormat:@"<tem:deliveryDate>%@</tem:deliveryDate>", checkInDateTime];
    NSString *payType = [NSString stringWithFormat:@"<tem:payType>%@</tem:payType>", documentPayType];
    NSString *carRezType = [NSString stringWithFormat:@"<tem:carRezType>%@</tem:carRezType>", reservationType];
    NSString *carBrand = [NSString stringWithFormat:@"<tem:carBrand>%@</tem:carBrand>", brandName];
    NSString *carModal = [NSString stringWithFormat:@"<tem:carModal>%@</tem:carModal>", modelName];
    NSString *carShortModal = [NSString stringWithFormat:@"<tem:carShortModal>%@</tem:carShortModal>", @""];
    NSString *documentPrice = [NSString stringWithFormat:@"<tem:totalPrice>%@</tem:totalPrice>", totalPrice];
    NSString *currency = [NSString stringWithFormat:@"<tem:currency>%@</tem:currency>", @"TRY"];
    NSString *language = [NSString stringWithFormat:@"<tem:lang>%@</tem:lang>", @""];
    NSString *closeFunction = @"</tem:Rezervation>";
    NSString *closeBody = @"</soapenv:Body>";
    NSString *closeHeader = @"</soapenv:Envelope>";
    
    NSString *soapMsg = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", signature, openHeader, openBody, openFunction, mailAdress, fullName, reservationCode,pickUpLocation,pickUpDate, deliveryLocation, deliveryDate, payType, carRezType, carBrand, carModal, carShortModal, documentPrice, currency, language, closeFunction, closeBody, closeHeader];
    
    NSMutableURLRequest *soapReq = [NSMutableURLRequest requestWithURL:connectionURL];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu" , (unsigned long)[soapMsg length]];
    [soapReq addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [soapReq addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [soapReq setHTTPMethod:@"POST"];
    [soapReq setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:soapReq returningResponse:&response error:&error];
    
    if (error == nil && data != nil && [data length] > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
