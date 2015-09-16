//
//  coreDataHelper.h
//  testCoreData1
//
//  Created by Smiley.V on 15/9/9.
//  Copyright (c) 2015年 2crazyones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "define.h"
@protocol dataHelperDelegate
-(void)observeProgress:(NSUInteger)progress ;
-(void)migrationFinished:(NSError*)error ;
@end
@interface coreDataHelper : NSObject
@property (nonatomic, readonly)NSManagedObjectContext* content ;
@property (nonatomic, readonly)NSManagedObjectModel* model ;
@property (nonatomic, readonly)NSPersistentStore* store ;
@property (nonatomic, readonly)NSPersistentStoreCoordinator* coordinator ;
@property (nonatomic, readonly)NSUInteger progressPercentage ;
@property (nonatomic, weak) id<dataHelperDelegate> delegate ;
-(void)setupCoreData ;
-(void)saveContext ;
@end
