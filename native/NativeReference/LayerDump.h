#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Describes a layer tree with the private Core Animation filters UIKit hangs
/// off it — `filters`, `compositingFilter` and a backdrop layer's own — and
/// every input those filters carry, colour matrices included.
NSString *LayerDumpDescribe(CALayer *layer);

NS_ASSUME_NONNULL_END
