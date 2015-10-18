#import <Foundation/Foundation.h>

#import "VMBCollectionItemChange.h"


NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^VMBCollectionItemComparator)(id left, id right);


// Algebraic data type, to be converted to proper enum when Swift
@interface VMBCollectionSectionChange : NSObject

/// Returns either reload, insert, remove, incremental or `nil` change. `nil` means "nothing changed".
/// `identityComparator` will be used to detect insertions and removals, should not be nil.
/// `equalityComparator` will be used to find items that needs refresh, if `nil`, object equality (`-isEqual:`) will be used instead
+ (nullable instancetype)sectionChangeFromInitialArray:(NSArray *)initial
                                            finalArray:(NSArray *)final
                                    identityComparator:(VMBCollectionItemComparator)identityComparator
                                    equalityComparator:(nullable VMBCollectionItemComparator)equalityComparator;

+ (nullable instancetype)sectionChangeFromInitialArray:(NSArray *)initial
                                            finalArray:(NSArray *)final
                                    identityComparator:(VMBCollectionItemComparator)identityComparator;

+ (instancetype)reloadChange;
+ (instancetype)insertChange;
+ (instancetype)removeChange;

/// changes is NSArray<YACollectionItemChange>
+ (instancetype)incrementalChange:(NSArray<VMBCollectionItemChange *> *)changes;

- (void)ifReloadChange:(dispatch_block_t)reloadHandler
                insert:(dispatch_block_t)insertHandler
                remove:(dispatch_block_t)removeHandler
           incremental:(void (^)(NSArray<VMBCollectionItemChange *> *changes))incrementalHandler;

@end

NS_ASSUME_NONNULL_END
