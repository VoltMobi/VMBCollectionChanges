#if COCOAPODS == 1
#import <VMBArrayDiff/VMBArrayDiff.h>
#else
#import <ArrayDiff/ArrayDiff.h>
#endif

#import "VMBCollectionItemChange.h"
#import "VMBCollectionSectionChange.h"


@interface YACollectionSectionChangeReload : VMBCollectionSectionChange

@end

@implementation YACollectionSectionChangeReload

- (void)ifReloadChange:(dispatch_block_t)reloadHandler
                insert:(dispatch_block_t)insertHandler
                remove:(dispatch_block_t)removeHandler
           incremental:(void (^)(NSArray<VMBCollectionItemChange *> *))incrementalHandler {
    reloadHandler();
}

@end


@interface YACollectionSectionChangeInsert : VMBCollectionSectionChange

@end

@implementation YACollectionSectionChangeInsert

- (void)ifReloadChange:(dispatch_block_t)reloadHandler
                insert:(dispatch_block_t)insertHandler
                remove:(dispatch_block_t)removeHandler
           incremental:(void (^)(NSArray<VMBCollectionItemChange *> *))incrementalHandler {
    insertHandler();
}

@end


@interface YACollectionSectionChangeRemove : VMBCollectionSectionChange

@end

@implementation YACollectionSectionChangeRemove

- (void)ifReloadChange:(dispatch_block_t)reloadHandler
                insert:(dispatch_block_t)insertHandler
                remove:(dispatch_block_t)removeHandler
           incremental:(void (^)(NSArray<VMBCollectionItemChange *> *))incrementalHandler {
    removeHandler();
}

@end


@interface YACollectionSectionChangeIncremental : VMBCollectionSectionChange

@property (nonatomic, copy) NSArray *changes;

@end

@implementation YACollectionSectionChangeIncremental

- (void)ifReloadChange:(dispatch_block_t)reloadHandler
                insert:(dispatch_block_t)insertHandler
                remove:(dispatch_block_t)removeHandler
           incremental:(void (^)(NSArray<VMBCollectionItemChange *> *))incrementalHandler {
    incrementalHandler(self.changes);
}

@end


@implementation VMBCollectionSectionChange

#pragma mark - API

+ (instancetype)sectionChangeFromInitialArray:(NSArray *)initial
                                   finalArray:(NSArray *)final
                           identityComparator:(VMBCollectionItemComparator)identityComparator
                           equalityComparator:(VMBCollectionItemComparator)equalityComparator {
    NSCParameterAssert(identityComparator != nil);

    if (initial.count == 0 && final.count > 0) {
        return [self insertChange];
    } else if (initial.count > 0 && final.count == 0) {
        return [self removeChange];
    }

    NSSet *arrayChanges = VMBChangesByDiffingArrays(initial, final, identityComparator);

    NSMutableIndexSet *leftIntactIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, initial.count)];
    NSMutableIndexSet *rightIntactIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, final.count)];

    NSMutableArray *changes = [NSMutableArray array];

    if (arrayChanges.count > 0) {

        for (VMBArrayDiffChange *change in arrayChanges) {
            VMBCollectionItemChange *itemChange;

            switch (change.changeType) {
                case VMBArrayDiffChangeTypeInsert: {
                    itemChange = [VMBCollectionItemChange insertAtIndex:change.index];
                    [rightIntactIndexes removeIndex:change.index];
                    break;
                }
                case VMBArrayDiffChangeTypeDelete: {
                    itemChange = [VMBCollectionItemChange removeAtIndex:change.index];
                    [leftIntactIndexes removeIndex:change.index];
                    break;
                }
            }

            [changes addObject:itemChange];
        }

        NSCAssert(leftIntactIndexes.count == rightIntactIndexes.count, @"Number of untouched indexes should be the same for both arrays");
    }

    if (equalityComparator == nil) {
        equalityComparator = ^BOOL(id left, id right) {
            return [left isEqual:right];
        };
    }

    NSUInteger leftIndex = leftIntactIndexes.firstIndex;
    NSUInteger rightIndex = rightIntactIndexes.firstIndex;

    while (leftIndex != NSNotFound) {
        id leftItem = initial[leftIndex];
        id rightItem = final[rightIndex];

        if (!equalityComparator(leftItem, rightItem)) {
            // table or collection view is expecting *old* index path for reload calls, so use `leftIndex`
            [changes addObject:[VMBCollectionItemChange refreshWithInitialIndex:leftIndex finalIndex:rightIndex]];
        }

        leftIndex = [leftIntactIndexes indexGreaterThanIndex:leftIndex];
        rightIndex = [rightIntactIndexes indexGreaterThanIndex:rightIndex];
    }

    if (changes.count == 0) {
        return nil;
    } else {
        return [self incrementalChange:changes];
    }
}

+ (instancetype)sectionChangeFromInitialArray:(NSArray *)initial
                                   finalArray:(NSArray *)final
                           identityComparator:(VMBCollectionItemComparator)identityComparator {
    return [self sectionChangeFromInitialArray:initial
                                    finalArray:final
                            identityComparator:identityComparator
                            equalityComparator:nil];
}

+ (instancetype)reloadChange {
    return [[YACollectionSectionChangeReload alloc] init];
}

+ (instancetype)insertChange {
    return [[YACollectionSectionChangeInsert alloc] init];
}

+ (instancetype)removeChange {
    return [[YACollectionSectionChangeRemove alloc] init];
}

+ (instancetype)incrementalChange:(NSArray *)changes {
    YACollectionSectionChangeIncremental *instance = [[YACollectionSectionChangeIncremental alloc] init];
    instance.changes = changes;

    return instance;
}

- (void)ifReloadChange:(dispatch_block_t)reloadHandler
                insert:(dispatch_block_t)insertHandler
                remove:(dispatch_block_t)removeHandler
           incremental:(void (^)(NSArray<VMBCollectionItemChange *> *))incrementalHandler {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This class is not meant to be subclassed"
                                 userInfo:nil];
}

@end
