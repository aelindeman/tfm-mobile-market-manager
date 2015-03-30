//
//  ReportGenerator.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Locations.h"
#import "MarketDays.h"
#import "MarketStaff.h"
#import "Redemptions.h"
#import "TerminalTotals.h"
#import "TokenTotals.h"
#import "Transactions.h"
#import "Vendors.h"

@interface ReportGenerator : NSObject

- (id) initWithMarketDay:(MarketDays *)marketDay;

- (NSString *)generateDemographicsReport;
- (void)generateDemographicsReportAtPath:(NSString *)path;

- (NSString *)generateRedemptionsReport;
- (void)generateRedemptionsReportAtPath:(NSString *)path;

- (NSString *)generateSalesReport;
- (void)generateSalesReportAtPath:(NSString *)path;

@property (nonatomic) NSManagedObjectID *selectedMarketDayID;
@property (nonatomic) MarketDays *selectedMarketDay;

@end
