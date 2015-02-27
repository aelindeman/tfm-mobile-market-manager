//
//  Vendors.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>

@interface Vendor : NSObject

@property unsigned long identifier;

@property NSString *business_name;
@property NSString *product_types;

@property NSString *name;
@property NSString *address;
@property NSString *phone;
@property NSString *email;

@property NSString *state_tax_id;
@property NSString *federal_tax_id;

@property NSSet *marketdays;
@property NSSet *redemptions;

- (NSString *)fieldDescription;

@end
