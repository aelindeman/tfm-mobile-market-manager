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

- (NSString *)fieldDescription
{
	NSString *locationName = [(Locations *)self.location name];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	NSString *date = [dateFormatter stringFromDate:self.date];
	
	return [NSString stringWithFormat:@"%@ – %@", locationName, date];
}

@end
