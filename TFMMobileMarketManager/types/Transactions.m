//
//  Transactions.m
//  tfmco-mip
//

#import "Transactions.h"
#import "MarketDays.h"


@implementation Transactions

@dynamic credit_fee;
@dynamic credit_total;
@dynamic credit_used;
@dynamic cust_ethnicity;
@dynamic cust_frequency;
@dynamic cust_gender;
@dynamic cust_id;
@dynamic cust_referral;
@dynamic cust_senior;
@dynamic cust_zipcode;
@dynamic markedInvalid;
@dynamic snap_bonus;
@dynamic snap_total;
@dynamic snap_used;
@dynamic marketday;
@dynamic time;

- (NSString *)description
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"HH:mm:ss"];

	return [NSString stringWithFormat:@"%@ at %@ - $%i using %@%@",
		[self.marketday fieldDescription],
		[df stringFromDate:self.time],
		(self.snap_used) ? self.snap_total : (self.credit_used) ? self.credit_total : 0,
		(self.snap_used) ? @"SNAP" : (self.credit_used) ? @"credit" : @"unknown",
		(self.markedInvalid) ? @" (Invalid)" : @""];
}

@end
