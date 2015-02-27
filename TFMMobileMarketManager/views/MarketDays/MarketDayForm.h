//
//  MarketDayForm.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Location.h"
#import "Staff.h"
#import "Vendor.h"
#import "FXForms.h"

@interface MarketDayForm : NSObject <FXForm>

@property Location *location;

@property NSArray *vendors;

@property NSDate *date;
@property NSDate *start_time;
@property NSDate *end_time;

@property (nonatomic, strong) NSArray *staff;
@property NSString *notes;

- (NSArray *)loadLocations;
- (NSArray *)loadStaff;
- (NSArray *)loadVendors;

@end
