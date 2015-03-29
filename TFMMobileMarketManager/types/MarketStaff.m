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
	return self.name;
}

- (NSString *)fieldDescription
{
	return [self description];
}

@end
