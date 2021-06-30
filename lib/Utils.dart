import 'package:intent/intent.dart';
import 'package:intent/action.dart';
import 'package:intent/extra.dart';

class Utils {
  static callNumber(String number) {
    Intent intent = Intent();
    intent.setAction(Action.ACTION_DIAL);
    intent.setData(Uri.parse('tel:' + number.replaceAll(' ', '')));
    intent.startActivity();
  }
}
