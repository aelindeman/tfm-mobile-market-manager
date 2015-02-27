//
//  TransactionForm.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FXForms.h"

@interface TransactionForm : NSObject <FXForm>

// Demographics
@property NSString *cust_zipcode;
@property NSUInteger cust_id;

@property Frequency cust_frequency;
@property NSString *cust_referral;
@property BOOL cust_gender;
@property BOOL cust_senior;
@property Ethnicity cust_ethnicity;

// Credit card
@property BOOL credit_used;
@property NSUInteger credit_amount; // input only
@property NSUInteger credit_fee;
@property NSUInteger credit_total; // automatically calculated

// SNAP
@property BOOL snap_used;
@property NSUInteger snap_amount; // form only
@property NSUInteger snap_bonus;
@property NSUInteger snap_total; // automatically calculated

// Transactional
@property BOOL markedInvalid;

@end
