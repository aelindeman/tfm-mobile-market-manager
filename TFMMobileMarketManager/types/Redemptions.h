//
//  Redemptions.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays;

@interface Redemptions : NSManagedObject

@property (nonatomic) int16_t bonus_count;
@property (nonatomic) int16_t check_number;
@property (nonatomic) int16_t credit_amount;
@property (nonatomic) int16_t credit_count;
@property (nonatomic) NSDate *date;
@property (nonatomic) BOOL markedInvalid;
@property (nonatomic) int16_t snap_count;
@property (nonatomic) int16_t total;
@property (nonatomic, retain) MarketDays *marketday;
@property (nonatomic, retain) NSManagedObject *vendor;

- (NSString *)description;

@end
