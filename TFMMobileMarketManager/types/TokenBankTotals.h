//
//  TokenBankTotals.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays;

@interface TokenBankTotals : NSManagedObject

@property (nonatomic) int16_t market_bonus_tokens;
@property (nonatomic) int16_t market_credit_tokens;
@property (nonatomic) int16_t market_snap_tokens;
@property (nonatomic) int16_t redeemed_bonus_tokens;
@property (nonatomic) int16_t redeemed_credit_tokens;
@property (nonatomic) int16_t redeemed_snap_tokens;
@property (nonatomic, retain) MarketDays *marketday;

@end
