//
//  MarketStaffForm.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FXForms.h"

@interface MarketStaffForm : NSObject <FXForm>

@property NSString *name;
@property NSString *phone;
@property NSString *email;
@property Position position;

@end
