class Optional<T> {
  const Optional.absent() : value = null, isPresent = false;

  const Optional.of(this.value) : isPresent = true;

  final T? value;
  final bool isPresent;
}
