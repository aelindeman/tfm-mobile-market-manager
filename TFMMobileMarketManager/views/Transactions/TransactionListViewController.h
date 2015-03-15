//
//  TransactionListViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Transactions.h"
#import "TransactionFormViewController.h"
#import "FXForms.h"

@interface TransactionListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) Transactions *selectedObject;

@end
