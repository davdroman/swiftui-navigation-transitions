@_spi(package) @testable import NavigationTransition
import UIKit
import XCTestDynamicOverlay

@_spi(package)public class UnimplementedContext: NavigationTransition._Context {
    public override var transientViews: (NavigationTransition.FromView, NavigationTransition.ToView)? {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return nil
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    public init() {
        super.init(uiKitContext: UnimplementedUIKitContext())
    }
}
