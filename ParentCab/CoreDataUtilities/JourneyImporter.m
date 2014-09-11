//
//  JourneyImporter.m
//  ParentCab
//
//  Created by Zac Tolley on 09/09/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "JourneyImporter.h"
#import "model.h"

@implementation JourneyImporter

- (void)deepCopyJourneysFromContext:(NSManagedObjectContext*)sourceContext
			   toContext:(NSManagedObjectContext*)targetContext
{
	int x = 0;
	
	// Fetch all the journeys in the source context and loop through (can we do this in batches?)
	NSArray *journeys = [self currentJourneys:sourceContext];
	
	for (Journey *journey in journeys) {
		
		// Create a new object in the new context
		Journey *targetJourney = [NSEntityDescription insertNewObjectForEntityForName:@"Journey" inManagedObjectContext:targetContext];
		targetJourney.startTime = journey.startTime;
		targetJourney.endTime = journey.endTime;
		targetJourney.distance = journey.distance;
		targetJourney.fare = journey.fare;
		
		StartLocation *targetStartLocation = [NSEntityDescription insertNewObjectForEntityForName:@"StartLocation" inManagedObjectContext:targetContext];
		[self copyLocationFrom: journey.startLocation to:targetStartLocation];
		targetJourney.startLocation = targetStartLocation;
		
		EndLocation *targetEndLocation = [NSEntityDescription insertNewObjectForEntityForName:@"EndLocation" inManagedObjectContext:targetContext];
		[self copyLocationFrom:journey.endLocation to:targetEndLocation];
		targetJourney.endLocation = targetEndLocation;
		
		for (Step *step in journey.steps) {
			StepLocation *targetStepLocation = [NSEntityDescription insertNewObjectForEntityForName:@"StepLocation" inManagedObjectContext:targetContext];
			[self copyLocationFrom:step.location to:targetStepLocation];
			
			Step *targetStep =[NSEntityDescription insertNewObjectForEntityForName:@"Step" inManagedObjectContext:targetContext];
			targetStep.location = targetStepLocation;
			targetStep.timestamp = step.timestamp;
			targetStep.journey = targetJourney;
			
			[targetJourney addStepsObject:targetStep];
		}
		
		x++;
	}
	
	
	NSLog(@"Imported %d Journeys", x);
	
}

- (void)copyLocationFrom:(Location *)source to:(Location *)dest {
	
	dest.latitude = source.latitude;
	dest.longitude = source.longitude;
	if (source.postcode) dest.postcode = [NSString stringWithString:source.postcode];
	if (source.thoroughfare) dest.thoroughfare = [NSString stringWithString:source.thoroughfare];
	
	
}
- (NSArray *)currentJourneys:(NSManagedObjectContext *)sourceContext {
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Journey"];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO]];

	NSError *error;
	
	NSArray *result = [sourceContext executeFetchRequest:request error:&error];
	
	if (result) {
		return result;
	} else {
		NSLog(@"%@", error.localizedDescription);
		return Nil;
	}
	

}

@end