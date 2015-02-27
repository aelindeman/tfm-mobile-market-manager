//
//  MarketStaff.m
//  tfmco-mip
//

#import "MarketStaff.h"
#import "MarketDays.h"


@implementation MarketStaff

@dynamic name;
@dynamic position;
@dynamic marketday;

- (NSString *)fieldDescription
{
	return self.name;
}

@end
