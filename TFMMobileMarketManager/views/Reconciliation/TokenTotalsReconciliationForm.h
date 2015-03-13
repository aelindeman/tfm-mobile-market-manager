//
//  TokenTotalsReconciliationForm.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface TokenTotalsReconciliationForm : NSObject <FXForm>

@property unsigned int marketBonusTokenCount;
@property unsigned int marketCreditTokenCount;
@property unsigned int marketSnapTokenCount;
@property unsigned int redeemedBonusTokenCount;
@property unsigned int redeemedCreditTokenCount;
@property unsigned int redeemedSnapTokenCount;

@end
