import UIKit

/// The blur materials and vibrancy styles the harness walks through, named as
/// the Flutter package names them.
let blurStyles: [(String, UIBlurEffect.Style)] = [
    ("ultraThin", .systemUltraThinMaterial),
    ("thin", .systemThinMaterial),
    ("regular", .systemMaterial),
    ("thick", .systemThickMaterial),
    ("chrome", .systemChromeMaterial),
    ("legacyLight", .light),
    ("legacyExtraLight", .extraLight),
    ("legacyDark", .dark),
    ("legacyRegular", .regular),
    ("legacyProminent", .prominent),
]

let vibrancyStyles: [(String, UIVibrancyEffectStyle)] = [
    ("label", .label),
    ("secondaryLabel", .secondaryLabel),
    ("tertiaryLabel", .tertiaryLabel),
    ("quaternaryLabel", .quaternaryLabel),
    ("fill", .fill),
    ("secondaryFill", .secondaryFill),
    ("tertiaryFill", .tertiaryFill),
    ("separator", .separator),
]

/// A blur view with a vibrancy view in its content, holding `content`.
@MainActor func makeVibrant(blur: UIBlurEffect.Style, vibrancy: UIVibrancyEffectStyle?, content: UIView) -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: blur)
    let blurView = UIVisualEffectView(effect: blurEffect)
    let effect: UIVibrancyEffect = vibrancy.map { UIVibrancyEffect(blurEffect: blurEffect, style: $0) }
        ?? UIVibrancyEffect(blurEffect: blurEffect)
    let vibrancyView = UIVisualEffectView(effect: effect)
    vibrancyView.translatesAutoresizingMaskIntoConstraints = false
    blurView.contentView.addSubview(vibrancyView)
    NSLayoutConstraint.activate([
        vibrancyView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
        vibrancyView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
        vibrancyView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
        vibrancyView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
    ])
    content.translatesAutoresizingMaskIntoConstraints = false
    vibrancyView.contentView.addSubview(content)
    NSLayoutConstraint.activate([
        content.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor),
        content.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor),
        content.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor),
        content.bottomAnchor.constraint(equalTo: vibrancyView.contentView.bottomAnchor),
    ])
    return blurView
}
