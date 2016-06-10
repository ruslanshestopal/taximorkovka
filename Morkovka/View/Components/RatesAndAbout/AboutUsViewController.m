#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@property(nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSString *path = [[NSBundle mainBundle]
                      pathForResource: @"about"
                               ofType: @"html"];
    NSData *fileData = [NSData dataWithContentsOfFile: path];
    [self.webView loadData:
         fileData MIMEType: @"text/html"
          textEncodingName: @"UTF-8"
                   baseURL: [NSURL fileURLWithPath: path]];
    
}
@end
