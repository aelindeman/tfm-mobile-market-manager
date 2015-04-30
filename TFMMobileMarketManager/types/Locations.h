//
//  Locations.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays;

@interface Locations : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *marketdays;
@end

@interface Locations (CoreDataGeneratedAccessors)

- (NSString *)description;
- (NSString *)fieldDescription;

- (void)addMarketdaysObject:(MarketDays *)value;
- (void)removeMarketdaysObject:(MarketDays *)value;
- (void)addMarketdays:(NSSet *)values;
- (void)removeMarketdays:(NSSet *)values;

@end
