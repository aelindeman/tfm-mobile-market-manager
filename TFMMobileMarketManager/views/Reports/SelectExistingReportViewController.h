//
//  SelectExistingReportViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "ReportsMenuViewController.h"

@interface SelectExistingReportViewController : UITableViewController <ReportsMenuDelegate>

@property (nonatomic, assign) id <ReportsMenuDelegate> delegate;

@end
