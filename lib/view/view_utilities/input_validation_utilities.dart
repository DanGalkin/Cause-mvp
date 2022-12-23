bool isDecimalNumberInputValid(String input) {
  //TODO include the possibility to have negative numbers
  RegExp regexp = RegExp(r'^\d+\.?\d*$');
  print('$input match is: ${regexp.hasMatch(input)}');
  return regexp.hasMatch(input);
}
