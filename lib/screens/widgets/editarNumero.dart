String formatarNumero(double numero) {
  if (numero.toString().contains('.')) {

    return numero.toString().replaceAll('.', '');
  } else {

    return '${numero}00';
  }
}

String formatWithComma(int number) {
  String numberStr = number.toString();
  
  if (numberStr.length < 2) {
    return numberStr;
  }
  
  return numberStr.substring(0, numberStr.length - 2) + ',' + numberStr.substring(numberStr.length - 2);
}