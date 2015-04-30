//
//  MarketStaff.m
//  tfmco-mip
//

#import "MarketStaff.h"
#import "MarketDays.h"


@implementation MarketStaff

@dynamic name;
@dynamic phone;
@dynamic email;
@dynamic position;
@dynamic marketdays;

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%i) - %tu market day%@",
		self.name,
		self.position,
		[self.marketdays count],
		([self.marketdays count] == 1) ? @"" : @"s"];
}

- (NSString *)fieldDescription
{
	return self.name;
}

@end
