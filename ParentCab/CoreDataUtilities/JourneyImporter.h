//
//  JourneyImporter.h
//  ParentCab
//
//  Created by Zac Tolley on 09/09/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface JourneyImporter : NSObject

- (void)deepCopyJourneysFromContext:(NSManagedObjectContext*)sourceContext
			   toContext:(NSManagedObjectContext*)targetContext;

@end
