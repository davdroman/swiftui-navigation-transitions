import SwiftUI

extension AtomicTransition {
    /// A transition entering from `edge` on insertion, and exiting towards `edge` on removal.
    public static func move(edge: Edge) -> Self {
        .custom { view, operation, container in
            switch (edge, operation) {
            case (.top, .insertion):
                view.initial.translation.dy = -container.frame.height
                view.animation.translation.dy = 0

            case (.leading, .insertion):
                view.initial.translation.dx = -container.frame.width
                view.animation.translation.dx = 0

            case (.trailing, .insertion):
                view.initial.translation.dx = container.frame.width
                view.animation.translation.dx = 0

            case (.bottom, .insertion):
                view.initial.translation.dy = container.frame.height
                view.animation.translation.dy = 0

            case (.top, .removal):
                view.animation.translation.dy = -container.frame.height
                view.completion.translation.dy = 0

            case (.leading, .removal):
                view.animation.translation.dx = -container.frame.width
                view.completion.translation.dx = 0

            case (.trailing, .removal):
                view.animation.translation.dx = container.frame.width
                view.completion.translation.dx = 0

            case (.bottom, .removal):
                view.animation.translation.dy = container.frame.height
                view.completion.translation.dy = 0
            }
        }
    }
}
