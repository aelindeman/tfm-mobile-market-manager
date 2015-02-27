//
//  RedemptionsListViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Redemptions.h"
#import "RedemptionFormViewController.h"
#import "FXForms.h"

@interface RedemptionsListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
