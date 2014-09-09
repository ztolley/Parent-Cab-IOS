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
	
	// Fetch all the journeys in the source context and loop through (can we do this in batches?)
	NSArray *journeys = [self currentJourneys:sourceContext];
	int x = 1;
	
	for (Journey *journey in journeys) {
		
		// Create a new object in the new context
		Journey *targetJourney = [NSEntityDescription insertNewObjectForEntityForName:@"Journey" inManagedObjectContext:targetContext];
		targetJourney.startTime = journey.startTime;
		targetJourney.endTime = journey.endTime;
		targetJourney.distance = journey.distance;
		targetJourney.fare = journey.fare;
		
		StartLocation *targetStartLocation = [NSEntityDescription insertNewObjectForEntityForName:@"StartLocation" inManagedObjectContext:targetContext];
		targetStartLocation.latitude = journey.startLocation.latitude;
		targetStartLocation.longitude = journey.startLocation.longitude;
		if (journey.startLocation.postcode) targetStartLocation.postcode = [NSString stringWithString:journey.startLocation.postcode];
		if (journey.startLocation.thoroughfare) targetStartLocation.thoroughfare = [NSString stringWithString:journey.startLocation.thoroughfare];
		targetJourney.startLocation = targetStartLocation;
		
		EndLocation *targetEndLocation = [NSEntityDescription insertNewObjectForEntityForName:@"EndLocation" inManagedObjectContext:targetContext];
		targetEndLocation.latitude = journey.endLocation.latitude;
		targetEndLocation.longitude = journey.endLocation.longitude;
		if (journey.endLocation.postcode) targetEndLocation.postcode = [NSString stringWithString:journey.endLocation.postcode];
		if (journey.endLocation.thoroughfare) targetEndLocation.thoroughfare = [NSString stringWithString:journey.endLocation.thoroughfare];
		targetJourney.endLocation = targetEndLocation;
		
		for (Step *step in journey.steps) {
			StepLocation *targetStepLocation = [NSEntityDescription insertNewObjectForEntityForName:@"StepLocation" inManagedObjectContext:targetContext];
			targetStepLocation.latitude = step.location.latitude;
			targetStepLocation.longitude = step.location.longitude;
			if (step.location.postcode) targetStepLocation.postcode = [NSString stringWithString:step.location.postcode];
			if (step.location.thoroughfare) targetStepLocation.thoroughfare = [NSString stringWithString:step.location.thoroughfare];
			
			Step *targetStep =[NSEntityDescription insertNewObjectForEntityForName:@"Step" inManagedObjectContext:targetContext];
			targetStep.location = targetStepLocation;
			targetStep.timestamp = step.timestamp;
			targetStep.journey = targetJourney;
			
			[targetJourney addStepsObject:targetStep];
		}

		NSLog(@"-- %d --", x);
		x++;
		
	}
	
	
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
