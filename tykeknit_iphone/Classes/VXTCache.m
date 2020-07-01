//
//  VXTCache.m
//  jukeBox
//
//  Created by Abhinit Tiwari on 09/06/09.
//  Copyright 2009 Vercingetorix Technologies Pvt Ltd. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "VXTCache.h"
#import "Global.h"

#define SMALL_IMAGE_SIZE (70*70)
#define MEDIUM_IMAGE_SIZE (150*190)
#define LARGE_IMAGE_SIZE (600*400)

#define CACHE_MIN_AGE (60*60) // 1 hour

#define CACHE_MAX_AGE (60*60*2) // 2 hours

static NSString* cacheDir = @"jBox";

static VXTCache* gSharedCache = nil;

@implementation VXTCache
@synthesize disableDiskCache = _disableDiskCache, disableImageCache = _disableImageCache,cachePath = _cachePath, maxPixelCount = _maxPixelCount, invalidationAge = _invalidationAge;

+ (VXTCache*)sharedCache {

	if (!gSharedCache) {
		gSharedCache = [[VXTCache alloc] init];
	}
	return gSharedCache;
}

+ (void)setSharedCache:(VXTCache*)cache {
	
	if (gSharedCache != cache) {
		[gSharedCache release];
		gSharedCache = [cache retain];
	}
}

+ (NSString*)defaultCachePath {
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);	
	NSString* cachesPath = [paths objectAtIndex:0];
	NSString* cachePath = [cachesPath stringByAppendingPathComponent:cacheDir];
	NSFileManager* fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:cachesPath]) {
		if([OS_VERSION floatValue] >= 4.0f) {
			[fm createDirectoryAtPath:cachesPath withIntermediateDirectories:YES attributes:nil error:nil];
		}else {
//			[fm createDirectoryAtPath:cachesPath attributes:nil];
		}
	}
	if (![fm fileExistsAtPath:cachePath]) {
		if([OS_VERSION floatValue] >= 4.0f) {
			[fm createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
		}else {
//			[fm createDirectoryAtPath:cachePath attributes:nil];
		}
	}
	return cachePath;
}

- (id)init {
	if (self == [super init]) {
		_cachePath = [[VXTCache defaultCachePath] retain];
		_imageCache = [[NSMutableDictionary alloc] init];
		_imageSortedList = [[NSMutableArray alloc] init];
		_totalLoading = 0;
		_disableDiskCache = NO;
		_disableImageCache = NO;
		_invalidationAge = CACHE_MIN_AGE;
		_maxPixelCount = -1;//(SMALL_IMAGE_SIZE*100) + (MEDIUM_IMAGE_SIZE*10);
		_totalPixelCount = 0;

		//Copied this from 320
		//This is supposed to disable the default NSURLCACHEPOLICY. In 4 words "SAVES MEMORY WITHOUT CRASHING"
		NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0
																	diskPath:nil];
		[NSURLCache setSharedURLCache:sharedCache];
		[sharedCache release];
	}
	return self;
}

- (void)dealloc {
	[_imageCache release];
	[_imageSortedList release];
	[_cachePath release];
	[super dealloc];
}

- (void)expireImagesFromMemory {
	while (_imageSortedList.count) {
		NSString* key = [_imageSortedList objectAtIndex:0];
		UIImage* image = [_imageCache objectForKey:key];

		_totalPixelCount -= image.size.width * image.size.height;
		[_imageCache removeObjectForKey:key];
		[_imageSortedList removeObjectAtIndex:0];
		if (_totalPixelCount <= _maxPixelCount) {
			break;
		}
	}
}

- (void)storeImage:(UIImage*)image forKey:(NSString*)key force:(BOOL)force{
	if (image && (force || !_disableImageCache)) {
		int pixelCount = image.size.width * image.size.height;
		if (force || pixelCount < LARGE_IMAGE_SIZE) {
			_totalPixelCount += pixelCount;
			if (_totalPixelCount > _maxPixelCount && _maxPixelCount) {
				[self expireImagesFromMemory];
			}
			[_imageSortedList addObject:key];
			[_imageCache setObject:image forKey:key];
		}
	}
}

- (NSData*)loadDataFromDisk:(NSString*)url {
	NSString* filePath = [self cachePathForURL:url];
	NSFileManager* fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filePath]) {
		return [[[NSData alloc] initWithContentsOfFile:filePath] autorelease];
	} else {
		return nil;
	}
}

- (NSString *)keyForURL:(NSString*)url {
	const char* str = [url UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);

	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

- (NSString*)cachePathForURL:(NSString*)url {
	NSString* key = [self keyForURL:url];
	return [self cachePathForKey:key];
}

- (NSString*)cachePathForKey:(NSString*)key {
	return [_cachePath stringByAppendingPathComponent:key];
}

- (BOOL)hasDataForURL:(NSString*)url {
	NSString* filePath = [self cachePathForURL:url];
	NSFileManager* fm = [NSFileManager defaultManager];
	return [fm fileExistsAtPath:filePath];
}

- (NSData*)dataForURL:(NSString*)url {
	return [self dataForURL:url expires:0 timestamp:nil];
}

- (NSData*)dataForURL:(NSString*)url expires:(NSTimeInterval)expirationAge
			timestamp:(NSDate**)timestamp {
	NSString* key = [self keyForURL:url];
	return [self dataForKey:key expires:expirationAge timestamp:timestamp];
}

- (NSData*)dataForKey:(NSString*)key expires:(NSTimeInterval)expirationAge
			timestamp:(NSDate**)timestamp {
	NSString* filePath = [self cachePathForKey:key];
	NSFileManager* fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filePath]) {
		NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
		NSDate* modified = [attrs objectForKey:NSFileModificationDate];
		if (expirationAge && [modified timeIntervalSinceNow] < -expirationAge) {
			return nil;
		}
		if (timestamp) {
			*timestamp = modified;
		}
		return [NSData dataWithContentsOfFile:filePath];
	}

	return nil;
}

- (id)imageForURL:(NSString*)url {
	NSString* key = [self keyForURL:url];
	return [self imageForKey:key];
}

- (id)imageForKey:(NSString*)key {
	UIImage* image = [_imageCache objectForKey:key];
	return image ? [[image retain] autorelease] : nil;
}

- (void)storeData:(NSData*)data forURL:(NSString*)url {
	NSString* key = [self keyForURL:url];
	[self storeData:data forKey:key];
}

- (void)storeData:(NSData*)data forKey:(NSString*)key {
	if (!_disableDiskCache) {
		NSString* filePath = [self cachePathForKey:key];
		NSFileManager* fm = [NSFileManager defaultManager];
		[fm createFileAtPath:filePath contents:data attributes:nil];
	}
}

- (void)storeImage:(UIImage*)image forURL:(NSString*)url {
	NSString* key = [self keyForURL:url];
	[self storeImage:image forKey:key];
}

- (void)storeImage:(UIImage*)image forKey:(NSString*)key {
	[self storeImage:image forKey:key force:NO];
}

- (void)removeURL:(NSString*)url fromDisk:(BOOL)fromDisk {
	NSString*  key = [self keyForURL:url];
	[_imageSortedList removeObject:key];
	[_imageCache removeObjectForKey:key];

	if (fromDisk) {
		NSString* filePath = [self cachePathForKey:key];
		NSFileManager* fm = [NSFileManager defaultManager];
		if (filePath && [fm fileExistsAtPath:filePath]) {
			[fm removeItemAtPath:filePath error:nil];
		}
	}
}

- (void)removeKey:(NSString*)key {
	NSString* filePath = [self cachePathForKey:key];
	NSFileManager* fm = [NSFileManager defaultManager];
	if (filePath && [fm fileExistsAtPath:filePath]) {
		[fm removeItemAtPath:filePath error:nil];
	}
}

- (void)removeAll:(BOOL)fromDisk {
	[_imageCache removeAllObjects];
	[_imageSortedList removeAllObjects];
	_totalPixelCount = 0;

	if (fromDisk) {
		NSFileManager* fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:_cachePath error:nil];
		
		if([OS_VERSION floatValue] >= 4.0f) {
			[fm createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
		}else {
//			[fm createDirectoryAtPath:_cachePath attributes:nil];
		}
	}
}

- (void)invalidateURL:(NSString*)url {
	NSString* key = [self keyForURL:url];
	return [self invalidateKey:key];
}

- (void)invalidateKey:(NSString*)key {
	NSString* filePath = [self cachePathForKey:key];
	NSFileManager* fm = [NSFileManager defaultManager];
	if (filePath && [fm fileExistsAtPath:filePath]) {
		NSDate* invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
		NSDictionary* attrs = [NSDictionary dictionaryWithObject:invalidDate
														  forKey:NSFileModificationDate];
		if([OS_VERSION floatValue] >= 4.0f) {
			[fm setAttributes:attrs ofItemAtPath:filePath error:nil];
		}else {
//			[fm changeFileAttributes:attrs atPath:filePath];
		}
	}
}

- (void)invalidateAll {
	NSDate* invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
	NSDictionary* attrs = [NSDictionary dictionaryWithObject:invalidDate
													  forKey:NSFileModificationDate];
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSDirectoryEnumerator* e = [fm enumeratorAtPath:_cachePath];
	for (NSString* fileName; fileName == [e nextObject]; ) {
		NSString* filePath = [_cachePath stringByAppendingPathComponent:fileName];
		
		if([OS_VERSION floatValue] >= 4.0f) {
			[fm setAttributes:attrs ofItemAtPath:filePath error:nil];
		}else {
//			[fm changeFileAttributes:attrs atPath:filePath];
		}
	}
}

- (void)logMemoryUsage {
//	NSEnumerator* e = [_imageCache keyEnumerator];
//	for (NSString* key ; key = [e nextObject]; ) {
//		UIImage* image = [_imageCache objectForKey:key];
//	}  
}

@end