//
//  TerminalTotalsReconciliationViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "MarketOpenMenuViewController.h"
#import "ReconciliationEntryTableViewCell.h"
#import "TerminalTotals.h"
#import "Transactions.h"

@interface TerminalTotalsReconciliationViewController : UITableViewController <MarketOpenDelegate>

@property (nonatomic, assign) id <MarketOpenDelegate> delegate;

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property ReconciliationEntryTableViewCell *inputCell;
@property ReconciliationEntryTableViewCell *deviceCell;

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) TerminalTotals *editObject;

@end
