//
//  ReportViewerViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

@interface ReportViewerViewController : UIViewController

@property NSString *filePath;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;

@end
