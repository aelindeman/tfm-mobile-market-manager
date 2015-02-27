//
//  VendorForm.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FXForms.h"

@interface VendorForm : NSObject <FXForm>

// Basic info
@property NSString *business_name;
@property NSString *product_types; // description

// Business info
@property NSString *name; // owner/operator name
@property NSString *address;

// Contact info
@property NSString *phone;
@property NSString *email;

// Tax info
@property NSString *state_tax_id;
@property NSString *federal_tax_id;

@end
