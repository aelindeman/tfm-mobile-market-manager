//
//  TokenBankTotals.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>

#import "MarketDay.h"

@interface TokenBank : NSObject

@property unsigned long identifier;

@property unsigned int market_snap_tokens;
@property unsigned int market_bonus_tokens;
@property unsigned int market_credit_tokens;

@property unsigned int redeemed_snap_tokens;
@property unsigned int redeemed_bonus_tokens;
@property unsigned int redeemed_credit_tokens;

@property MarketDay *marketday;

@end
