//
//  TransactionFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Transactions.h"
#import "TransactionForm.h"
#import "FXForms.h"

@interface TransactionFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Transactions *editObject;
@property bool editMode;

@end
