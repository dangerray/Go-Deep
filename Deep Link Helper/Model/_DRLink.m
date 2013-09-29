// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DRLink.m instead.

#import "_DRLink.h"

const struct DRLinkAttributes DRLinkAttributes = {
	.timeStamp = @"timeStamp",
	.title = @"title",
	.url = @"url",
};

const struct DRLinkRelationships DRLinkRelationships = {
};

const struct DRLinkFetchedProperties DRLinkFetchedProperties = {
};

@implementation DRLinkID
@end

@implementation _DRLink

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DRLink" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DRLink";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DRLink" inManagedObjectContext:moc_];
}

- (DRLinkID*)objectID {
	return (DRLinkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic timeStamp;






@dynamic title;






@dynamic url;











@end
