import 'package:flutter/material.dart';
import 'package:front_end_flutter/screens/giacngu.dart';
import 'package:front_end_flutter/screens/luongnuoc.dart';
import 'package:front_end_flutter/screens/uongthuoc.dart';
import 'package:front_end_flutter/screens/nhatky.dart';
import 'package:front_end_flutter/screens/thongtin.dart';
import 'package:front_end_flutter/screens/chiso.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Trang chính
      _buildMainPage(),
      // Nhật ký
      NhatKyScreen(userId: widget.userId),
      // Chỉ số
      ChiSoScreen(userId: widget.userId),
      // Profile
      ThongTinScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMainPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Card 1: Lịch uống thuốc
          SizedBox(
            height: 150, // Chiều cao của Card
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        'Lịch trình uống thuốc',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      subtitle: Text(
                        'Xem lịch uống thuốc của bạn.',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    UongThuocScreen(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.medication, color: Colors.red, size: 60),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Card 2: Lịch uống nước
          SizedBox(
            height: 150, // Chiều cao của Card
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        'Lịch uống nước',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      subtitle: Text(
                        'Xem lịch uống nước của bạn.',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    LuongNuocScreen(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.local_drink,
                      color: Colors.green,
                      size: 60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Card 3: Giấc ngủ
          SizedBox(
            height: 150, // Chiều cao của Card
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        'Giấc ngủ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      subtitle: Text(
                        'Xem thông tin giấc ngủ của bạn.',
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    GhiChepScreen(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.bed, color: Colors.indigo, size: 60),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách tiêu đề cho từng trang
    final List<String> titles = [
      'Trang chính',
      'Nhật ký',
      'Chỉ số',
      'Thông tin cá nhân',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex], // Tiêu đề thay đổi theo trang
          style: TextStyle(
            color: const Color.fromARGB(255, 102, 102, 166),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chính'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Nhật ký'),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Chỉ số',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: const Color.fromARGB(255, 102, 102, 166),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
