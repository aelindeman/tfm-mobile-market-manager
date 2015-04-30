//
//  Redemptions.m
//  tfmco-mip
//

#import "Redemptions.h"
#import "MarketDays.h"


@implementation Redemptions

@dynamic bonus_count;
@dynamic check_number;
@dynamic credit_amount;
@dynamic credit_count;
@dynamic date;
@dynamic markedInvalid;
@dynamic snap_count;
@dynamic total;
@dynamic marketday;
@dynamic vendor;

- (NSString *)description
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd"];

	return [NSString stringWithFormat:@"%@ - $%i on %@%@",
		[self.vendor valueForKey:@"name"],
		self.total,
		[df stringFromDate:self.date],
		(!self.check_number) ? @"" : [NSString stringWithFormat:@" (check %i)", self.check_number]];
}

@end
