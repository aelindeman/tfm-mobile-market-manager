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
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd"];
	
	return [NSString stringWithFormat:@"%@ %@ - %tu staff, %tu vendor%@ - %tu transaction%@, %tu redemption%@",
		[df stringFromDate:self.date],
		[self.location valueForKey:@"name"],
		[self.staff count],
		[self.vendors count],
		([self.vendors count] == 1) ? @"" : @"s",
		[self.transactions count],
		([self.transactions count] == 1) ? @"" : @"s",
		[self.redemptions count],
		([self.redemptions count] == 1) ? @"" : @"s"];
}

- (NSString *)fieldDescription
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	
	return [NSString stringWithFormat:@"%@ - %@",
		[self.location description],
		[dateFormatter stringFromDate:self.date]];
}

@end
