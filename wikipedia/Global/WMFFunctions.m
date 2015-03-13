
#import "WMFFunctions.h"
#import <sys/xattr.h>
#import <mach/mach_time.h>
#import "WMFMacroUtilities.h"

BOOL rangesAreContiguous(NSRange first, NSRange second){
    NSIndexSet* firstIndexes  = [NSIndexSet indexSetWithIndexesInRange:first];
    NSIndexSet* secondIndexes = [NSIndexSet indexSetWithIndexesInRange:second];

    NSUInteger endOfFirstRange       = [firstIndexes lastIndex];
    NSUInteger beginingOfSecondRange = [secondIndexes firstIndex];

    if (beginingOfSecondRange - endOfFirstRange == 1) {
        return YES;
    }

    return NO;
}

NSRange rangeWithFirstAndLastIndexes(NSUInteger first, NSUInteger last){
    if (last < first) {
        return NSMakeRange(0, 0);
    }

    if (first == NSNotFound || last == NSNotFound) {
        return NSMakeRange(0, 0);
    }

    NSUInteger length = last - first + 1;

    NSRange r = NSMakeRange(first, length);
    return r;
}

float nanosecondsWithSeconds(float seconds){
    return (seconds * 1000000000);
}

CGFloat measureTimeBlock(void (^ block)(void)) {
    mach_timebase_info_data_t info;

    if (mach_timebase_info(&info) != KERN_SUCCESS) {
        return -1.0;
    }

    uint64_t start = mach_absolute_time();
    block();
    uint64_t end     = mach_absolute_time();
    uint64_t elapsed = end - start;

    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
}

dispatch_time_t dispatchTimeFromNow(float seconds){
    return dispatch_time(DISPATCH_TIME_NOW, nanosecondsWithSeconds(seconds));
}

BOOL addSkipBackupAttributeToItemAtURL(NSURL* URL){
#ifdef DEBUG

    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);

#endif

    if (IS_OS_5_1_OR_LATER) {
        NSError* error = nil;
        BOOL success   = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                        forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (!success) {
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    } else if (IS_OS_5_0_1_OR_LATER) {
        const char* filePath = [[URL path] fileSystemRepresentation];

        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue   = 1;

        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }

    return NO;
}

NSUInteger sizeOfFolderContentsInBytes(NSString* folderPath){
    NSError* error    = nil;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];

    if (error != nil) {
        return NSNotFound;
    }

    double bytes = 0.0;
    for (NSString* eachFile in contents) {
        NSDictionary* meta = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:eachFile] error:&error];

        if (error != nil) {
            break;
        }

        NSNumber* fileSize = [meta objectForKey:NSFileSize];
        bytes += [fileSize unsignedIntegerValue];
    }

    if (error != nil) {
        return NSNotFound;
    }

    return bytes;
}

double bytesWithMegaBytes(long long megaBytes){
    NSNumber* mb = [NSNumber numberWithLongLong:megaBytes];

    double mbAsDouble = [mb doubleValue];

    double b = mbAsDouble * 1048576.0;

    return b;
}

double megaBytesWithBytes(long long bytes){
    NSNumber* b = [NSNumber numberWithLongLong:bytes];

    double bytesAsDouble = [b doubleValue];

    double mb = bytesAsDouble / 1048576.0;

    return mb;
}

double gigaBytesWithBytes(long long bytes){
    NSNumber* b = [NSNumber numberWithLongLong:bytes];

    double bytesAsDouble = [b doubleValue];

    double gb = bytesAsDouble / 1073741824.0;

    return gb;
}

NSString* prettySizeStringWithBytesRounded(long long bytes){
    NSString* size = nil;

    if (bytes <= 524288000) { // smaller than 500 MB
        double mb = megaBytesWithBytes(bytes);
        mb   = round(mb);
        size = [NSString stringWithFormat:@"%.f MB", mb];
    } else {
        double gb = gigaBytesWithBytes(bytes);
        gb   = round(gb / 0.1) * 0.1;
        size = [NSString stringWithFormat:@"%.1f GB", gb];
    }
    return size;
}

NSString* prettySizeStringWithBytesFloored(long long bytes){
    NSString* size = nil;

    if (bytes <= 524288000) { // smaller than 500 MB
        double mb = megaBytesWithBytes(bytes);
        mb   = floor(mb);
        size = [NSString stringWithFormat:@"%.f MB", mb];
    } else {
        double gb = gigaBytesWithBytes(bytes);
        gb   = floor(gb / 0.1) * 0.1;
        size = [NSString stringWithFormat:@"%.1f GB", gb];
    }
    return size;
}

void dispatchOnMainQueue(dispatch_block_t block){
    dispatch_async(dispatch_get_main_queue(), block);
}

void dispatchOnBackgroundQueue(dispatch_block_t block){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

void dispatchOnMainQueueAfterDelayInSeconds(float delay, dispatch_block_t block){
    dispatchAfterDelayInSeconds(delay, dispatch_get_main_queue(), block);
}

void dispatchAfterDelayInSeconds(float delay, dispatch_queue_t queue, dispatch_block_t block){
    dispatch_after(dispatchTimeFromNow(delay), queue, block);
}

Progress progressMake(unsigned long long complete, unsigned long long total){
    if (total == 0) {
        return kProgressZero;
    }

    Progress p;

    p.total    = total;
    p.complete = complete;

    NSNumber* t = [NSNumber numberWithLongLong:total];
    NSNumber* c = [NSNumber numberWithLongLong:complete];

    double r = [c doubleValue] / [t doubleValue];

    p.ratio = r;

    return p;
}

Progress const kProgressZero = {
    0,
    0,
    0.0
};
