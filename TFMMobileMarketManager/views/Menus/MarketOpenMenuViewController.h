//
//  MarketOpenMenuViewController.h
//  tfmco-mip
//

#import <QuickLook/QuickLook.h>
#import "AppDelegate.h"

@protocol MarketOpenDelegate

@optional
- (void)updateInfoLabels;

- (void)notifyTerminalReconciliationStatus:(bool)status;
- (void)updateTerminalReconciliationStatus:(bool)status;
- (void)updateTokenReconciliationStatus:(bool)status;

@end

#import "MarketDayFormViewController.h"
#import "Redemptions.h"
#import "RedemptionFormViewController.h"
#import "TerminalTotalsReconciliationViewController.h"
#import "TokenTotalsReconciliationFormViewController.h"
#import "Transactions.h"
#import "TransactionFormViewController.h"

@interface MarketOpenMenuViewController : UITableViewController <MarketOpenDelegate, QLPreviewControllerDataSource>

@property (nonatomic, assign) id <MarketOpenDelegate> delegate;

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property (nonatomic) QLPreviewController *helpViewer;

@property (weak, nonatomic) IBOutlet UILabel *vendorHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *vendorDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *redemptionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *redemptionDetailLabel;

@property bool terminalTotalsReconciled;
@property bool tokenTotalsReconciled;

@end
