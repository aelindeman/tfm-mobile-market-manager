//
//  TransactionFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketOpenMenuViewController.h"
#import "Transactions.h"
#import "TransactionForm.h"
#import "FXForms.h"

@interface TransactionFormViewController : FXFormViewController <MarketOpenDelegate>

@property (nonatomic) id <MarketOpenDelegate> delegate;

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Transactions *editObject;
@property bool editMode;

@end
