//
//  TerminalTotals.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays;

@interface TerminalTotals : NSManagedObject

@property (nonatomic) int16_t credit_amount;
@property (nonatomic) int16_t credit_transactions;
@property (nonatomic) int16_t snap_amount;
@property (nonatomic) int16_t snap_transactions;
@property (nonatomic) int16_t total_amount;
@property (nonatomic) int16_t total_transactions;
@property (nonatomic, retain) MarketDays *marketday;

@end
