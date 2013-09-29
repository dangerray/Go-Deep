// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DRLink.h instead.

#import <CoreData/CoreData.h>


extern const struct DRLinkAttributes {
	__unsafe_unretained NSString *timeStamp;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *url;
} DRLinkAttributes;

extern const struct DRLinkRelationships {
} DRLinkRelationships;

extern const struct DRLinkFetchedProperties {
} DRLinkFetchedProperties;






@interface DRLinkID : NSManagedObjectID {}
@end

@interface _DRLink : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DRLinkID*)objectID;





@property (nonatomic, strong) NSDate* timeStamp;



//- (BOOL)validateTimeStamp:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;






@end

@interface _DRLink (CoreDataGeneratedAccessors)

@end

@interface _DRLink (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveTimeStamp;
- (void)setPrimitiveTimeStamp:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;




@end
