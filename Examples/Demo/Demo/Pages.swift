import SwiftUI

struct PageOne: View {
	var body: some View {
		let content = Group {
			Text("**SwiftUINavigationTransitions** is a library that integrates seamlessly with SwiftUI's **Navigation** views, allowing complete customization over **push and pop transitions**!")
		}

		PageView(number: 1, title: "Welcome", color: .orange) {
			content
		} link: {
			PageLink(title: "Show me!")
		} destination: {
			PageTwo()
		}
		.modifier {
			if #available(iOS 16, tvOS 16, *) {
				$0.navigationDestination(for: Int.self) { number in
					switch number {
					case 1: PageOne()
					case 2: PageTwo()
					case 3: PageThree()
					case 4: PageFour()
					case 5: PageFive()
					default: EmptyView()
					}
				}
			} else {
				$0
			}
		}
	}
}

struct PageTwo: View {
	var body: some View {
		let content = Group {
			Text("The library is fully compatible with **NavigationView** in iOS 13+, and the new **NavigationStack** in iOS 16.")
			Text("In fact, that entire transition you just saw can be implemented in **one line** of SwiftUI code:")
			Code("""
				NavigationStack {
				  ...
				}
				.navigationTransition(.slide)
				"""
			)
		}

		PageView(number: 2, title: "Overview", color: .green) {
			content
		} link: {
			PageLink(title: "🤯")
		} destination: {
			PageThree()
		}
	}
}

struct PageThree: View {
	var body: some View {
		let content = Group {
			Text("The API is designed to resemble that of built-in SwiftUI Transitions for maximum **familiarity** and **ease of use**.")
			Text("You can apply **custom animations** just like with standard SwiftUI transitions:")
			Code("""
				.navigationTransition(
				    .fade(.in).animation(
				        .easeInOut(duration: 0.3)
				    )
				)
				"""
			)
			Text("... and you can even **combine** them too:")
			Code("""
				.navigationTransition(
				    .slide.combined(with: .fade(.in))
				)
				"""
			)
		}

		PageView(number: 3, title: "API Design", color: .red) {
			content
		} link: {
			PageLink(title: "Sweet!")
		} destination: {
			PageFour()
		}
	}
}

struct PageFour: View {
	var body: some View {
		let content = Group {
			Text("The library ships with some standard transitions out of the box, however you can create fully **custom transitions** in just a few lines of code.")
			Text("This demo features some presets to play with. You'll find them in the **settings** menu at the top.")
		}

		PageView(number: 4, title: "Customization", color: .blue) {
			content
		} link: {
			PageLink(title: "Awesome!")
		} destination: {
			PageFive()
		}
	}
}

struct PageFive: View {
	var body: some View {
		let content = Group {
			Text("The repository contains extensive [documentation](https://github.com/davdroman/swiftui-navigation-transitions/tree/main/Documentation) from how to get started to going fully custom, depending on your needs. 📖")
			Text("Feel free to **post questions**, **ideas**, or any **cool transitions** you build in the [Discussions](https://github.com/davdroman/swiftui-navigation-transitions/discussions) section! 💬")
			Text("I sincerely hope you enjoy using this library as much as I enjoyed building it.")
			Text("❤️")
		}

		PageView.final(number: 5, title: "Get Started", color: .purple) {
			content
		}
	}
}

struct PageLink: View {
	var title: String

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 6, style: .continuous)
			#if !os(tvOS) && !os(visionOS)
				.fill(Color.blue.opacity(0.8))
			#else
				.fill(Color.clear)
			#endif
			Text(title)
			#if !os(tvOS)
				.foregroundColor(.white)
			#endif
				.font(.system(size: 18, weight: .medium, design: .rounded))
		}
		.frame(maxHeight: 50)
	}
}

struct Code<Content: StringProtocol>: View {
	var content: Content

	init(_ content: Content) {
		self.content = content
	}

	var lineLimit: Int {
		content.split(separator: "\n").count
	}

	var body: some View {
		let shape = RoundedRectangle(cornerRadius: 4, style: .circular)

		Text(content)
			.frame(maxWidth: 500, alignment: .leading)
			.padding(10)
			.lineLimit(lineLimit)
			.multilineTextAlignment(.leading)
			.minimumScaleFactor(0.5)
			.font(.system(size: 14, design: .monospaced))
			.background(shape.stroke(Color(white: 0.1).opacity(0.35), lineWidth: 1))
			.background(Color(white: 0.94).opacity(0.6).clipShape(shape))
		#if !os(tvOS)
			.textSelection(.enabled)
		#endif
	}
}
