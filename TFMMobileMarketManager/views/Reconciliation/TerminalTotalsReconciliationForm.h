//
//  TerminalTotalsReconciliationForm.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface TerminalTotalsReconciliationForm : NSObject <FXForm>

@property unsigned int terminalCreditAmount;
@property unsigned int terminalCreditTransactionCount;
@property unsigned int terminalSnapAmount;
@property unsigned int terminalSnapTransactionCount;
@property unsigned int terminalTotalAmount;
@property unsigned int terminalTotalTransactionCount;

@end
