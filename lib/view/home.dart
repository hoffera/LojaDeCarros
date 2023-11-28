import 'package:bd2/view/screen_carro.dart';
import 'package:bd2/view/screen_marca.dart';
import 'package:bd2/view/screen_modelo.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const ScreenCarro(),
      const ScreenModelo(),
      const HomeScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(),
        child: GNav(
          curve: Curves.easeInOutCirc,
          activeColor: Colors.white,
          mainAxisAlignment: MainAxisAlignment.center,
          tabActiveBorder: Border.all(
            color: Colors.grey[300]!,
          ),
          gap: 8,
          tabs: const [
            GButton(
              icon: Icons.child_friendly_sharp,
              text: 'Carro',
            ),
            GButton(
              icon: Icons.child_care_sharp,
              text: 'Modelo',
            ),
            GButton(
              icon: Icons.cruelty_free_sharp,
              text: 'Marca',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
