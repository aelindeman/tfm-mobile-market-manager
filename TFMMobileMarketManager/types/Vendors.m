//
//  Vendors.m
//  tfmco-mip
//

#import "Vendors.h"
#import "MarketDays.h"
#import "Redemptions.h"


@implementation Vendors

@dynamic address;
@dynamic business_name;
@dynamic email;
@dynamic federal_tax_id;
@dynamic name;
@dynamic phone;
@dynamic product_types;
@dynamic state_tax_id;
@dynamic marketdays;
@dynamic redemptions;

- (NSString *)fieldDescription
{
	return self.business_name;
}

@end
