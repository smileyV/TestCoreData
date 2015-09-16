//
//  mainViewController.m
//  testCoreData1
//
//  Created by Smiley.V on 15/9/16.
//  Copyright (c) 2015年 2crazyones. All rights reserved.
//

#import "mainViewController.h"
#import "migrationViewController.h"
@interface mainViewController ()

@end

@implementation mainViewController
-(void)buttonDown:(id)obj
{
    migrationViewController* viewController = [[migrationViewController alloc]init] ;
    [self.navigationController pushViewController:viewController animated:YES] ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor] ;
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 50, 50)] ;
    [button addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchUpInside] ;
    [self.view addSubview:button] ;
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(200, 50, 300, 50)] ;
    lable.text = @"mainView" ;
    [self.view addSubview:lable] ;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
