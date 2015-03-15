//
//  MarketDayForm.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Locations.h"
#import "MarketStaff.h"
#import "Vendors.h"
#import "FXForms.h"

@interface MarketDayForm : NSObject <FXForm>

@property Locations *location;

@property NSArray *vendors;
@property NSUInteger vendorsCount;

@property NSDate *date;
@property NSDate *start_time;
@property NSDate *end_time;

@property (nonatomic, strong) NSArray *staff;
@property NSString *notes;

- (NSArray *)loadLocations;
- (NSArray *)loadStaff;
- (NSArray *)loadVendors;

@end
