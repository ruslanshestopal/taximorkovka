#import "TopTableViewController.h"

@implementation TopTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"menuIcon"]
                                   style:UIBarButtonItemStylePlain
                                   target:self action:@selector(anchorRight)];
    UIBarButtonItem *phoneButton  = [[UIBarButtonItem alloc]
                                     initWithImage:[UIImage imageNamed:@"phoneIcon"]
                                     style:UIBarButtonItemStylePlain
                                     target:self action:@selector(anchorLeft)];
    
    self.navigationItem.leftBarButtonItem  = menuButton;
    self.navigationItem.rightBarButtonItem = phoneButton;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.navigationController.view.layer.shadowOpacity = 0.75f;
    self.navigationController.view.layer.shadowRadius = 10.0f;
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

//
- (IBAction)anchorRight {
    if (self.slidingViewController.currentTopViewPosition == 2) {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }else{
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

- (IBAction)anchorLeft {
    if (self.slidingViewController.currentTopViewPosition == 2) {
        [self.slidingViewController anchorTopViewToLeftAnimated:YES];
    }else{
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    
}
@end
