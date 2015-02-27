//
//  VendorFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Vendor.h"
#import "VendorForm.h"
#import "FXForms.h"

@interface VendorFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Vendor *editObject;
@property bool editMode;

@end