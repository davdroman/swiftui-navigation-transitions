import UIKit

extension UIView {
    public static var unimplemented: UIView {
        UnimplementedUIView()
    }
}

final class UnimplementedUIView: UIView {
    // TODO: unimplement some stuff...
}
