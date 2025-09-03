enum State {
  running,
  failing,
  done,
}

class StateValue<T> {
  final T? value;
  final State state;
  final String? error;

  const StateValue.error(String this.error)
      : state = State.failing,
        value = null;

  const StateValue.done(T this.value)
      : state = State.done,
        error = null;

  const StateValue.running()
      : state = State.running,
        error = null,
        value = null;

  E match<E>(
    E Function(T) onDone,
    E Function(String) onError,
    E Function() onRunning,
  ) {
    switch (state) {
      case State.done:
        return onDone(value as T);
      case State.failing:
        return onError(error!);
      case State.running:
        return onRunning();
    }
  }
}
