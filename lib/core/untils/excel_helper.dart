import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:io'; // 💡 Bắt buộc có để can thiệp thư mục Android

class ExcelHelper {
  // =========================================================================
  // 1. HÀM XUẤT FILE CHO TRƯỞNG BỘ MÔN (Hàm gốc của ông)
  // =========================================================================
  static Future<bool> exportToExcel({
    required String fileName,
    required String deptId,
    required List<String> headers,
    required List<List<CellValue>> dataRows,
  }) async {
    try {
      var excel = Excel.createExcel();
      String sheetName = 'Danh_Sach_Phan_Cong';
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      sheetObject.setColumnWidth(0, 8.0);
      sheetObject.setColumnWidth(1, 20.0);
      sheetObject.setColumnWidth(2, 30.0);
      sheetObject.setColumnWidth(3, 15.0);
      sheetObject.setColumnWidth(4, 30.0);

      sheetObject.merge(
        CellIndex.indexByString("A1"),
        CellIndex.indexByString("E2"),
        customValue: TextCellValue(
          "DANH SÁCH PHÂN CÔNG GVHD - BỘ MÔN ${deptId.toUpperCase()}",
        ),
      );

      var titleStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#FFFF00"),
      );
      sheetObject.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

      var headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#D3D3D3"),
      );

      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      int rowIndex = 3;
      for (var row in dataRows) {
        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex,
            ),
          );
          cell.value = row[colIndex];

          if (colIndex == 0 || colIndex == 1 || colIndex == 3) {
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Center,
              verticalAlign: VerticalAlign.Center,
            );
          } else {
            cell.cellStyle = CellStyle(verticalAlign: VerticalAlign.Center);
          }
        }
        rowIndex++;
      }

      // 💡 LOGIC LƯU FILE ÉP BUỘC CHO ANDROID
      List<int>? fileBytes = excel.encode();
      if (fileBytes != null) {
        Uint8List bytes = Uint8List.fromList(fileBytes);
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        String finalFileName = "${fileName}_$timeStamp.xlsx";

        if (Platform.isAndroid) {
          String path = '/storage/emulated/0/Download/$finalFileName';
          File file = File(path);
          await file.writeAsBytes(bytes);
        } else {
          await FileSaver.instance.saveAs(
            name: "${fileName}_$timeStamp",
            bytes: bytes,
            fileExtension: 'xlsx',
            mimeType: MimeType.microsoftExcel,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi xuất Excel: $e");
      return false;
    }
  }

  // =========================================================================
  // 2. HÀM XUẤT EXCEL 2 BẢNG CHO TRƯỞNG KHOA (CẤP CƠ SỞ)
  // =========================================================================
  static Future<bool> exportAdminBaseCouncilExcel({
    required String fileName,
    required List<dynamic> students,
    required List<dynamic> councils,
  }) async {
    try {
      var excel = Excel.createExcel();
      String sheetName = 'Hoi_Dong_Co_So';
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      sheetObject.setColumnWidth(0, 8.0);
      sheetObject.setColumnWidth(1, 15.0);
      sheetObject.setColumnWidth(2, 15.0);
      sheetObject.setColumnWidth(3, 25.0);
      sheetObject.setColumnWidth(4, 15.0);
      sheetObject.setColumnWidth(5, 35.0);
      sheetObject.setColumnWidth(7, 15.0);
      sheetObject.setColumnWidth(8, 30.0);

      var headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#D3D3D3"), // Xám
      );
      var centerStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      var wrapStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      );

      // BẢNG 1: SINH VIÊN
      List<String> svHeaders = [
        "STT",
        "Mã Hội Đồng",
        "Mã SV",
        "Họ Tên",
        "Lớp",
        "Tên Đề Tài",
      ];
      for (int i = 0; i < svHeaders.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(svHeaders[i]);
        cell.cellStyle = headerStyle;
      }

      for (int i = 0; i < students.length; i++) {
        var sv = students[i];
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = IntCellValue(
          i + 1,
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = TextCellValue(
          sv['council_code'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = TextCellValue(
          sv['student_code'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = TextCellValue(
          sv['full_name'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = TextCellValue(
          sv['class_name'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = TextCellValue(
          sv['topic_name'] ?? '',
        );

        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
      }

      // BẢNG 2: HỘI ĐỒNG
      List<String> hdHeaders = ["Mã Hội Đồng", "Thành viên"];
      for (int i = 0; i < hdHeaders.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 7 + i, rowIndex: 0),
        );
        cell.value = TextCellValue(hdHeaders[i]);
        cell.cellStyle = headerStyle;
      }

      for (int i = 0; i < councils.length; i++) {
        var hd = councils[i];
        var cellCode = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1),
        );
        cellCode.value = TextCellValue(hd['council_code'] ?? '');
        cellCode.cellStyle = centerStyle;

        var cellMem = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1),
        );
        cellMem.value = TextCellValue(hd['members'] ?? '');
        cellMem.cellStyle = wrapStyle;
      }

      // 💡 LOGIC LƯU FILE ÉP BUỘC CHO ANDROID
      List<int>? fileBytes = excel.encode();
      if (fileBytes != null) {
        Uint8List bytes = Uint8List.fromList(fileBytes);
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        String finalFileName = "${fileName}_$timeStamp.xlsx";

        if (Platform.isAndroid) {
          String path = '/storage/emulated/0/Download/$finalFileName';
          File file = File(path);
          await file.writeAsBytes(bytes);
        } else {
          await FileSaver.instance.saveAs(
            name: "${fileName}_$timeStamp",
            bytes: bytes,
            fileExtension: 'xlsx',
            mimeType: MimeType.microsoftExcel,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi xuất Excel Cơ sở: $e");
      return false;
    }
  }

  // =========================================================================
  // 3. HÀM MỚI: XUẤT EXCEL 2 BẢNG CHO TRƯỞNG KHOA (CẤP TRƯỜNG)
  // =========================================================================
  static Future<bool> exportAdminSchoolCouncilExcel({
    required String fileName,
    required List<dynamic> students,
    required List<dynamic> councils,
  }) async {
    try {
      var excel = Excel.createExcel();
      String sheetName = 'Hoi_Dong_Cap_Truong';
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      sheetObject.setColumnWidth(0, 8.0);
      sheetObject.setColumnWidth(1, 15.0);
      sheetObject.setColumnWidth(2, 15.0);
      sheetObject.setColumnWidth(3, 25.0);
      sheetObject.setColumnWidth(4, 15.0);
      sheetObject.setColumnWidth(5, 35.0);
      sheetObject.setColumnWidth(7, 15.0);
      sheetObject.setColumnWidth(8, 30.0);

      var headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#2962FF"), // Xanh dương
        fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
      );
      var centerStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      var wrapStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      );

      // BẢNG 1: SINH VIÊN
      List<String> svHeaders = [
        "STT",
        "Mã Hội Đồng",
        "Mã SV",
        "Họ Tên",
        "Lớp",
        "Tên Đề Tài",
      ];
      for (int i = 0; i < svHeaders.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(svHeaders[i]);
        cell.cellStyle = headerStyle;
      }

      for (int i = 0; i < students.length; i++) {
        var sv = students[i];
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = IntCellValue(
          i + 1,
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = TextCellValue(
          sv['council_code'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = TextCellValue(
          sv['student_code'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = TextCellValue(
          sv['full_name'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = TextCellValue(
          sv['class_name'] ?? '',
        );
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = TextCellValue(
          sv['topic_name'] ?? '',
        );

        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1),
                )
                .cellStyle =
            centerStyle;
      }

      // BẢNG 2: HỘI ĐỒNG
      List<String> hdHeaders = ["Mã Hội Đồng", "Thành viên"];
      for (int i = 0; i < hdHeaders.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 7 + i, rowIndex: 0),
        );
        cell.value = TextCellValue(hdHeaders[i]);
        cell.cellStyle = headerStyle;
      }

      for (int i = 0; i < councils.length; i++) {
        var hd = councils[i];
        var cellCode = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1),
        );
        cellCode.value = TextCellValue(hd['council_code'] ?? '');
        cellCode.cellStyle = centerStyle;

        var cellMem = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1),
        );
        cellMem.value = TextCellValue(hd['members'] ?? '');
        cellMem.cellStyle = wrapStyle;
      }

      // 💡 LOGIC LƯU FILE ÉP BUỘC CHO ANDROID
      List<int>? fileBytes = excel.encode();
      if (fileBytes != null) {
        Uint8List bytes = Uint8List.fromList(fileBytes);
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        String finalFileName = "${fileName}_$timeStamp.xlsx";

        if (Platform.isAndroid) {
          String path = '/storage/emulated/0/Download/$finalFileName';
          File file = File(path);
          await file.writeAsBytes(bytes);
        } else {
          await FileSaver.instance.saveAs(
            name: "${fileName}_$timeStamp",
            bytes: bytes,
            fileExtension: 'xlsx',
            mimeType: MimeType.microsoftExcel,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi xuất Excel Cấp trường: $e");
      return false;
    }
  }
}
