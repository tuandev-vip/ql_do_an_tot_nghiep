import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';

class ExcelHelper {
  static Future<bool> exportToExcel({
    required String fileName,
    required String deptId, // Thêm deptId để lấy tên bộ môn đưa vào tiêu đề
    required List<String> headers, // Đổi sang List<String> để dễ cấu hình style
    required List<List<CellValue>> dataRows,
  }) async {
    try {
      var excel = Excel.createExcel();
      String sheetName = 'Danh_Sach_Phan_Cong';
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      // 1. TỰ ĐỘNG DÃN DÒNG
      sheetObject.setColumnWidth(0, 8.0);
      sheetObject.setColumnWidth(1, 20.0);
      sheetObject.setColumnWidth(2, 30.0);
      sheetObject.setColumnWidth(3, 15.0);
      sheetObject.setColumnWidth(4, 30.0);

      // 2. TẠO TIÊU ĐỀ LỚN (Gộp từ ô A1 đến E2)
      sheetObject.merge(
        CellIndex.indexByString("A1"),
        CellIndex.indexByString("E2"),
        customValue: TextCellValue(
          "DANH SÁCH PHÂN CÔNG GVHD - BỘ MÔN ${deptId.toUpperCase()}",
        ),
      );

      // Đổ màu vàng, in đậm, căn giữa cho Tiêu đề lớn
      var titleStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#FFFF00"), // Màu vàng
      );
      sheetObject.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

      // 3. TẠO DÒNG HEADER (Hàng thứ 3 - index là 2)
      var headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#D3D3D3"), // Màu xám nhẹ
      );

      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // 4. ĐỔ DỮ LIỆU BÌNH THƯỜNG (Bắt đầu từ hàng 4 - index là 3)
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

          // Căn giữa cho STT, Mã SV, Lớp cho đẹp (Giữ nguyên tên trái)
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

      // 5. LƯU FILE
      List<int>? fileBytes = excel.encode();
      if (fileBytes != null) {
        Uint8List bytes = Uint8List.fromList(fileBytes);
        await FileSaver.instance.saveFile(
          name: '$fileName.xlsx',
          bytes: bytes,
          mimeType: MimeType.microsoftExcel,
        );
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi xuất Excel: $e");
      return false;
    }
  }
}
