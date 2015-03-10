//
//  VendorForm.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FXForms.h"

@interface VendorForm : NSObject <FXForm>

// Basic info
@property NSString *businessName;
@property NSString *productTypes; // description

// Business info
@property NSString *name; // owner/operator name
@property NSString *address;

// Contact info
@property NSString *phone;
@property NSString *email;

// Transaction info
@property bool acceptsSNAP;
@property bool acceptsIncentives;

// Tax info
@property NSString *stateTaxID;
@property NSString *federalTaxID;

@end
