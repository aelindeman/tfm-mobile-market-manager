//
//  ReportTool.h
//  TFMMobileMarketManager
//

// report names
#ifndef TFMM3_REPORT_TYPES_ALL
	#define TFMM3_REPORT_TYPE_DEMOGRAPHICS @"Demographics"
	#define TFMM3_REPORT_TYPE_REDEMPTIONS  @"Redemptions"
	#define TFMM3_REPORT_TYPE_SALES        @"Sales"
	#define TFMM3_REPORT_TYPE_VENDORS      @"Vendors"
	#define TFMM3_REPORT_TYPE_STAFF        @"Staff"
	#define TFMM3_REPORT_TYPE_LOCATIONS    @"Locations"
	#define TFMM3_REPORT_TYPE_DUMP         @"Dump"
	#define TFMM3_REPORT_TYPES_MARKETDAY   @[TFMM3_REPORT_TYPE_DEMOGRAPHICS, TFMM3_REPORT_TYPE_REDEMPTIONS, TFMM3_REPORT_TYPE_SALES]
	#define TFMM3_REPORT_TYPES_ALL         @[TFMM3_REPORT_TYPE_DEMOGRAPHICS, TFMM3_REPORT_TYPE_REDEMPTIONS, TFMM3_REPORT_TYPE_SALES, TFMM3_REPORT_TYPE_VENDORS, TFMM3_REPORT_TYPE_STAFF, TFMM3_REPORT_TYPE_LOCATIONS, TFMM3_REPORT_TYPE_DUMP]
#endif

#import "AppDelegate.h"
#import "Locations.h"
#import "MarketDays.h"
#import "MarketStaff.h"
#import "Redemptions.h"
#import "TerminalTotals.h"
#import "TokenTotals.h"
#import "Transactions.h"
#import "Vendors.h"

@interface ReportTool : NSObject

- (id) initWithMarketDay:(MarketDays *)marketDay;

- (NSString *)generateDemographicsReport;
- (bool)generateDemographicsReportAtPath:(NSString *)path;

- (NSString *)generateRedemptionsReport;
- (bool)generateRedemptionsReportAtPath:(NSString *)path;

- (NSString *)generateSalesReport;
- (bool)generateSalesReportAtPath:(NSString *)path;

- (NSString *)generateVendorsReport;
- (bool)generateVendorsReportAtPath:(NSString *)path;

- (NSString *)generateStaffReport;
- (bool)generateStaffReportAtPath:(NSString *)path;

- (NSString *)generateLocationsReport;
- (bool)generateLocationsReportAtPath:(NSString *)path;

- (NSString *)dump;
- (bool)dumpAtPath:(NSString *)path;

@property (nonatomic) NSManagedObjectID *selectedMarketDayID;
@property (nonatomic) MarketDays *selectedMarketDay;

@property NSString *failureReason;

@end
