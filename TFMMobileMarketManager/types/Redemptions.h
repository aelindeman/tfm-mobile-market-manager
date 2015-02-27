//
//  Redemptions.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>

#import "MarketDay.h"
#import "Vendor.h"

@interface Redemptions : NSObject

@property unsigned long identifier;

@property NSDate *date;
@property unsigned int check_number;

@property unsigned int bonus_count;
@property unsigned int credit_amount;
@property unsigned int credit_count;

@property unsigned int snap_count;
@property unsigned int total;

@property bool markedInvalid;

@property MarketDay *marketday;
@property Vendor *vendor;

@end
