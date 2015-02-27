//
//  Vendors.m
//  tfmco-mip
//

#import "Vendor.h"

@implementation Vendor

@dynamic identifier;

@dynamic business_name;
@dynamic product_types;

@dynamic name;
@dynamic address;
@dynamic phone;
@dynamic email;

@dynamic state_tax_id;
@dynamic federal_tax_id;

@dynamic marketdays;
@dynamic redemptions;

- (NSString *)fieldDescription
{
	return self.business_name;
}

@end
