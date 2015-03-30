//
//  SelectMarketDayViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "MarketDays.h"
#import "ReportsMenuViewController.h"

@interface SelectMarketDayViewController : UITableViewController <NSFetchedResultsControllerDelegate, ReportsMenuDelegate>

@property (nonatomic, assign) id <ReportsMenuDelegate> delegate;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) MarketDays *selectedObject;

@end
