//
//  ReportsMenuViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "ReportGenerator.h"

@protocol ReportsMenuDelegate

@optional
- (void)setMarketDayFromID:(NSManagedObjectID *)objectID;

@end

#import "SelectExistingReportViewController.h"
#import "SelectMarketDayViewController.h"

@interface ReportsMenuViewController : UITableViewController <ReportsMenuDelegate>

@property (nonatomic, assign) id <ReportsMenuDelegate> delegate;

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property (nonatomic) NSManagedObjectID *selectedMarketDayID;
@property (nonatomic) MarketDays *selectedMarketDay;

@end
