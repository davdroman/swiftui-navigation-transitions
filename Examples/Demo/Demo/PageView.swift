import SwiftUI

struct PageView<Content: View, Link: View, Destination: View>: View {
	@EnvironmentObject var appState: AppState

	let number: Int
	let title: String
	let color: Color
	let content: Content
	let link: Link?
	let destination: Destination?

	var body: some View {
		ZStack {
			Rectangle()
				.modifier {
					if #available(iOS 16, tvOS 16, *) {
						$0.fill(color.gradient)
					} else {
						$0.fill(color)
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.edgesIgnoringSafeArea(.all)
				.opacity(0.45)
				.blendMode(.multiply)
			VStack {
				VStack(spacing: 20) {
					content
				}
				.font(.system(size: 20, design: .rounded))
				.lineSpacing(4)
				.shadow(color: .white.opacity(0.25), radius: 1, x: 0, y: 1)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.foregroundColor(Color(white: 0.14))
				.frame(maxWidth: 1200)

				Group {
					if let link, let destination {
						if #available(iOS 16, tvOS 16, *) {
							NavigationLink(value: number + 1) { link }
						} else {
							NavigationLink(destination: destination) { link }
						}
					}
				}
				#if os(tvOS)
				.frame(maxWidth: 600)
				#else
				.frame(maxWidth: 300)
				#endif
			}
			.multilineTextAlignment(.center)
			.padding(.horizontal)
			.padding(.bottom, 30)
		}
		#if !os(tvOS)
		.navigationBarTitle(Text(title), displayMode: .inline)
		#endif
		.navigationBarItems(
			trailing: Button(action: { appState.isPresentingSettings = true }) {
				Group {
					if #available(iOS 14, tvOS 16, *) {
						Image(systemName: "gearshape")
					} else {
						Image(systemName: "gear")
					}
				}
				.font(.system(size: 16, weight: .semibold))
			}
		)
	}
}

extension PageView {
	init(
		number: Int,
		title: String,
		color: Color,
		@ViewBuilder content: () -> Content,
		@ViewBuilder link: () -> Link,
		@ViewBuilder destination: () -> Destination = { EmptyView() }
	) {
		self.init(
			number: number,
			title: title,
			color: color,
			content: content(),
			link: link(),
			destination: destination()
		)
	}
}

extension PageView where Link == EmptyView, Destination == EmptyView {
	static func final(
		number: Int,
		title: String,
		color: Color,
		@ViewBuilder content: () -> Content
	) -> some View {
		Self(
			number: number,
			title: title,
			color: color,
			content: content(),
			link: nil,
			destination: nil
		)
	}
}

extension View {
	/// Modify a view with a `ViewBuilder` closure.
	///
	/// This represents a streamlining of the
	/// [`modifier`](https://developer.apple.com/documentation/swiftui/view/modifier(_:)) +
	/// [`ViewModifier`](https://developer.apple.com/documentation/swiftui/viewmodifier) pattern.
	///
	/// - Note: Useful only when you don't need to reuse the closure.
	/// If you do, turn the closure into a proper modifier.
	public func modifier<ModifiedContent: View>(
		@ViewBuilder _ modifier: (Self) -> ModifiedContent
	) -> ModifiedContent {
		modifier(self)
	}
}
