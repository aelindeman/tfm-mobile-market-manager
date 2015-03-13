//
//  MarketDayListViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketDays.h"
#import "MarketDayFormViewController.h"
#import "FXForms.h"

@interface MarketDayListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
