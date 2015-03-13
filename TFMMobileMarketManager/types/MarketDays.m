//
//  MarketDays.m
//  tfmco-mip
//

#import "MarketDays.h"


@implementation MarketDays

@dynamic date;
@dynamic end_time;
@dynamic notes;
@dynamic start_time;
@dynamic location;
@dynamic redemptions;
@dynamic staff;
@dynamic terminalTotals;
@dynamic tokenTotals;
@dynamic transactions;
@dynamic vendors;

- (NSString *)description
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	NSString *date = [dateFormatter stringFromDate:self.date];
	
	return [NSString stringWithFormat:@"%@ – %@", [self.location description], date];
}

- (NSString *)fieldDescription
{
	return [self description];
}

@end
