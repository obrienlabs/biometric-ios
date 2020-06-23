//
//  BMPersistence.h
//  Biometric
//
//  Created by Michael O'Brien on 2014-05-24.
//  Copyright (c) 2014 Michael O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMPersistence : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
