//
//  TerminalTotals.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>

#import "MarketDay.h"

@interface TerminalTotals : NSObject

@property unsigned long identifier;

@property unsigned int credit_amount;
@property unsigned int credit_transactions;

@property unsigned int snap_amount;
@property unsigned int snap_transactions;

@property unsigned int total_amount;
@property unsigned int total_transactions;

@property MarketDay *marketday;

@end
