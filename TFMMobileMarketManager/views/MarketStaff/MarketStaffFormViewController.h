//
//  MarketStaffFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketStaff.h"
#import "MarketStaffForm.h"
#import "FXForms.h"

@interface MarketStaffFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) MarketStaff *editObject;
@property bool editMode;

@end
