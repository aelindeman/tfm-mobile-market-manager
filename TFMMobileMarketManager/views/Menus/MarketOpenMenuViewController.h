//
//  MarketOpenMenuViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"

@protocol MarketOpenDelegate

@optional
- (void)updateInfoLabels;
- (void)updateTerminalReconcilationStatus:(bool)status;
- (void)updateTokenReconcilationStatus:(bool)status;

@end

#import "MarketDayFormViewController.h"
#import "Redemptions.h"
#import "RedemptionFormViewController.h"
#import "TerminalTotalsReconciliationViewController.h"
#import "TokenTotalsReconciliationFormViewController.h"
#import "Transactions.h"
#import "TransactionFormViewController.h"

@interface MarketOpenMenuViewController : UITableViewController <MarketOpenDelegate>

@property (nonatomic, assign) id <MarketOpenDelegate> delegate;

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property (weak, nonatomic) IBOutlet UILabel *vendorHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *vendorDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *redemptionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *redemptionDetailLabel;

@property bool terminalTotalsReconciled;
@property bool tokenTotalsReconciled;

@end
