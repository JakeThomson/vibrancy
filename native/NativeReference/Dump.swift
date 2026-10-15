import UIKit

/// Builds one blur-and-vibrancy pair per material and style, lets UIKit apply
/// its effects, and writes the layer trees with their private filters to
/// `Documents/dump-<light|dark>.txt` (and stdout).
final class DumpViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var report = "iOS \(UIDevice.current.systemVersion) dark=\(Parity.dark)\n"
        var probes: [(String, UIView)] = []
        for (blurName, blur) in blurStyles {
            let bare = makeBlurOnly(blur)
            probes.append(("blur \(blurName)", bare))
            for (vibName, vib) in vibrancyStyles {
                let label = UILabel()
                label.text = "Vibrant"
                probes.append(("\(blurName) / \(vibName)", makeVibrant(blur: blur, vibrancy: vib, content: label)))
            }
            let label = UILabel()
            label.text = "Vibrant"
            probes.append(("\(blurName) / default", makeVibrant(blur: blur, vibrancy: nil, content: label)))
        }
        for (_, probe) in probes {
            probe.frame = CGRect(x: 20, y: 100, width: 200, height: 60)
            view.addSubview(probe)
        }
        view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            for (name, probe) in probes {
                report += "=== \(name)\n" + LayerDumpDescribe(probe.layer) + "\n"
            }
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("dump-\(Parity.dark ? "dark" : "light").txt")
            try? report.write(to: url, atomically: true, encoding: .utf8)
            print("DUMP_WRITTEN \(url.path)")
        }
    }

    private func makeBlurOnly(_ style: UIBlurEffect.Style) -> UIView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
}
