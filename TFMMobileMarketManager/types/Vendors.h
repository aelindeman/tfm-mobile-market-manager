//
//  Vendors.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays, Redemptions;

@interface Vendors : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * businessName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * federalTaxID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * productTypes;
@property (nonatomic, retain) NSString * stateTaxID;
@property (nonatomic) bool acceptsSNAP;
@property (nonatomic) bool acceptsIncentives;
@property (nonatomic, retain) NSSet *marketdays;
@property (nonatomic, retain) NSSet *redemptions;
@end

@interface Vendors (CoreDataGeneratedAccessors)

- (NSString *)description;
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
