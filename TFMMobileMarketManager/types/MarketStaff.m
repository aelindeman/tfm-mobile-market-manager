//
//  MarketStaff.m
//  tfmco-mip
//

#import "MarketStaff.h"
#import "MarketDays.h"


@implementation MarketStaff

@dynamic name;
@dynamic phone;
@dynamic position;
@dynamic marketday;

- (NSString *)description
{
	return self.name;
}

- (NSString *)fieldDescription
{
	return [self description];
}

@end
