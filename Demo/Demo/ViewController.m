//
//  ViewController.m
//  Demo
//
//  Created by lufei on 2020/6/9.
//  Copyright © 2020 test. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    UIViewController *vc = [TableViewController new];
    vc.view.backgroundColor = [UIColor redColor];
    
    [self presentViewController:vc animated:false completion:nil];
    
}

@end
