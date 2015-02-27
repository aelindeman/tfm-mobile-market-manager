//
//  MarketStaff.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>

#import "MarketDay.h"

@interface Staff : NSObject

@property unsigned long identifier;

@property NSString *name;
@property NSString *position;

@property MarketDay *marketday;

- (NSString *)fieldDescription;

@end
