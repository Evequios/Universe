import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:wwe_universe/pages/News/news_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WWE Universe',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Expanded(
            child: Image(
              image: AssetImage('assets/home.jpg')
              )
            ),
            const Text('Welcome',
            style: TextStyle(
              fontSize: 80,
              letterSpacing: 1.2,
              color: Colors.white,
              backgroundColor: Colors.black
            )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: const Text(
                    'IRL',
                    style: TextStyle(
                      fontSize: 20,
                      backgroundColor : Colors.grey,
                      color: Colors.black)),
                  onPressed: () {},),
                
                TextButton(
                  child: const Text(
                    'Universe',
                    style : TextStyle(
                      fontSize: 20,
                      backgroundColor: Colors.grey,
                      color: Colors.black
                    )),
                  onPressed: () {},),
              ],
            ) 
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget{
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context){
    return AnimatedSplashScreen(
      splash: 'assets/home.jpg',
      splashIconSize: double.infinity,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.black,
      nextScreen: const NewsPage());
  }
}
