//
//  Locations.m
//  tfmco-mip
//

#import "Locations.h"
#import "MarketDays.h"


@implementation Locations

@dynamic address;
@dynamic name;
@dynamic marketdays;

- (NSString *)description
{
	return self.name;
}

- (NSString *)fieldDescription
{
	return self.name;
}

@end
