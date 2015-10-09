#import "VMBCollectionItemChange.h"


@implementation VMBCollectionItemChange

+ (instancetype)insertAtIndex:(NSUInteger)index {
    VMBCollectionItemChange *change = [[self alloc] init];
    change->_changeType = VMBCollectionItemChangeTypeInsert;
    change->_initialIndex = NSNotFound;
    change->_finalIndex = index;

    return change;
}

+ (instancetype)removeAtIndex:(NSUInteger)index {
    VMBCollectionItemChange *change = [[self alloc] init];
    change->_changeType = VMBCollectionItemChangeTypeRemove;
    change->_initialIndex = index;
    change->_finalIndex = NSNotFound;

    return change;
}

+ (instancetype)refreshWithInitialIndex:(NSUInteger)initialIndex finalIndex:(NSUInteger)finalIndex {
    VMBCollectionItemChange *change = [[self alloc] init];
    change->_changeType = VMBCollectionItemChangeTypeRefresh;
    change->_initialIndex = initialIndex;
    change->_finalIndex = finalIndex;

    return change;
}

@end
