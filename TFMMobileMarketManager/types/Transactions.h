//
//  Transactions.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays;

@interface Transactions : NSManagedObject

@property (nonatomic) int16_t credit_fee;
@property (nonatomic) int16_t credit_total;
@property (nonatomic) BOOL credit_used;
@property (nonatomic) int16_t cust_ethnicity;
@property (nonatomic) int16_t cust_frequency;
@property (nonatomic) BOOL cust_gender;
@property (nonatomic) int16_t cust_id;
@property (nonatomic, retain) NSString * cust_referral;
@property (nonatomic) BOOL cust_senior;
@property (nonatomic) NSString * cust_zipcode;
@property (nonatomic) BOOL markedInvalid;
@property (nonatomic) int16_t snap_bonus;
@property (nonatomic) int16_t snap_total;
@property (nonatomic) BOOL snap_used;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic, retain) MarketDays *marketday;

@end
