import 'package:djani_gpt/screen/home.dart';
import 'package:flutter/material.dart';
class splashScreen extends StatelessWidget {
  const splashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Stack(
             children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/1.6,

                decoration: BoxDecoration(
                  color: Colors.white,
                ),

              ),
               Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/1.6,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                   colors: [
                    Colors.purpleAccent.shade100,
                          Colors.deepPurple,
                   ],
                  ),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(60)),
                ),
                child: Center(child: Image.asset("assets/images/splash.png")),
              ),
             ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/2.666,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                   colors: [
                   Colors.purpleAccent.shade100,
                          Colors.deepPurple,
                   ],
                  ),
                ),
              ),
          ),
           Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/2.666,
                decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(60)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
                  child: Column(
                    children: [
                      Text("Bienvenue sur DJANI GPT",style: TextStyle(
                       fontSize: 22,
                       fontWeight: FontWeight.bold,
                      ),
                      ),
                      SizedBox(height: 20,),
                      Text("Une intelligence artificielle qui répond à toutes vos questions et qui génère des images grace à votre imagination",
                      textAlign: TextAlign.center,),

                    ],
                    ),
                ),
              ),
              ),
             ],
            ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: ElevatedButton.icon(
                        onPressed: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
                        }, icon: Icon(Icons.navigate_next),
                         label: Text("SUIVANT"),
                         ),
          );
      }
    }