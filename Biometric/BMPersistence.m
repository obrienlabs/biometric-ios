//
//  BMPersistence.m
//  Biometric
//
//  Created by Michael O'Brien on 2014-05-24.
//  Touring Core Data : 2014: Apress
//

#import "BMPersistence.h"

@implementation BMPersistence


- (void)saveContext {
    NSError *error;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]); abort();
    } }
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (id)init {
    self = [super init]; if (self != nil) {
        // Initialize the managed object model
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"]; _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        // Initialize the persistent store coordinator
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                                 URL:storeURL options:nil
                                                               error:&error]) { NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort(); }
        // Initialize the managed object context
        _managedObjectContext = [[NSManagedObjectContext alloc] init]; [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator]; }
    return self; }
@end
