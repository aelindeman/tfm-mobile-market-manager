//
//  ReportViewerViewController.m
//  TFMMobileMarketManager
//

#import "ReportViewerViewController.h"

@implementation ReportViewerViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
		
	// load file into text view
	if (self.filePath)
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
		{
			// title should be <marketday>/<filename>
			NSArray *pathDisplay = [[self.filePath pathComponents] subarrayWithRange:NSMakeRange([[self.filePath pathComponents] count] - 2, 2)];
			[self setTitle:[NSString pathWithComponents:pathDisplay]];
		
			NSError *error;
			[self.textView setText:[NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:&error]];
			if (error) [self.textView setText:[error localizedDescription]];
		}
		else
		{
			[self.textView setText:[NSString stringWithFormat:@"No file exists at path '%@'", self.filePath]];
		}
	}
}

@end
