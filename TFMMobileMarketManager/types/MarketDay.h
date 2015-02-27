//
//  MarketDay.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>

#import "Location.h"
#import "Staff.h"
#import "TokenBank.h"

@interface MarketDay : NSObject

@property unsigned long identifier;

@property Location *location;
@property NSSet *vendors;

@property NSDate *date;
@property NSTimeInterval length; /* start time is the time portion of (self.date), end time is (self.date + length) */
@property NSSet *staff;
@property NSString * notes;

@property NSSet *transactions;
@property NSSet *redemptions;
@property NSSet *terminal_totals;
@property TokenBank *tokenbank;

@end