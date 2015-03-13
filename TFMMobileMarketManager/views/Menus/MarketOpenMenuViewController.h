//
//  MarketOpenMenuViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketDayFormViewController.h"
#import "TerminalTotalsReconciliationFormViewController.h"
#import "TokenTotalsReconciliationFormViewController.h"

@interface MarketOpenMenuViewController : UITableViewController

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@end
