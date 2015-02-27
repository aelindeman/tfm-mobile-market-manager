//
//  MarketDayListViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Location.h"
#import "MarketDay.h"
#import "MarketDayFormViewController.h"
#import "Staff.h"
#import "FXForms.h"

@interface MarketDayListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
