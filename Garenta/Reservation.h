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
#import "CampaignObject.h"

@interface Reservation : NSObject

@property (nonatomic,retain) CarGroup *selectedCarGroup;
@property (nonatomic,retain) CarGroup *upsellCarGroup;
@property (nonatomic,retain) Office *checkOutOffice;
@property (nonatomic,retain) NSDate *checkOutTime;
@property (nonatomic,retain) Office *checkInOffice;
@property (nonatomic,retain) NSDate *checkInTime;
@property (nonatomic,retain) NSString *number;
@property (nonatomic,retain) NSString *reservationStatuId;  // E0003,E0008,VS...
@property (nonatomic,retain) NSString *reservationStatu;    // İptal,no show, ödeme yapılmış vs.vs. text
@property (strong,nonatomic) NSMutableArray *additionalEquipments;
@property (strong,nonatomic) NSMutableArray *additionalFullEquipments;
@property (strong,nonatomic) NSMutableArray *additionalDrivers;
@property (strong,nonatomic) NSMutableArray *etReserv;
@property (strong,nonatomic) Car *selectedCar;
@property (strong,nonatomic) Car *upsellSelectedCar;
@property (copy,nonatomic) NSString *reservationNumber;
@property (strong, nonatomic) CreditCard *paymentNowCard;
@property (strong, nonatomic) User *temporaryUser;
@property (strong, nonatomic) NSString *paymentType;  // 1-şimdi öde, 2 sonra öde
@property (strong,nonatomic) NSDecimalNumber *changeReservationDifference;
@property (strong,nonatomic) NSDecimalNumber *documentTotalPrice;
@property (strong,nonatomic) NSString *reservationType; // 10-araca, 20-gruba
@property (strong,nonatomic) NSString *updateStatus; // Update fonksiyonunda IV_UPDATE_STATUS için kullanılır
@property (strong, nonatomic) NSMutableArray *etExpiry;
@property (strong,nonatomic) NSMutableArray *upsellList;
@property (strong,nonatomic) NSMutableArray *downsellList;
@property (strong,nonatomic) CampaignObject *campaignObject;
@property CampaignReservationType campaignButtonPressed;
@property (nonatomic,retain) NSString *minCheckOutTime;  //rezervasyonun minimum kaç saat sonraya yapılacağı
@property (nonatomic,retain) NSString *minPayLatertime;  // sonra ödenin minimum kaç saat sonraya yapılacağı

// Ata Cengiz 05.02.2015
@property (nonatomic) BOOL becomePriority;
@property (nonatomic) BOOL gainGarentaTL;
@property (nonatomic) BOOL gainMiles;
@property (nonatomic, strong) NSString *tkNumber;
@property (nonatomic, strong) NSString *corporateReceiptNumber;
// Ata Cengiz 05.02.2015

// Ata Cengiz 12.02.2015
@property (nonatomic) BOOL isContract;
@property (nonatomic, strong) NSString *isUpgradeTime;
@property (nonatomic, strong) NSString *upgradePriceCode;
@property (nonatomic, strong) NSString *upgradeCampaignID;
// Ata Cengiz 12.02.2015

-(NSDecimalNumber*)totalPriceWithCurrency:(NSString*)currency isPayNow:(BOOL)isPayNow andGarentaTl:(NSString *)garentaTl andIsMontlyRent:(BOOL)isMontlyRent andIsCorparatePayment:(BOOL)isCorparate andIsPersonalPayment:(BOOL)isPersonalPayment andReservation:(Reservation *)reservation;

- (id)initWithMinCheckOutTime:(NSString *)aCheckOutTime andMinPayLaterTime:(NSString *)aPayLaterTime;

+ (NSString *)createReservationAtSAP:(Reservation *)_reservation andIsPayNow:(BOOL)isPayNow andGarentaTl:(NSString *)garentaTl;
+ (BOOL)changeReservationAtSAP:(Reservation *)_reservation andIsPayNow:(BOOL)isPayNow andTotalPrice:(NSDecimalNumber *)totalPrice andGarentaTl:(NSString *)garentaTl;
+ (BOOL)changeContractAtSAP:(Reservation *)_reservation andTotalPrice:(NSDecimalNumber *)aTotalPrice;
+ (NSString *)getCustomerIP;

@end
