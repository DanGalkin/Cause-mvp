import '../../model/board.dart';
import '../../model/parameter.dart';

List<Parameter> orderedParamList(Board board) {
  List<Parameter> paramListToOrder = board.params.values.toList();
  paramListToOrder.sort(((a, b) => a.createdTime.compareTo(b.createdTime)));
  return paramListToOrder;
}
