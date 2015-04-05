//
//  ReportsMenuViewController.h
//  tfmco-mip
//

#import <QuickLook/QuickLook.h>
#import "AppDelegate.h"
#import "ReportGenerator.h"

@protocol ReportsMenuDelegate

@optional
- (void)setMarketDayFromID:(NSManagedObjectID *)objectID;

@end

#import "SelectExistingReportViewController.h"
#import "SelectMarketDayViewController.h"

@interface ReportsMenuViewController : UITableViewController <QLPreviewControllerDataSource, ReportsMenuDelegate>

@property (nonatomic, assign) id <ReportsMenuDelegate> delegate;

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property NSString *mostRecentReportPath;

@property (nonatomic) NSManagedObjectID *selectedMarketDayID;
@property (nonatomic) MarketDays *selectedMarketDay;

@property (nonatomic) QLPreviewController *previewer;

@end
