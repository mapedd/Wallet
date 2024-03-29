import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

public enum PresentationAction<Action> {
  case dismiss
  case presented(Action)
}
extension PresentationAction: Equatable where Action: Equatable {}

extension Reducer {
  func ifLet<ChildState: Identifiable, ChildAction>(
    _ stateKeyPath: WritableKeyPath<State, ChildState?>,
    action actionCasePath: CasePath<Action, PresentationAction<ChildAction>>
  ) -> some ReducerOf<Self>
  where ChildState: _EphemeralState
  {
    self.ifLet(stateKeyPath, action: actionCasePath) {
      EmptyReducer()
    }
  }

  func ifLet<ChildState: Identifiable, ChildAction>(
    _ stateKeyPath: WritableKeyPath<State, ChildState?>,
    action actionCasePath: CasePath<Action, PresentationAction<ChildAction>>,
    @ReducerBuilder<ChildState, ChildAction> child: () -> some Reducer<ChildState, ChildAction>
  ) -> some ReducerOf<Self> {
    let child = child()
    return Reduce { state, action in
      switch (state[keyPath: stateKeyPath], actionCasePath.extract(from: action)) {

      case (_, .none):
        let childStateBefore = state[keyPath: stateKeyPath]
        let effects = self.reduce(into: &state, action: action)
        let childStateAfter = state[keyPath: stateKeyPath]
        let cancelEffect: Effect<Action>
        if
          !(ChildState.self is _EphemeralState.Type),
          let childStateBefore,
          childStateBefore.id != childStateAfter?.id
        {
          cancelEffect = .cancel(id: childStateBefore.id)
        } else {
          cancelEffect = .none
        }
        let onFirstAppearEffect: Effect<Action>
        if
          !(ChildState.self is _EphemeralState.Type),
          let childStateAfter,
          childStateAfter.id != childStateBefore?.id
        {
          onFirstAppearEffect = .run { send in
            do {
              try await withTaskCancellation(id:  DismissID(id: childStateAfter.id)) {
                try await Task.never()
              }
            } catch is CancellationError {
              await send(actionCasePath.embed(.dismiss))
            }
          }
          .cancellable(id: childStateAfter.id)
        } else {
          onFirstAppearEffect = .none
        }
        return .merge(
          effects,
          cancelEffect,
          onFirstAppearEffect
        )

      case (.none, .some(.presented)), (.none, .some(.dismiss)):
        XCTFail("A presentation action was sent while child state was nil.")
        return self.reduce(into: &state, action: action)

      case (.some(var childState), .some(.presented(let childAction))):
        defer {
          if ChildState.self is _EphemeralState.Type {
            state[keyPath: stateKeyPath] = nil
          }
        }
        let childEffects = child
          .dependency(\.dismiss, DismissEffect { [id = childState.id] in
            Task.cancel(id:  DismissID(id: id))
          })
          .reduce(into: &childState, action: childAction)
        state[keyPath: stateKeyPath] = childState
        let effects = self.reduce(into: &state, action: action)
        return .merge(
          childEffects
            .map { actionCasePath.embed(.presented($0)) }
            .cancellable(id: childState.id),
          effects
        )

      case let (.some(childState), .some(.dismiss)):
        let effects = self.reduce(into: &state, action: action)
        state[keyPath: stateKeyPath] = nil
        return .merge(
          effects,
          .cancel(id: childState.id)
        )
      }
    }
  }
}

protocol _EphemeralState {}
extension AlertState: _EphemeralState {}
extension ConfirmationDialogState: _EphemeralState {}

private struct DismissID: Hashable { let id: AnyHashable }

struct DismissEffect: Sendable {
  private var dismiss: @Sendable () async -> Void
  func callAsFunction() async {
    await self.dismiss()
  }
}
extension DismissEffect {
  init(_ dismiss: @escaping @Sendable () async -> Void) {
    self.dismiss = dismiss
  }
}
extension DismissEffect: DependencyKey {
  static var liveValue = DismissEffect(dismiss: {})
  static var testValue = DismissEffect(dismiss: {})
}
extension DependencyValues {
  var dismiss: DismissEffect {
    get { self[DismissEffect.self] }
    set { self[DismissEffect.self] = newValue }
  }
}
// self.dismiss.dismiss()
// self.dismiss()

public extension View {
  func sheet<ChildState: Identifiable, ChildAction>(
    store: Store<ChildState?, PresentationAction<ChildAction>>,
    @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
  ) -> some View {
    WithViewStore(store, observe: { $0?.id }) { viewStore in
      self.sheet(
        item: Binding(
          get: { viewStore.state.map { Identified($0, id: \.self) } },
          set: { newState in
            if viewStore.state != nil {
              viewStore.send(.dismiss)
            }
          }
        )
      ) { _ in
        IfLetStore(
          store.scope(
            state: returningLastNonNilValue { $0 },
            action: PresentationAction.presented
          )
        ) { store in
          child(store)
        }
      }
    }
  }

  func popover<ChildState: Identifiable, ChildAction>(
    store: Store<ChildState?, PresentationAction<ChildAction>>,
    @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
  ) -> some View {
    WithViewStore(store, observe: { $0?.id }) { viewStore in
      self.popover(
        item: Binding(
          get: { viewStore.state.map { Identified($0, id: \.self) } },
          set: { newState in
            if viewStore.state != nil {
              viewStore.send(.dismiss)
            }
          }
        )
      ) { _ in
        IfLetStore(
          store.scope(
            state: returningLastNonNilValue { $0 },
            action: PresentationAction.presented
          )
        ) { store in
          child(store)
        }
      }
    }
  }

  @available(macOS, unavailable)
  func fullScreenCover<ChildState: Identifiable, ChildAction>(
    store: Store<ChildState?, PresentationAction<ChildAction>>,
    @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
  ) -> some View {
    WithViewStore(store, observe: { $0?.id }) { viewStore in
      self.fullScreenCover(
        item: Binding(
          get: { viewStore.state.map { Identified($0, id: \.self) } },
          set: { newState in
            if viewStore.state != nil {
              viewStore.send(.dismiss)
            }
          }
        )
      ) { _ in
        IfLetStore(
          store.scope(
            state: returningLastNonNilValue { $0 },
            action: PresentationAction.presented
          )
        ) { store in
          child(store)
        }
      }
    }
  }
}

func returningLastNonNilValue<A, B>(
  _ f: @escaping (A) -> B?
) -> (A) -> B? {
  var lastValue: B?
  return { a in
    lastValue = f(a) ?? lastValue
    return lastValue
  }
}

extension View {
  func alert<Action>(
    store: Store<AlertState<Action>?, PresentationAction<Action>>
  ) -> some View {
    WithViewStore(
      store,
      observe: { $0 },
      removeDuplicates: { ($0 != nil) == ($1 != nil) }
    ) { viewStore in
      self.alert(
        unwrapping: Binding(
          get: { viewStore.state },
          set: { newState in
            if viewStore.state != nil {
              viewStore.send(.dismiss)
            }
          }
        )
      ) { action in
        if let action {
          viewStore.send(.presented(action))
        }
      }
    }
  }
}

extension View {
  func confirmationDialog<Action>(
    store: Store<ConfirmationDialogState<Action>?, PresentationAction<Action>>
  ) -> some View {
    WithViewStore(
      store,
      observe: { $0 },
      removeDuplicates: { ($0 != nil) == ($1 != nil) }
    ) { viewStore in
      self.confirmationDialog(
        unwrapping: Binding(
          get: { viewStore.state },
          set: { newState in
            if viewStore.state != nil {
              viewStore.send(.dismiss)
            }
          }
        )
      ) { action in
        if let action {
          viewStore.send(.presented(action))
        }
      }
    }
  }
}

@available(*, deprecated)
public struct NavigationLinkStore<ChildState: Identifiable, ChildAction, Destination: View, Label: View>: View {
  public  init(store: Store<ChildState?, PresentationAction<ChildAction>>, id: ChildState.ID? = nil, action: @escaping () -> Void, destination: @escaping (Store<ChildState, ChildAction>) -> Destination, label: Label) {
    self.store = store
    self.id = id
    self.action = action
    self.destination = destination
    self.label = label
  }
  
  let store: Store<ChildState?, PresentationAction<ChildAction>>
  let id: ChildState.ID?
  let action: () -> Void
  @ViewBuilder let destination: (Store<ChildState, ChildAction>) -> Destination
  @ViewBuilder let label: Label

  public var body: some View {
//    NavigationLink(
//      tag: <#T##V#>,
//      selection: <#T##SwiftUI.Binding<V?>#>,
//      destination: <#T##() -> Destination#>,
//      label: <#T##() -> Label#>
//    )

    WithViewStore(self.store, observe: { $0?.id == self.id }) { viewStore in
      NavigationLink(
        isActive: Binding(
          get: { viewStore.state },
          set: { isActive in
            if isActive {
              self.action()
            } else if viewStore.state {
              viewStore.send(.dismiss)
            }
          }
        ),
        destination: {
          IfLetStore(
            self.store.scope(state: returningLastNonNilValue { $0 }, action: { .presented($0) })
          ) { store in
            self.destination(store)
          }
        },
        label: { self.label }
      )
    }
  }
}

struct Test: View, PreviewProvider {
  static var previews: some View {
    Self()
  }

  @State var background = Color.white
  @State var message = ""
  @State var isPresented = false

  var body: some View {
    ZStack {
      self.background.edgesIgnoringSafeArea(.all)
      Button {
        self.isPresented = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.message = "\(Int.random(in: 0...1_000_000))"
          self.background = .red
        }
      } label: {
        Text("Press")
      }
      .alert("Hello: \(self.message)", isPresented: self.$isPresented) {
        Text("Ok")
      }
    }
  }
}
