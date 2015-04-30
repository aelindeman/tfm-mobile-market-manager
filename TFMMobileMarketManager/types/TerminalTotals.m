//
//  TerminalTotals.m
//  tfmco-mip
//

#import "TerminalTotals.h"
#import "MarketDays.h"


@implementation TerminalTotals

@dynamic credit_amount;
@dynamic credit_transactions;
@dynamic snap_amount;
@dynamic snap_transactions;
@dynamic total_amount;
@dynamic total_transactions;
@dynamic marketday;

- (NSString *)description
{
	return [NSString stringWithFormat:@"Terminal totals for %@", [self.marketday fieldDescription]];
}

@end
