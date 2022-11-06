import Animation
@_spi(package) import Animator
import UIKit

public typealias _Animator = Animator

/// Represents a transition which applies to two views: an origin ("from") view and a destination ("to") view.
///
/// It is designed to handle both push and pop operations for a pair of views in a given navigation stack transition,
/// and is usually composed of smaller isolated transitions of type `AtomicTransition`, which act as building blocks.
///
/// Although the library ships with a set of predefined transitions (e.g. ``move(axis:)``, one can also create
/// entirely new, fully customizable transitions via ``custom(withTransientViews:)`` or ``custom(withAnimator:)``.
public struct NavigationTransition {
    public typealias Animator = _Animator

    public enum Operation: Hashable {
        case push
        case pop

        @_spi(package)public init?(_ operation: UINavigationController.Operation) {
            switch operation {
            case .push:
                self = .push
            case .pop:
                self = .pop
            case .none:
                return nil
            @unknown default:
                return nil
            }
        }
    }

    @_spi(package)public class _Context {
        public let uiKitContext: UIViewControllerContextTransitioning
        public var transientViews: (NavigationTransition.FromView, NavigationTransition.ToView)?

        public init(uiKitContext: UIViewControllerContextTransitioning) {
            self.uiKitContext = uiKitContext
        }
    }

    typealias _Handler = (Animator, Operation, _Context) -> Void

    private var handler: _Handler
    @_spi(package)public var animation: Animation = .default
    @_spi(package)public var isDefault = false

    init(handler: @escaping _Handler) {
        self.handler = handler
    }

    @_spi(package)public func prepare(_ animator: Animator, for operation: Operation, in context: _Context) {
        self.handler(animator, operation, context)
    }
}

extension NavigationTransition {
    /// Typealias for `AnimatorTransientView`.
    public typealias FromView = AnimatorTransientView
    /// Typealias for `AnimatorTransientView`.
    public typealias ToView = AnimatorTransientView

    typealias _TransientViewsHandler = (Animator, FromView, ToView, Operation, Context) -> Void

    init(withTransientViews transientViewsHandler: @escaping _TransientViewsHandler) {
        self.init { animator, operation, context in
            let uiKitContext = context.uiKitContext

            // short circuit repeated view set-ups when combining transitions
            if let (fromView, toView) = context.transientViews {
                transientViewsHandler(animator, fromView, toView, operation, uiKitContext)
                return
            }

            guard
                let fromUIView = uiKitContext.view(forKey: .from),
                let fromUIViewSnapshot = fromUIView.snapshotView(afterScreenUpdates: false),
                let toUIView = uiKitContext.view(forKey: .to),
                let toUIViewSnapshot = toUIView.snapshotView(afterScreenUpdates: true)
            else {
                return
            }

            let fromView = FromView(fromUIViewSnapshot)
            let toView = ToView(toUIViewSnapshot)
            context.transientViews = (fromView, toView)

            let container = uiKitContext.containerView
            fromUIView.removeFromSuperview()
            container.addSubview(fromUIViewSnapshot)
            switch operation {
            case .push:
                container.insertSubview(toUIViewSnapshot, aboveSubview: fromUIViewSnapshot)
            case .pop:
                container.insertSubview(toUIViewSnapshot, belowSubview: fromUIViewSnapshot)
            }

            // this is a hack that uses a 0-sized container to ensure that
            // toView is added to the view hierarchy but not visible,
            // in order to have toViewSnapshot sized properly
            let invisibleContainer = UIView()
            invisibleContainer.clipsToBounds = true
            invisibleContainer.addSubview(fromUIView)
            invisibleContainer.addSubview(toUIView)
            container.addSubview(invisibleContainer)

            animator.addCompletion { [weak container, weak fromUIView, weak toUIView] _ in
                guard
                    let container = container,
                    let fromUIView = fromUIView,
                    let toUIView = toUIView
                else {
                    return
                }
                for subview in container.subviews {
                    subview.removeFromSuperview()
                }
                if uiKitContext.transitionWasCancelled {
                    container.addSubview(fromUIView)
                } else {
                    container.addSubview(toUIView)
                }
            }

            transientViewsHandler(animator, fromView, toView, operation, uiKitContext)
        }
    }
}

public typealias _Animation = Animation

extension NavigationTransition {
    public typealias Animation = _Animation

    /// Attaches an animation to this transition.
    public func animation(_ animation: Animation) -> Self {
        var copy = self
        copy.animation = animation
        return copy
    }
}
