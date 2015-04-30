//
//  Vendors.m
//  tfmco-mip
//

#import "Vendors.h"
#import "MarketDays.h"
#import "Redemptions.h"


@implementation Vendors

@dynamic address;
@dynamic businessName;
@dynamic email;
@dynamic federalTaxID;
@dynamic name;
@dynamic phone;
@dynamic productTypes;
@dynamic stateTaxID;
@dynamic acceptsSNAP;
@dynamic acceptsIncentives;
@dynamic marketdays;
@dynamic redemptions;

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%@) - %i market day%@, %i redemption%@",
		self.businessName,
		self.name,
		[self.marketdays count],
		([self.marketdays count] == 1) ? @"" : @"s",
		[self.redemptions count],
		([self.redemptions count] == 1) ? @"" : @"s"];
}

- (NSString *)fieldDescription
{
	return self.businessName;
}

@end
