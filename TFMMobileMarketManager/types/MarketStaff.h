//
//  MarketStaff.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays;

@interface MarketStaff : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic) int16_t position;
@property (nonatomic, retain) MarketDays *marketday;

- (NSString *)description;
- (NSString *)fieldDescription;

@end
