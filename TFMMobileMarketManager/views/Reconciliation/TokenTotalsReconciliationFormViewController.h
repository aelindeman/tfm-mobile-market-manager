//
//  TokenTotalsReconciliationFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "FXForms.h"
#import "TokenTotals.h"
#import "TokenTotalsReconciliationForm.h"

@interface TokenTotalsReconciliationFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) TokenTotals *editObject;
@property bool editMode;

@end
