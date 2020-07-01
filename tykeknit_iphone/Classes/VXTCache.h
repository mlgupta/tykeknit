//
//  VXTCache.h
//  jukeBox
//
//  Created by Abhinit Tiwari on 09/06/09.
//  Copyright 2009 Vercingetorix Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VXTCache : NSObject {
	NSString* _cachePath;
	NSMutableDictionary* _imageCache;
	NSMutableArray* _imageSortedList;
	NSUInteger _totalPixelCount;
	NSUInteger _maxPixelCount;
	NSInteger _totalLoading;
	NSTimeInterval _invalidationAge;
	BOOL _disableDiskCache;
	BOOL _disableImageCache;
}


// Disables the disk cache.
@property(nonatomic) BOOL disableDiskCache;

// Disables the in-memory cache for images.
@property(nonatomic) BOOL disableImageCache;

// Gets the path to the directory of the disk cache.
@property(nonatomic,copy) NSString* cachePath;

/* The maximum number of pixels to keep in memory for cached images.
   Setting this to zero will allow an unlimited number of images to be cached.   
*/
@property(nonatomic) NSUInteger maxPixelCount;

// amount of time to subtract from modified date fof the files so that they are removed from cache the next time around
@property(nonatomic) NSTimeInterval invalidationAge;

// This retursn a 'singleton' to any class that requires it
+ (VXTCache*)sharedCache;

// setter for the cache.
+ (void)setSharedCache:(VXTCache*)cache;

// gettter for the default cache path (jBox by default)
+ (NSString*)defaultCachePath;


// returns the key under which a URL response has been cached. key is an md5 string of the URL
- (NSString *)keyForURL:(NSString*)url;

//returns YES if there is a cache entry for a URL else NO.
- (BOOL)hasDataForURL:(NSString*)url;

//returns the path in the cache where a URLRespomse may be stored.
- (NSString*)cachePathForURL:(NSString*)url;

//returns the path in the cache where a key may be stored.
- (NSString*)cachePathForKey:(NSString*)key;

// returbs the data for a URL from the cache if it exists
// returns nil if the URL is not cached 
- (NSData*)dataForURL:(NSString*)url;

// returns the data for a URL from the cache if it exists and is newer than a minimum(the one whiuch is passed) timestamp
// returns nil if the URL is not cached or if the cacxhe entry is older than the minimum.
- (NSData*)dataForURL:(NSString*)url expires:(NSTimeInterval)expirationAge
			timestamp:(NSDate**)timestamp;
- (NSData*)dataForKey:(NSString*)key expires:(NSTimeInterval)expirationAge
			timestamp:(NSDate**)timestamp;

// returns an image from the in-memory image cache.
// returns nil if the URL is not cached.
- (id)imageForURL:(NSString*)url;
- (id)imageForKey:(NSString*)key;

// writes a data on disk.
- (void)storeData:(NSData*)data forURL:(NSString*)url;
- (void)storeData:(NSData*)data forKey:(NSString*)key;

//writes an image in the memory cache.
- (void)storeImage:(UIImage*)image forURL:(NSString*)url;
- (void)storeImage:(UIImage*)image forKey:(NSString*)key;

// removes the data for a URL from the memory cache and optionally from the disk cache.
- (void)removeURL:(NSString*)url fromDisk:(BOOL)fromDisk;

// remove mentioned key from disk
- (void)removeKey:(NSString*)key;

// remove everything from memory. if fromDisk==YES then from disk too. 
- (void)removeAll:(BOOL)fromDisk;

 
// changes the file in the disk cache so that its modified timestamp is the current
// time minus the max cache expiration age.

// this is to make sure that the next time the URL is requested from the cache it will be loaded
// from the network if the max cache expiration age is used.

- (void)invalidateURL:(NSString*)url;

- (void)invalidateKey:(NSString*)key;

- (void)invalidateAll;

- (void)logMemoryUsage;

@end
