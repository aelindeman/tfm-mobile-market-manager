//
//  MarketOpenMenuViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketDayFormViewController.h"
#import "Redemptions.h"
#import "TerminalTotalsReconciliationViewController.h"
#import "TokenTotalsReconciliationFormViewController.h"
#import "Transactions.h"

@protocol MarketOpenDelegate

@optional
- (void)updateInfoLabels;

@end

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

@end
