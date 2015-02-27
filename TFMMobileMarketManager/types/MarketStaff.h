//
//  MarketStaff.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarketDays;

@interface MarketStaff : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *position;
@property (nonatomic, retain) MarketDays *marketday;

- (NSString *)fieldDescription;

@end
