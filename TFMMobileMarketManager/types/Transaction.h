//
//  Transactions.h
//  tfmco-mip
//

#import <Foundation/Foundation.h>

#import "MarketDay.h"
#import "typedefs.h"

@interface Transaction : NSObject

@property unsigned long identifier;

@property NSTimeInterval time;
@property NSString *cust_zipcode;
@property unsigned int cust_id;

@property Frequency cust_frequency;
@property NSString *cust_referral;
@property BOOL cust_gender;
@property BOOL cust_senior;
@property Ethnicity cust_ethnicity;

@property BOOL credit_used;
@property double credit_fee;
@property double credit_total;

@property BOOL snap_used;
@property double snap_bonus;
@property double snap_total;

@property BOOL markedInvalid;

@property MarketDay *marketday;

@end
