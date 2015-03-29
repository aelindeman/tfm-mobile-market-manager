//
//  RedemptionFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketDays.h"
#import "MarketOpenMenuViewController.h"
#import "Redemptions.h"
#import "RedemptionForm.h"
#import "Vendors.h"
#import "FXForms.h"

@interface RedemptionFormViewController : FXFormViewController <MarketOpenDelegate>

@property (nonatomic) id <MarketOpenDelegate> delegate;

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Redemptions *editObject;
@property bool editMode;

@end
