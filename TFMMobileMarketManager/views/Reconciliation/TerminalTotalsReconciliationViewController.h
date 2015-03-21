//
//  TerminalTotalsReconciliationViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "ReconciliationEntryTableViewCell.h"
#import "TerminalTotals.h"
#import "Transactions.h"

@interface TerminalTotalsReconciliationViewController : UITableViewController

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) TerminalTotals *editObject;
@property bool editMode;

@end
