//
//  Locations.m
//  TFMMobileMarketManager
//

#import "Location.h"

@implementation Location

@dynamic identifier;

@dynamic abbreviation;
@dynamic address;
@dynamic name;
@dynamic marketdays;

- (NSString *)fieldDescription
{
	return self.name;
}

@end
