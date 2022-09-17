import 'package:excel_app/lesson_model.dart';
import 'package:excel_dart/excel_dart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      title: 'Звонок. Администрирование',
      theme: ThemeData(
        backgroundColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

void addValueToMap<K, V>(Map<K, List<V>> map, K key, V value) => {
      map.update(key, (list) => list..add(value), ifAbsent: () => [value])
    };

void addValueToMapWithMap<K, L, V>(
        Map<K, Map<L, List<V>>> map, K key, L key2, V value) =>
    {
      map.update(
          key,
          (list) => list
            ..update(
              key2,
              (list2) => list2..add(value),
              ifAbsent: () => [value],
            ),
          ifAbsent: () => {
                key2: [value]
              })
    };

class _MyHomePageState extends State<MyHomePage> {
  List<String> listClasses = [];
  Map<String, Map<String, List<LessonModel>>> listLesson = {};
  Map<String, List<String>> listDays = {};
  List<String> nameClass = [];
  List<String> listTimeLessons = [];
  final TextEditingController _schoolIdController = TextEditingController();
  bool dataLoading = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _schoolIdController,
              decoration: InputDecoration(hintText: "Введите ид школы"),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  FilePickerResult? pickedFile = await FilePicker.platform
                      .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['xlsx'],
                          allowMultiple: false,
                          withData: true);

                  /// file might be picked

                  if (pickedFile != null) {
                    var bytes = pickedFile.files.single.bytes;
                    var excel = Excel.decodeBytes(bytes!);

                    for (String table in excel.tables.keys) {
                      print("Table: $table");
                      Sheet sheetObject = excel[table];

                      print(excel.tables[table]!.getColWidths);
                      print(excel.tables[table]!.maxCols);
                      print(excel.tables[table]!.maxRows);
                      setState(() {
                        dataLoading = true;
                      });

                      for (List<Data?> row in excel.tables[table]!.rows) {
                        for (Data? i in row) {
                          if (i != null) {
                            if (i.cellIndex.rowIndex == 2 &&
                                i.cellIndex.columnIndex > 2) {
                              listClasses.add(i.value.toString());
                            }
                            int time = 2;
                            String firstLessonTime = sheetObject
                                .cell(CellIndex.indexByColumnRow(
                                    columnIndex: 2, rowIndex: 3))
                                .value;
                            if (!listTimeLessons.contains(firstLessonTime)) {
                              listTimeLessons.add(firstLessonTime);
                            }

                            do {
                              String times = sheetObject
                                  .cell(CellIndex.indexByColumnRow(
                                      columnIndex: 2, rowIndex: 3 + time))
                                  .value;
                              if (!listTimeLessons.contains(times)) {
                                listTimeLessons.add(times);
                              }
                              time = time + 2;
                            } while (sheetObject
                                    .cell(CellIndex.indexByColumnRow(
                                        columnIndex: 2, rowIndex: 3 + time))
                                    .value
                                    .toString() !=
                                firstLessonTime);
                            if (i.cellIndex.rowIndex > 2 &&
                                i.cellIndex.columnIndex > 2) {
                              //addValueToMap(listLesson, row[i.cellIndex.columnIndex]!.value, value)
                              //print(row[i.cellIndex.rowIndex]!.value);
                              print(
                                  "Col ${i.cellIndex.columnIndex - (i.cellIndex.columnIndex - 2)}");
                              print("Row ${i.cellIndex.rowIndex}");
                              if (sheetObject
                                      .cell(CellIndex.indexByColumnRow(
                                          columnIndex: i.cellIndex.columnIndex,
                                          rowIndex: i.cellIndex.rowIndex -
                                              (i.cellIndex.rowIndex - 2)))
                                      .value !=
                                  null) {
                                String classes = sheetObject
                                    .cell(CellIndex.indexByColumnRow(
                                        columnIndex: i.cellIndex.columnIndex,
                                        rowIndex: i.cellIndex.rowIndex -
                                            (i.cellIndex.rowIndex - 2)))
                                    .value;

                                String numberLesson = sheetObject
                                    .cell(CellIndex.indexByColumnRow(
                                        columnIndex: 1,
                                        rowIndex: i.cellIndex.rowIndex))
                                    .value
                                    .toString();

                                String? classItog;
                                int nullIndex = 0;
                                int colIndex = 0;
                                do {
                                  classItog = sheetObject
                                      .cell(CellIndex.indexByColumnRow(
                                          columnIndex: 0,
                                          rowIndex:
                                              i.cellIndex.rowIndex - colIndex))
                                      .value;
                                  colIndex++;

                                  print("Null");
                                  if (classItog == null) {
                                    nullIndex++;
                                  }
                                  if (nullIndex > 50) {
                                    break;
                                  }
                                } while (classItog == null);
                                nullIndex = 0;
                                String officeLesson = sheetObject
                                    .cell(CellIndex.indexByColumnRow(
                                        columnIndex:
                                            i.cellIndex.columnIndex + 1,
                                        rowIndex: i.cellIndex.rowIndex + 1))
                                    .value
                                    .toString();
                                print("Номер урока: $numberLesson");
                                print("День недели: $classItog");
                                print("Класс: $classes");
                                print("Урок: ${i.value.toString()}");
                                print("Кабинет: $officeLesson");

                                String str = listTimeLessons[
                                    int.parse(numberLesson) - 1];
                                List<String> parts = str.split(' - ');
                                String startLessonTime = parts[0].trim();
                                String endLessonTime = parts[1].trim();

                                addValueToMapWithMap(
                                    listLesson,
                                    classes,
                                    classItog!,
                                    LessonModel(
                                        number: numberLesson,
                                        title: i.value.toString(),
                                        office: officeLesson,
                                        startLessonTime: startLessonTime,
                                        endLessonTime: endLessonTime));
                              }
                            }
                            print("${i.cellIndex}");
                            print("${i.value}");
                            print("\n");
                          }
                        }
                      }

                      //print(mp);
                      print(listLesson);
                      print(listTimeLessons);
                      /*print(sheetObject
                          .cell(CellIndex.indexByColumnRow(
                              columnIndex: 2, rowIndex: 3))
                          .value);*/
                      setState(() {
                        nameClass = listLesson.keys.toList();
                        dataLoading = false;
                      });
                    }
                  }
                },
                child: const Text("Загрузить файл"),
              ),
            ),
            dataLoading
                ? const CircularProgressIndicator()
                : listClasses.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: listLesson.length,
                        itemBuilder: (context, item) => Column(
                              children: [
                                Text(nameClass[item]),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        listLesson[nameClass[item]]!.length,
                                    itemBuilder: (context2, item2) => Column(
                                          children: [
                                            Text(listLesson[nameClass[item]]!
                                                .keys
                                                .toList()[item2]),
                                            ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    listLesson[nameClass[item]]!
                                                        .values
                                                        .toList()[item2]
                                                        .toList()
                                                        .length,
                                                itemBuilder:
                                                    (context3, item3) => Row(
                                                          children: [
                                                            Text(
                                                                "${listLesson[nameClass[item]]!.values.toList()[item2].toList()[item3].number} "),
                                                            Text(
                                                                "Урок: ${listLesson[nameClass[item]]!.values.toList()[item2].toList()[item3].title} "),
                                                            Text(
                                                                "Кабинет: ${listLesson[nameClass[item]]!.values.toList()[item2].toList()[item3].office} "),
                                                            Text(
                                                                "Начало урока: ${listLesson[nameClass[item]]!.values.toList()[item2].toList()[item3].startLessonTime} "),
                                                            Text(
                                                                "Конец урока: ${listLesson[nameClass[item]]!.values.toList()[item2].toList()[item3].endLessonTime}"),
                                                          ],
                                                        ))
                                          ],
                                        ))
                              ],
                            ))
                    : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
