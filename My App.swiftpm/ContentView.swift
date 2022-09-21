import SwiftUI
import ComposableArchitecture

enum Counter {
    struct State: Equatable {
        var count = 0
    }
    enum Action {
        case increment
        case decrement
    }
    struct Environment {
        
    }
    
    static let reducer = Reducer
    <
        Counter.State,
        Counter.Action,
        Counter.Environment
    > { state, action, _ in
        switch action {
            case .increment:
            state.count += 1
            return .none 
            case .decrement:
            state.count -= 1
            return .none 
        }
    }.debug()
}

struct ContentView: View {
    let store: Store<Counter.State, Counter.Action>
    var body: some View {
        WithViewStore(self.store) { viewStore in 
            HStack {
                Button("Plus", action: { viewStore.send(.decrement)})
                Text("\(viewStore.count)")
                Button("Minus", action: { viewStore.send(.increment)})
            }
        }
    
    }
}
