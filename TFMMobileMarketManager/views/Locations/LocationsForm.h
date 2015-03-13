//
//  LocationsForm.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FXForms.h"

@interface LocationsForm : NSObject <FXForm>

@property NSString *address;
@property NSString *name;

@end
