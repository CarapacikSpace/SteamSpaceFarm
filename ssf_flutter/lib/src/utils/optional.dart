class Optional<T> {
  const new absent() : value = null, isPresent = false;

  const new of(this.value) : isPresent = true;

  final T? value;
  final bool isPresent;
}
