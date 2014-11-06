//
//  Reservation.h
//  Garenta
//
//  Created by Kerem Balaban on 21.12.2013.
//  Copyright (c) 2013 Kerem Balaban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Destination.h"
#import "Arrival.h"
#import "CarGroup.h"
#import "Car.h"
#import "CreditCard.h"
#import "User.h"

@interface Reservation : NSObject

@property (nonatomic,retain) CarGroup *selectedCarGroup;
@property (nonatomic,retain) Office *checkOutOffice;
@property (nonatomic,retain) NSDate *checkOutTime;
@property (nonatomic,retain) Office *checkInOffice;
@property (nonatomic,retain) NSDate *checkInTime;
@property (nonatomic,retain) NSString *number;
@property (nonatomic,retain) NSString *reservationStatu;
@property (strong,nonatomic) NSMutableArray *additionalEquipments;
@property (strong,nonatomic) NSMutableArray *additionalDrivers;
@property (strong,nonatomic) NSMutableArray *etReserv;
@property (strong,nonatomic) Car *selectedCar;
@property (copy,nonatomic) NSString *reservationNumber;
@property (strong, nonatomic) CreditCard *paymentNowCard;
@property (strong, nonatomic) User *temporaryUser;
@property (strong, nonatomic) NSString *paymentType;  // 1-şimdi öde, 2 sonra öde
@property (strong,nonatomic) NSDecimalNumber *changeReservationDifference;
@property (strong,nonatomic) NSString *reservationType; // 10-araca, 20-gruba
@property (strong,nonatomic) NSString *updateStatus; // Update fonksiyonunda IV_UPDATE_STATUS için kullanılır
@property (strong, nonatomic) NSArray *etExpiry;

-(NSDecimalNumber*)totalPriceWithCurrency:(NSString*)currency isPayNow:(BOOL)isPayNow andGarentaTl:(NSString *)garentaTl andIsMontlyRent:(BOOL)isMontlyRent;

+ (NSString *)createReservationAtSAP:(Reservation *)_reservation andIsPayNow:(BOOL)isPayNow;
+ (BOOL)changeReservationAtSAP:(Reservation *)_reservation andIsPayNow:(BOOL)isPayNow andTotalPrice:(NSDecimalNumber *)totalPrice;
+ (NSString *)getCustomerIP;

@end
