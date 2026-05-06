import 'package:flutter/material.dart';
import '../../data/models/weekly_report_model.dart';

class WeekSelectorDropdown extends StatelessWidget {
  final int selectedWeek;
  final Map<int, WeeklyReportModel> reportsData;
  final ValueChanged<int?> onWeekChanged;

  const WeekSelectorDropdown({
    super.key,
    required this.selectedWeek,
    required this.reportsData,
    required this.onWeekChanged,
  });

  Color _getColorByStatus(String status) {
    switch (status) {
      case "REVIEWED":
        return const Color(0xFF4CAF50);
      case "SUBMITTED":
        return const Color(0xFFFF9800);
      case "OPEN":
        return const Color(0xFF2962FF);
      case "OVERDUE":
        return Colors.redAccent;
      default:
        return Colors.grey.shade400;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "REVIEWED":
        return "Đã nhận xét";
      case "SUBMITTED":
        return "Chờ nhận xét";
      case "OPEN":
        return "Đang mở";
      case "OVERDUE":
        return "Quá hạn nộp";
      default:
        return "Chưa mở";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = reportsData[selectedWeek]!.status;
    final currentColor = _getColorByStatus(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: currentColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: currentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedWeek,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.white,
          onChanged: onWeekChanged,
          items: reportsData.keys.map((weekNum) {
            final status = reportsData[weekNum]!.status;
            final itemColor = _getColorByStatus(status);
            return DropdownMenuItem<int>(
              value: weekNum,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: itemColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Tuần $weekNum: ${_getStatusText(status)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) => reportsData.keys.map((weekNum) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tuần $weekNum: ${_getStatusText(reportsData[weekNum]!.status)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
