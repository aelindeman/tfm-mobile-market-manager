//
//  RedemptionFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "MarketDay.h"
#import "Vendor.h"
#import "Redemptions.h"
#import "RedemptionForm.h"
#import "FXForms.h"

@interface RedemptionFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Redemptions *editObject;
@property bool editMode;

@end
