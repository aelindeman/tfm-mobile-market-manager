//
//  ReportsMenuViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "ReportGenerator.h"

@protocol ReportsMenuDelegate

- (void)updateStatus;

@end

@interface ReportsMenuViewController : UITableViewController

@property (nonatomic, assign) id <ReportsMenuDelegate> delegate;

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property (nonatomic) MarketDays *selectedMarketDay;

@end
