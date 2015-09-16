//
//  AppDelegate.m
//  testCoreData1
//
//  Created by Smiley.V on 15/9/9.
//  Copyright (c) 2015年 2crazyones. All rights reserved.
//

#import "AppDelegate.h"
#import "coreDataHelper.h"
#import "define.h"
#import "Item.h"
#import "Measurement.h"
#import "Amount.h"
#import "mainViewController.h"
#define debug 1
@interface AppDelegate ()
@property(nonatomic, strong,readonly) coreDataHelper* dataHelper ;
@end

@implementation AppDelegate

-(coreDataHelper*)cdh
{
    DEBUG_RUNNING ;
    if (nil == _dataHelper)
    {
        _dataHelper = [coreDataHelper new] ;
        [_dataHelper setupCoreData] ;
    }
    return _dataHelper ;
}
-(void)demo
{
    DEBUG_RUNNING ;
//    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Item"] ;
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ;
//    //NSPredicate* filter = [NSPredicate predicateWithFormat:@"name != %@",@"apple"] ;
//    //[request setPredicate:filter] ;
//    NSFetchRequest* modelRequest = [[[_dataHelper model]fetchRequestTemplateForName:@"Test"]copy];
//    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]] ;
//    NSArray* resultArray = [_dataHelper.content executeFetchRequest:modelRequest error:nil] ;
//    for (Item* item in resultArray)
//    {
//        NSLog(@"fetch object name:%@",item.name) ;
//    }
    NSArray* newItemNames = [NSArray arrayWithObjects:@"apple",@"milk",@"bread",@"cheese",@"butter", nil];
    for (NSString* newItemName in newItemNames)
    {
        Item* newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_dataHelper.content] ;
        newItem.name = newItemName ;
        DEBUG_OUT(@"Insert new object item for :%@",newItem.name) ;
    }
    
}

-(void)demo_chapter3_1
{
    DEBUG_RUNNING ;
    for (int i = 1; i < 50000; ++i)
    {
        Measurement* newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:_dataHelper.content] ;
        newMeasurement.abc = [NSString stringWithFormat:@"LOTS OF TEST DATA x%i",i] ;
    }
    [_dataHelper saveContext] ;
}
-(void)demo_chapter3_2
{
    DEBUG_RUNNING ;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Amount"] ;
    [request setFetchLimit:50] ;
    NSError* error = nil ;
    NSArray* fetchObjects = [_dataHelper.content executeFetchRequest:request error:&error] ;
    if (nil == error)
    {
        for (Amount* amount in fetchObjects)
        {
            NSLog(@"fetched object:%@",amount.xyz) ;
        }
    }
    else
    {
        DEBUG_OUT(@"failed fetch object error:%@",error) ;
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    mainViewController* mainView = [[mainViewController alloc]init] ;
    UINavigationController* navigationController = [[UINavigationController alloc]init] ;
    [navigationController setViewControllers:[NSArray arrayWithObject:mainView]] ;
    [self.window setFrame:[UIScreen mainScreen].bounds] ;
    self.window.rootViewController = mainView ;
    //self.window set
    //[navigationController setViewControllers:nil]
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[[self cdh]saveContext] ;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //[self cdh] ;
    //[self demo_chapter3_2] ;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //[[self cdh]saveContext] ;
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
