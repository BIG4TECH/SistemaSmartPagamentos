import 'package:intl/intl.dart';

String formatedDouble(dynamic valor){
  NumberFormat formatoDouble = NumberFormat("#,##0.00", "pt_BR");

  return formatoDouble.format(valor);
}

DateTime extractDateBeforeT(String input) {
 
  if (input.contains('T')) {

    String datePart = input.split('T').first;

    return DateTime.parse(datePart);
  } else {
    return DateTime.now();
    //throw FormatException("A string não contém a letra 'T'");
  }
}