//
//  TerminalTotalsReconciliationFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "FXForms.h"
#import "TerminalTotals.h"
#import "TerminalTotalsReconciliationForm.h"
#import "Transactions.h"

@interface TerminalTotalsReconciliationFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) TerminalTotals *editObject;
@property bool editMode;

@end
