import SwiftUI

struct PageView<Content: View, Link: View>: View {
	@EnvironmentObject var appState: AppState

	let number: Int
	let title: String
	let color: Color
	let content: Content
	let link: Link?

	var body: some View {
		ZStack {
			Rectangle()
				.fill(color.gradient)
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
					if let link {
						NavigationLink(value: number + 1) { link }
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
				Image(systemName: "gearshape").font(.system(size: 16, weight: .semibold))
			},
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
	) {
		self.init(
			number: number,
			title: title,
			color: color,
			content: content(),
			link: link(),
		)
	}
}

extension PageView where Link == EmptyView {
	static func final(
		number: Int,
		title: String,
		color: Color,
		@ViewBuilder content: () -> Content,
	) -> some View {
		Self(
			number: number,
			title: title,
			color: color,
			content: content(),
			link: nil,
		)
	}
}
