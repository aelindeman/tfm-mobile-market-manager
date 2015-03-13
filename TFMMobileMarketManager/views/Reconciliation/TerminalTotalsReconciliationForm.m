//
//  TerminalTotalsReconciliationForm.m
//  TFMMobileMarketManager
//

#import "TerminalTotalsReconciliationForm.h"

@implementation TerminalTotalsReconciliationForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"terminalCreditAmount", FXFormFieldTitle: @"Credit amount", FXFormFieldAction: @"updateTerminalTotals:"},
		@{FXFormFieldKey: @"terminalCreditTransactionCount", FXFormFieldTitle: @"Number of credit transactions", FXFormFieldAction: @"updateTerminalTotals:"},
		
		@{FXFormFieldKey: @"terminalSnapAmount", FXFormFieldTitle: @"SNAP amount", FXFormFieldAction: @"updateTerminalTotals:"},
		@{FXFormFieldKey: @"terminalSnapTransactionCount", FXFormFieldTitle: @"Number of SNAP transactions", FXFormFieldAction: @"updateTerminalTotals:"},
		
		@{FXFormFieldKey: @"terminalTotalAmount", FXFormFieldTitle: @"Total amount", FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldHeader: @"Totals"},
		@{FXFormFieldKey: @"terminalTotalTransactionCount", FXFormFieldTitle: @"Number of transactions", FXFormFieldType: FXFormFieldTypeLabel}
	];
}

@end
