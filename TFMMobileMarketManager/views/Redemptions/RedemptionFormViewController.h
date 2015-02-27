//
//  RedemptionFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketDays.h"
#import "Vendors.h"
#import "Redemptions.h"
#import "RedemptionForm.h"
#import "FXForms.h"

@interface RedemptionFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Redemptions *editObject;
@property bool editMode;

@end
