import 'package:flutter/material.dart';

class CouncilSchoolTabView extends StatefulWidget {
  const CouncilSchoolTabView({super.key});

  @override
  State<CouncilSchoolTabView> createState() => _CouncilSchoolTabViewState();
}

class _CouncilSchoolTabViewState extends State<CouncilSchoolTabView>
    with AutomaticKeepAliveClientMixin {
  String selectedFilter = 'Tất cả';

  final List<String> filterOptions = [
    'Tất cả',
    'Hội đồng thường',
    'Hội đồng tổng hợp',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 💡 DÙNG SCAFFOLD ĐỂ CHỨA NÚT NỔI
    return Scaffold(
      backgroundColor: Colors.transparent, // Giữ màu nền zin
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Chức năng tạo HĐ Cấp trường đang phát triển!",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Tạo hội đồng Cấp trường",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: filterOptions.map((String value) {
                final isSelected = selectedFilter == value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(value),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => selectedFilter = value);
                      }
                    },
                    selectedColor: const Color(0xFF2962FF).withOpacity(0.1),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2962FF)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2962FF)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Chưa có Hội đồng Cấp trường nào",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 💡 NÚT XUẤT FILE RIÊNG (heroTag KHÁC để chống lỗi)
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "export_school_btn",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Chức năng xuất file Hội đồng Cấp trường đang phát triển!",
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFFBDB76B),
        label: const Text(
          "Xuất file",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
