#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VMBCollectionItemChangeType) {
    VMBCollectionItemChangeTypeInsert,
    VMBCollectionItemChangeTypeRemove,
    VMBCollectionItemChangeTypeRefresh,
};


@interface VMBCollectionItemChange : NSObject

+ (instancetype)insertAtIndex:(NSUInteger)index;
+ (instancetype)removeAtIndex:(NSUInteger)index;

/// Refresh change contains both index of changed object in initial collection and in final one.
/// We need both indexes because there are two table (collection) view cell update strategies:
/// 1. Just use `-reloadRowsAtIndexPaths:withRowAnimation` (`-reloadItemsAtIndexPaths:`), initial indexes are required.
/// (see https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9 for details)
/// 2. Manually updating existing cells contents, when reload is not an option, final indexes are required.
+ (instancetype)refreshWithInitialIndex:(NSUInteger)initialIndex finalIndex:(NSUInteger)finalIndex;

@property (nonatomic, readonly) NSUInteger initialIndex;
@property (nonatomic, readonly) NSUInteger finalIndex;
@property (nonatomic, readonly) VMBCollectionItemChangeType changeType;

@end

NS_ASSUME_NONNULL_END
