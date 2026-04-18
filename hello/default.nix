{ }:
derivation {
  name = "hello";
  builder = "gcc";
  args = [
    ./hello.c
    "-o"
    (placeholder "out")
  ];
}
