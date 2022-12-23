import '../../model/board.dart';
import '../../model/parameter.dart';
import '../../model/note.dart';

List<Parameter> orderedParamList(Board board) {
  List<Parameter> paramListToOrder = board.params.values.toList();
  paramListToOrder.sort(((a, b) => a.createdTime.compareTo(b.createdTime)));
  return paramListToOrder;
}

List<Note> orderNotesByTime(Parameter parameter) {
  List<Note> notes = parameter.notes.values.toList();

  if (parameter.durationType == DurationType.moment) {
    notes.sort((a, b) => b.moment!.compareTo(a.moment!));
  }

  if (parameter.durationType == DurationType.duration) {
    notes.sort((a, b) => b.duration!.end.compareTo(a.duration!.end));
  }

  return notes;
}
