import UIKit

/// The backgrounds the swatch page lays its cells over, shared with the
/// Flutter example and `tools/parity/fit.py`.
let swatchBackgrounds: [UInt32] = [
    0xFFFFFF, 0x000000, 0x808080, 0xD93025, 0x1E8E3E, 0x1A73E8,
    0x7FA7D9, 0xF29900, 0x8E44AD, 0xF4D03F, 0x16A085, 0x8D6E63,
]

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

/// One row per background, one column per content: the material alone, then
/// a vibrant square of white, black, red and half-transparent white.
/// `VIB_BLUR` and `VIB_STYLE` pick the material and style by their names in
/// `Styles.swift`.
final class SwatchesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let blur = blurStyles.first { $0.0 == (Parity.env["VIB_BLUR"] ?? "regular") }!.1
        let styleName = Parity.env["VIB_STYLE"] ?? "secondaryLabel"
        let style = vibrancyStyles.first { $0.0 == styleName }?.1
        let contents: [UIColor?] = [nil, .white, .black, UIColor(hex: 0xFF0000), UIColor(white: 1, alpha: 0.5)]
        let cell = CGSize(width: 70, height: 56)
        let origin = CGPoint(x: 26, y: 90)
        for (row, background) in swatchBackgrounds.enumerated() {
            let frame = CGRect(x: origin.x, y: origin.y + CGFloat(row) * cell.height,
                               width: cell.width * CGFloat(contents.count), height: cell.height)
            let backdrop = UIView(frame: frame)
            backdrop.backgroundColor = UIColor(hex: background)
            view.addSubview(backdrop)
            for (column, content) in contents.enumerated() {
                let square = UIView()
                square.backgroundColor = content ?? .clear
                let inner = UIView()
                inner.addSubview(square)
                square.frame = CGRect(x: 15, y: 8, width: 40, height: 40)
                let effect = makeVibrant(blur: blur, vibrancy: style, content: inner)
                effect.frame = CGRect(x: frame.minX + CGFloat(column) * cell.width, y: frame.minY,
                                      width: cell.width, height: cell.height)
                view.addSubview(effect)
            }
        }
    }
}

/// The sortd place card over a photo, then a patch and a name per style.
/// Shared frame for frame with the Flutter example's `CardPage`.
///
/// `VIB_HIDE=1` hides every piece of content, leaving the photo under the
/// material: `tools/parity/card.sh` feeds that capture to the Flutter page
/// as its backdrop.
final class CardViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let hide = Parity.env["VIB_HIDE"] == "1"
        let blur = blurStyles.first { $0.0 == (Parity.env["VIB_BLUR"] ?? "regular") }!.1
        let photo = UIImageView(image: UIImage(named: "sky"))
        photo.frame = view.bounds
        photo.contentMode = .scaleToFill
        view.addSubview(photo)
        let material = UIVisualEffectView(effect: UIBlurEffect(style: blur))
        material.frame = view.bounds
        view.addSubview(material)

        func add(_ style: UIVibrancyEffectStyle?, _ frame: CGRect, _ content: UIView) {
            content.isHidden = hide
            guard let style else {
                content.frame = frame
                material.contentView.addSubview(content)
                return
            }
            let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur), style: style))
            vibrancy.frame = frame
            content.frame = vibrancy.bounds
            vibrancy.contentView.addSubview(content)
            material.contentView.addSubview(vibrancy)
        }

        func label(_ text: String, _ font: UIFont, kern: CGFloat = 0) -> UILabel {
            let label = UILabel()
            label.attributedText = NSAttributedString(string: text, attributes: [.font: font, .kern: kern])
            label.numberOfLines = 0
            return label
        }

        func patch() -> UIView {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 10
            return view
        }

        add(.secondaryLabel, CGRect(x: 24, y: 110, width: 200, height: 20),
            label("PLACES", .systemFont(ofSize: 13, weight: .medium), kern: 2))
        add(nil, CGRect(x: 24, y: 134, width: 354, height: 42),
            label("Sky Garden", .systemFont(ofSize: 34, weight: .bold)))
        add(.tertiaryFill, CGRect(x: 24, y: 188, width: 110, height: 30), {
            let chip = UIView()
            chip.backgroundColor = .white
            chip.layer.cornerRadius = 15
            return chip
        }())
        add(nil, CGRect(x: 36, y: 193, width: 100, height: 20), label("Scenic spot", .systemFont(ofSize: 15, weight: .medium)))
        add(.secondaryLabel, CGRect(x: 24, y: 232, width: 354, height: 66),
            label("Known as the walkie talkie due to its unique shape, this skyscraper features a top-floor restaurant.",
                  .systemFont(ofSize: 17)))
        add(.tertiaryLabel, CGRect(x: 24, y: 310, width: 354, height: 20),
            label("Saved about a year ago", .systemFont(ofSize: 15)))
        add(.separator, CGRect(x: 24, y: 344, width: 354, height: 1), {
            let line = UIView()
            line.backgroundColor = .white
            return line
        }())
        for (index, (name, style)) in vibrancyStyles.enumerated() {
            let y = 364 + CGFloat(index) * 52
            add(style, CGRect(x: 24, y: y, width: 150, height: 40), patch())
            add(style, CGRect(x: 190, y: y + 8, width: 190, height: 24), label(name, .systemFont(ofSize: 20, weight: .semibold)))
        }
    }
}
