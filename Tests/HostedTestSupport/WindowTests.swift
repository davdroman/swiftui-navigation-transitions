import Testing

/// Tests that show views in the host app's window. They share the window, so they run one at a time.
@MainActor
@Suite(.serialized)
enum WindowTests {}
