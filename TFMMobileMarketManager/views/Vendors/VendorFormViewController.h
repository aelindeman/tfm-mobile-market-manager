//
//  VendorFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Vendors.h"
#import "VendorForm.h"
#import "FXForms.h"

@interface VendorFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Vendors *editObject;
@property bool editMode;

@end