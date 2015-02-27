//
//  Locations.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>

#import "MarketDay.h"

@interface Location : NSObject

@property unsigned long identifier;

@property NSString *abbreviation;
@property NSString *address;
@property NSString *name;

@property NSSet *marketdays;

- (NSString *)fieldDescription;

@end
