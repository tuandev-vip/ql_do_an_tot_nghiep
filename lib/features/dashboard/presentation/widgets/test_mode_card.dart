import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/bloc/batch_bloc.dart';
import 'package:ql_do_an_tot_nghiep/features/batch/presentation/bloc/batch_event.dart';
import '../../../../core/untils/time_manager.dart';
import '../../../batch/data/models/batch_model.dart';

class TestModeCard extends StatefulWidget {
  final BatchModel? activeBatch;
  const TestModeCard({super.key, this.activeBatch});

  @override
  State<TestModeCard> createState() => _TestModeCardState();
}

class _TestModeCardState extends State<TestModeCard> {
  DateTime selectedDate = TimeManager.now();
  String? selectedMilestone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "CỖ MÁY THỜI GIAN (TEST MODE)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // DROPDOWN TỰ ĐỘNG ĐỔ 18+ MỐC TỪ BATCH
          if (widget.activeBatch != null)
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Chọn mốc cần test"),
              initialValue: selectedMilestone,
              items: widget.activeBatch!.deadlines.keys.map((String key) {
                return DropdownMenuItem(
                  value: key,
                  child: Text(key, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedMilestone = val;
                    // Lấy ngày của mốc đó và trừ đi 1 giờ để test trạng thái "Còn hạn"
                    String? dateStr = widget.activeBatch!.deadlines[val];
                    if (dateStr != null && dateStr.isNotEmpty) {
                      selectedDate = DateTime.parse(
                        dateStr,
                      ).subtract(const Duration(hours: 1));
                    }
                  });
                }
              },
            ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Ngày áp dụng: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
            ),
            subtitle: const Text(
              "Bạn có thể chỉnh ngày thủ công tại đây",
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() => selectedDate = date);
              }
            },
          ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    TimeManager.setFakeTime(selectedDate);

                    // Ép cả hệ thống vẽ lại để nhận giờ mới
                    context.read<BatchBloc>().add(LoadBatchesEvent());

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🚀 Đã nhảy thời gian!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "ÁP DỤNG",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    TimeManager.stopFaking();
                    context.read<BatchBloc>().add(LoadBatchesEvent());
                    setState(() {
                      selectedDate = DateTime.now();
                      selectedMilestone = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🛑 Đã quay về hiện tại")),
                    );
                  },
                  child: const Text("DỪNG"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
