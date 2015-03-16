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

@property unsigned int deviceCreditAmount;
@property unsigned int deviceCreditTransactionCount;
@property unsigned int deviceSnapAmount;
@property unsigned int deviceSnapTransactionCount;
@property unsigned int deviceTotalAmount;
@property unsigned int deviceTotalTransactionCount;

@end
