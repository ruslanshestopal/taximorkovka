#import "TariffViewController.h"

@interface TariffViewController ()
@property(nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation TariffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle]
                      pathForResource: @"tarif"
                               ofType: @"html"];
    NSData *fileData = [NSData dataWithContentsOfFile: path];
    [self.webView loadData: fileData
                  MIMEType: @"text/html"
          textEncodingName: @"UTF-8"
                   baseURL: [NSURL fileURLWithPath: path]];
}
@end
