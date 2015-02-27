//
//  LocationsListViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Location.h"
#import "LocationsFormViewController.h"
#import "FXForms.h"

@interface LocationsListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
