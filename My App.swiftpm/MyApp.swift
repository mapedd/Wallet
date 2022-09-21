import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(initialState: .init(), reducer: Counter.reducer.debug(), environment: Counter.Environment()))
        }
    }
}
