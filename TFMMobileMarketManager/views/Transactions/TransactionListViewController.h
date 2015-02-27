//
//  TransactionListViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Transaction.h"
#import "TransactionFormViewController.h"
#import "FXForms.h"

@interface TransactionListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
