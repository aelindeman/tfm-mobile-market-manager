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
@property (nonatomic, retain) NSString *email;
@property (nonatomic) int16_t position;
@property (nonatomic, retain) NSSet *marketdays;

- (NSString *)description;
- (NSString *)fieldDescription;

@end
