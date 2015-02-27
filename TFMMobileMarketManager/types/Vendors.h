//
//  Vendors.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays, Redemptions;

@interface Vendors : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * business_name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * federal_tax_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * product_types;
@property (nonatomic, retain) NSString * state_tax_id;
@property (nonatomic, retain) NSSet *marketdays;
@property (nonatomic, retain) NSSet *redemptions;
@end

@interface Vendors (CoreDataGeneratedAccessors)

- (NSString *)fieldDescription;

- (void)addMarketdaysObject:(MarketDays *)value;
- (void)removeMarketdaysObject:(MarketDays *)value;
- (void)addMarketdays:(NSSet *)values;
- (void)removeMarketdays:(NSSet *)values;

- (void)addRedemptionsObject:(Redemptions *)value;
- (void)removeRedemptionsObject:(Redemptions *)value;
- (void)addRedemptions:(NSSet *)values;
- (void)removeRedemptions:(NSSet *)values;

@end
