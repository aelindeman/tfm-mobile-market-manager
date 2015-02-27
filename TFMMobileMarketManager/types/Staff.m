//
//  MarketStaff.m
//  TFMMobileMarketManager
//

#import "Staff.h"

@implementation Staff

@dynamic identifier;

@dynamic name;
@dynamic position;

@dynamic marketday;

- (NSString *)fieldDescription
{
	return self.name;
}

@end
