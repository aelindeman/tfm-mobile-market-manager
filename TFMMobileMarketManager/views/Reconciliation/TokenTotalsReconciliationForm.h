//
//  TokenTotalsReconciliationForm.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface TokenTotalsReconciliationForm : NSObject <FXForm>

@property NSUInteger marketBonusTokenCount;
@property NSUInteger marketCreditTokenCount;
@property NSUInteger marketSnapTokenCount;
@property NSUInteger redeemedBonusTokenCount;
@property NSUInteger redeemedCreditTokenCount;
@property NSUInteger redeemedSnapTokenCount;
@property NSInteger creditTokenDifference;
@property NSInteger snapTokenDifference;
@property NSInteger bonusTokenDifference;

@end
