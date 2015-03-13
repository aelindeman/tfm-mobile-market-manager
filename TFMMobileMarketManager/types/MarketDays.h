//
//  MarketDays.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MarketDays : NSManagedObject

@property (nonatomic) NSDate *date;
@property (nonatomic) int32_t end_time;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic) int32_t start_time;
@property (nonatomic, retain) NSManagedObject *location;
@property (nonatomic, retain) NSSet *redemptions;
@property (nonatomic, retain) NSSet *staff;
@property (nonatomic, retain) NSSet *terminalTotals;
@property (nonatomic, retain) NSManagedObject *tokenTotals;
@property (nonatomic, retain) NSOrderedSet *transactions;
@property (nonatomic, retain) NSSet *vendors;
@end

@interface MarketDays (CoreDataGeneratedAccessors)

- (void)addRedemptionsObject:(NSManagedObject *)value;
- (void)removeRedemptionsObject:(NSManagedObject *)value;
- (void)addRedemptions:(NSSet *)values;
- (void)removeRedemptions:(NSSet *)values;

- (void)addStaffObject:(NSManagedObject *)value;
- (void)removeStaffObject:(NSManagedObject *)value;
- (void)addStaff:(NSSet *)values;
- (void)removeStaff:(NSSet *)values;

- (void)addTerminal_totalsObject:(NSManagedObject *)value;
- (void)removeTerminal_totalsObject:(NSManagedObject *)value;
- (void)addTerminal_totals:(NSSet *)values;
- (void)removeTerminal_totals:(NSSet *)values;

- (void)insertObject:(NSManagedObject *)value inTransactionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTransactionsAtIndex:(NSUInteger)idx;
- (void)insertTransactions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTransactionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTransactionsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceTransactionsAtIndexes:(NSIndexSet *)indexes withTransactions:(NSArray *)values;
- (void)addTransactionsObject:(NSManagedObject *)value;
- (void)removeTransactionsObject:(NSManagedObject *)value;
- (void)addTransactions:(NSOrderedSet *)values;
- (void)removeTransactions:(NSOrderedSet *)values;
- (void)addVendorsObject:(NSManagedObject *)value;
- (void)removeVendorsObject:(NSManagedObject *)value;
- (void)addVendors:(NSSet *)values;
- (void)removeVendors:(NSSet *)values;

@end
