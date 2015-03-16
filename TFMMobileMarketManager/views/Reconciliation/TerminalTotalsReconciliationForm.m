//
//  TerminalTotalsReconciliationForm.m
//  TFMMobileMarketManager
//

#import "TerminalTotalsReconciliationForm.h"

@implementation TerminalTotalsReconciliationForm

- (NSArray *)fields
{
	return @[
		@{FXFormFieldKey: @"terminalCreditAmount", FXFormFieldTitle: @"Credit amount", FXFormFieldAction: @"updateTerminalTotals:", FXFormFieldHeader: @"Terminal totals"},
		@{FXFormFieldKey: @"terminalCreditTransactionCount", FXFormFieldTitle: @"Number of credit transactions", FXFormFieldAction: @"updateTerminalTotals:"},
		@{FXFormFieldKey: @"terminalSnapAmount", FXFormFieldTitle: @"SNAP amount", FXFormFieldAction: @"updateTerminalTotals:"},
		@{FXFormFieldKey: @"terminalSnapTransactionCount", FXFormFieldTitle: @"Number of SNAP transactions", FXFormFieldAction: @"updateTerminalTotals:"},
		@{FXFormFieldKey: @"terminalTotalAmount", FXFormFieldTitle: @"Total amount", FXFormFieldType: FXFormFieldTypeLabel},
		@{FXFormFieldKey: @"terminalTotalTransactionCount", FXFormFieldTitle: @"Number of transactions", FXFormFieldType: FXFormFieldTypeLabel},
		
		@{FXFormFieldKey: @"deviceCreditAmount", FXFormFieldTitle: @"Credit amount", FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldHeader: @"Device totals"},
		@{FXFormFieldKey: @"deviceCreditTransactionCount", FXFormFieldTitle: @"Number of credit transactions", FXFormFieldType: FXFormFieldTypeLabel},
		@{FXFormFieldKey: @"deviceSnapAmount", FXFormFieldTitle: @"SNAP amount", FXFormFieldType: FXFormFieldTypeLabel},
		@{FXFormFieldKey: @"deviceSnapTransactionCount", FXFormFieldTitle: @"Number of SNAP transactions", FXFormFieldType: FXFormFieldTypeLabel},
		@{FXFormFieldKey: @"deviceTotalAmount", FXFormFieldTitle: @"Total amount", FXFormFieldType: FXFormFieldTypeLabel},
		@{FXFormFieldKey: @"deviceTotalTransactionCount", FXFormFieldTitle: @"Number of transactions", FXFormFieldType: FXFormFieldTypeLabel}
	];
}

@end
