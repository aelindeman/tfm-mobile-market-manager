//
//  RedemptionForm.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Vendors.h"
#import "FXForms.h"

@interface RedemptionForm : NSObject <FXForm>

// Administrative
@property Vendors *vendor;
@property NSDate *date;
@property NSUInteger check_number;

// Tokens
@property NSUInteger snap_count;
@property NSUInteger bonus_count;
@property NSUInteger credit_count;

// Automatically calculated fields
@property NSUInteger credit_amount;
@property NSUInteger total;

@property BOOL markedInvalid;

- (NSArray *)loadVendors;

@end
