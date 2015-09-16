//
//  coreDataHelper.m
//  testCoreData1
//
//  Created by Smiley.V on 15/9/9.
//  Copyright (c) 2015年 2crazyones. All rights reserved.
//

#import "coreDataHelper.h"
#define debug 1

#define OBSERVE_PROGRESS @"migrationProgress"
@implementation coreDataHelper
#pragma FILE
NSString* storeFileName = @"Grocery-Dude.sqlite" ;
#pragma MIGRATION
-(BOOL)isMigrationNecessaryForStore:(NSURL*)StoreUrl
{
    if (![[NSFileManager defaultManager]fileExistsAtPath:[self storeUrl].path])
    {
        DEBUG_OUT(@"SKIPPED MIGRATION: missing source file") ;
        return NO ;
    }
    NSError* error = nil ;
    NSDictionary* sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:StoreUrl error:&error] ;
    NSManagedObjectModel* destinationModel = _coordinator.managedObjectModel ;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata])
    {
        DEBUG_OUT(@"SKIPPED MIGRATION:source file equal to destination file") ;
        return NO ;
    }
    return YES ;
}
-(BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new
{
    BOOL success = NO ;
    NSError* error = nil ;
    if ([[NSFileManager defaultManager]removeItemAtURL:old error:&error])
    {
        error = nil ;
        if ([[NSFileManager defaultManager]moveItemAtURL:new toURL:old error:&error])
        {
            success = YES ;
        }
        else
        {
            DEBUG_OUT(@"failed to move file :%@",error) ;
        }
    }
    return success ;
}
-(BOOL)migrateSotre:(NSURL*)sourceStore
{
    BOOL success = NO ;
    NSError* error = nil ;
    //step 1:source destination and mapping model
    NSDictionary* sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore error:&error] ;
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata] ;
    NSManagedObjectModel* destinModel = _model ;
    NSMappingModel* mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel] ;
    //step2 perform migration mapping model must not null
    if (mappingModel)
    {
        NSError* error = nil ;
        NSMigrationManager* migrationManager = [[NSMigrationManager alloc]initWithSourceModel:sourceModel destinationModel:destinModel] ;
        [migrationManager addObserver:self forKeyPath:OBSERVE_PROGRESS options:NSKeyValueObservingOptionNew context:NULL] ;
        NSURL* destinStore = [[self applicationStoresDirectory]URLByAppendingPathComponent:@"Temp.sqlite"] ;
        success = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error] ;
        //step3 replace old database with new database
        if ([self replaceStore:sourceStore withStore:destinStore])
        {
            [migrationManager removeObserver:self forKeyPath:OBSERVE_PROGRESS] ;
        }
       else
       {
           DEBUG_OUT(@"failed migration") ;
       }
    }
    return success ;
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:OBSERVE_PROGRESS])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey]floatValue] ;
            _progressPercentage = progress*100 ;
            if (nil != self.delegate)
            {
                [self.delegate observeProgress:self.progressPercentage] ;
            }
        }) ;
    }
}

-(void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrateSotre:storeURL] ;
        if (done)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* error = nil ;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeUrl] options:nil error:&error] ;
                if (!_store)
                {
                    DEBUG_OUT(@"failed to add store:%@",error) ;
                }
                else
                {
                    DEBUG_OUT(@"success to migrate store") ;
                }
                if (nil != self.delegate)
                {
                    [self.delegate migrationFinished:error] ;
                }
            }) ;
        }
    }) ;
}
#pragma PATH
-(NSString*)applicationDocumentsDirectory
{
    DEBUG_RUNNING ;
    return [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject] ;
}
-(NSURL*)applicationStoresDirectory
{
    NSURL* storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"] ;
    NSFileManager* fileManager = [NSFileManager defaultManager] ;
    if (![fileManager fileExistsAtPath:[storesDirectory path]])
    {
        NSError* error = nil ;
        if([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error])
        {
            DEBUG_OUT(@"Successfully created Stores directory") ;
        }
        else
        {
            DEBUG_OUT(@"Failed to create stores directory :%@",error) ;
        }
    }
    return storesDirectory ;
}

-(NSURL*)storeUrl
{
    DEBUG_RUNNING ;
    return [[self applicationStoresDirectory]URLByAppendingPathComponent:storeFileName] ;
}

-(id)init
{
    DEBUG_RUNNING ;
    self = [super init] ;
    if (nil == self)
    {
        return self ;
    }
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:_model] ;
    _content = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType] ;
    [_content setPersistentStoreCoordinator:_coordinator] ;
    return self ;
    
}
-(void)loadStore
{
    if (_store)
    {
        return ;
    }
    BOOL useMigrationManager = YES ;
    if (useMigrationManager&&[self isMigrationNecessaryForStore:[self storeUrl]])
    {
        [self performBackgroundManagedMigrationForStore:[self storeUrl]] ;
    }
    else
    {
        NSDictionary* option = @{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@NO,NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}} ;
        NSError* error = nil ;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeUrl] options:option error:&error] ;
        if (!_store)
        {
            DEBUG_OUT(@"failed to load store:%@",error) ;
        }
        else
        {
            DEBUG_OUT(@"success to load store") ;
        }
    }
}
//-(void)loadStore
//{
//    DEBUG_RUNNING ;
//    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@NO,NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
//    NSError* error = nil ;
//    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeUrl] options:options error:&error] ;
//    if (error)
//    {
//        DEBUG_OUT(@"Failed add store error:%@",error) ;
//    }
//    else
//    {
//        DEBUG_OUT(@"successfully add store") ;
//    }
//}
-(void)setupCoreData
{
    DEBUG_RUNNING ;
    [self loadStore] ;
}
-(void)saveContext
{
    DEBUG_RUNNING ;
    if ([_content hasChanges])
    {
        NSError* error = nil ;
        if ([_content save:&error])
        {
            DEBUG_OUT(@"_context SAVED changes to persistent store") ;
        }
        else
        {
            DEBUG_OUT(@"Failed save changes to persistent store error:%@",error) ;
        }
    }
    else
    {
        DEBUG_OUT(@"context has no changes") ;
    }
}
@end
