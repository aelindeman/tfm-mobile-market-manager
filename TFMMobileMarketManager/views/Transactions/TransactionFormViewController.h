//
//  TransactionFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Transaction.h"
#import "TransactionForm.h"
#import "FXForms.h"

@interface TransactionFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Transaction *editObject;
@property bool editMode;

@end
