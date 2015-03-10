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
@dynamic marketdays;
@dynamic redemptions;

- (NSString *)fieldDescription
{
	return self.businessName;
}

@end
