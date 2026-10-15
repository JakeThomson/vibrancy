#import "LayerDump.h"

static NSString *DescribeValue(id value) {
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
        NSValue *v = value;
        const char *type = v.objCType;
        NSUInteger size = 0;
        NSGetSizeAndAlignment(type, &size, NULL);
        if (strstr(type, "f") && size % sizeof(float) == 0 && size <= 256) {
            float buf[64];
            [v getValue:buf size:size];
            NSMutableArray *parts = [NSMutableArray array];
            for (NSUInteger i = 0; i < size / sizeof(float); i++) {
                [parts addObject:[NSString stringWithFormat:@"%.5f", buf[i]]];
            }
            return [NSString stringWithFormat:@"%s[%@]", type, [parts componentsJoinedByString:@","]];
        }
        return [v description];
    }
    if (value && CFGetTypeID((__bridge CFTypeRef)value) == CGColorGetTypeID()) {
        CGColorRef color = (__bridge CGColorRef)value;
        const CGFloat *c = CGColorGetComponents(color);
        size_t n = CGColorGetNumberOfComponents(color);
        NSMutableArray *parts = [NSMutableArray array];
        for (size_t i = 0; i < n; i++) [parts addObject:[NSString stringWithFormat:@"%.5f", c[i]]];
        CGColorSpaceRef space = CGColorGetColorSpace(color);
        NSString *name = (__bridge_transfer NSString *)CGColorSpaceCopyName(space);
        return [NSString stringWithFormat:@"CGColor(%@)[%@]", name, [parts componentsJoinedByString:@","]];
    }
    return [value description];
}

static NSString *DescribeFilter(id filter) {
    if (![filter isKindOfClass:NSClassFromString(@"CAFilter")]) return DescribeValue(filter);
    NSMutableString *out = [NSMutableString string];
    NSString *name = nil;
    @try { name = [filter valueForKey:@"name"]; } @catch (NSException *e) {}
    NSString *type = nil;
    @try { type = [filter valueForKey:@"type"]; } @catch (NSException *e) {}
    [out appendFormat:@"%@(type=%@", name, type];
    NSArray *keys = nil;
    if ([filter respondsToSelector:NSSelectorFromString(@"inputKeys")]) {
        keys = [filter valueForKey:@"inputKeys"];
    }
    NSMutableSet *all = [NSMutableSet setWithArray:keys ?: @[]];
    [all addObjectsFromArray:@[
        @"inputColorMatrix", @"inputRadius", @"inputAmount", @"inputColor0", @"inputColor1",
        @"inputReversed", @"inputNormalizeEdges", @"inputQuality", @"inputIntermediateBitDepth",
        @"inputBias", @"inputHardEdges", @"inputScale", @"inputDither", @"inputValues",
        @"inputColor", @"inputSourceSublayerName", @"inputBackdropAware", @"enabled",
    ]];
    for (NSString *key in [[all allObjects] sortedArrayUsingSelector:@selector(compare:)]) {
        id value = nil;
        @try { value = [filter valueForKey:key]; } @catch (NSException *e) { continue; }
        if (!value) continue;
        [out appendFormat:@", %@=%@", key, DescribeValue(value)];
    }
    [out appendString:@")"];
    return out;
}

static void Describe(CALayer *layer, NSUInteger depth, NSMutableString *out) {
    NSString *indent = [@"" stringByPaddingToLength:depth * 2 withString:@" " startingAtIndex:0];
    id delegate = layer.delegate;
    [out appendFormat:@"%@%@ <%@> frame=%@ opacity=%.3f", indent, NSStringFromClass([layer class]),
        delegate ? NSStringFromClass([delegate class]) : @"-",
        NSStringFromCGRect(layer.frame), layer.opacity];
    if (layer.backgroundColor) [out appendFormat:@" bg=%@", DescribeValue((__bridge id)layer.backgroundColor)];
    if (layer.compositingFilter) [out appendFormat:@" compositingFilter=%@", DescribeFilter(layer.compositingFilter)];
    for (id filter in layer.filters) [out appendFormat:@"\n%@  · filter %@", indent, DescribeFilter(filter)];
    for (id filter in layer.backgroundFilters) [out appendFormat:@"\n%@  · backgroundFilter %@", indent, DescribeFilter(filter)];
    for (NSString *key in @[@"scale", @"groupName", @"captureOnly", @"allowsInPlaceFiltering", @"marginWidth", @"zoom"]) {
        if ([layer respondsToSelector:NSSelectorFromString(key)]) {
            @try { [out appendFormat:@" %@=%@", key, [layer valueForKey:key]]; } @catch (NSException *e) {}
        }
    }
    if (layer.mask) {
        [out appendFormat:@"\n%@  mask:\n", indent];
        Describe(layer.mask, depth + 2, out);
    }
    [out appendString:@"\n"];
    for (CALayer *sub in layer.sublayers) Describe(sub, depth + 1, out);
}

NSString *LayerDumpDescribe(CALayer *layer) {
    NSMutableString *out = [NSMutableString string];
    Describe(layer, 0, out);
    return out;
}
