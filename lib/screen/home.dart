import 'package:animate_do/animate_do.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:djani_gpt/apiServices/services.dart';
import 'package:djani_gpt/screen/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textController = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  late OpenAIService openAIService;
  String? generatedContent;
  String? generatedImageUrl;
  bool isProcessing = false;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    openAIService = OpenAIService();
    initSpeechToText();
    initTextToSpeech();
    checkConnectivity(); // Check connectivity when the page is initialized
  }

    Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion à Djani Gpt'),
        ),
      );
    }
  }

  Future<void> processQuestion(String question) async {
  setState(() {
    generatedImageUrl = null;
    generatedContent = 'Réponse en cours...';
    textController.clear();
    isProcessing = true;
  });

  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // Handle no internet connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de connexion à Djani Gpt'),
      ),
    );
    return;
  }

  if (question.toLowerCase().contains("comment tu t'appelle ?") ||
      question.toLowerCase().contains("quel est ton nom ?")||question.toLowerCase().contains("Quel est ton nom ?")
      ||question.toLowerCase().contains("Quel est ton nom")||question.toLowerCase().contains("Comment tu t'appelle ?")
      ||question.toLowerCase().contains("Comment tu t'appelle")) {
    // Response specufique
    final nameResponse =
        "Je suis Djani, une des meilleures créations de Monsieur Ahmadou Tidjani fils de Mohamadou Aminou, né le 26 mars 2002 au Cameroun dans la ville de Garoua. Il m'a créé dans le but de résoudre toutes sortes de problèmes que l'humanité peut rencontrer. Nous sommes plusieurs dans ma famille, Djani 1.0, le 2.0 et moi le 3.0.";
    
    setState(() {
      generatedImageUrl = null;
      generatedContent = nameResponse;
      isProcessing = false;
    });

    await systemSpeak(nameResponse);
  } else {
    final speech = await openAIService.isArtPromptAPI(question);

    setState(() {
      if (speech.contains('https')) {
        generatedImageUrl = speech;
        generatedContent = null;
      } else {
        generatedImageUrl = null;
        generatedContent = speech;
        isProcessing = false;
      }
    });

    if (isProcessing) {
      await systemSpeak(speech);
    }
  }
}

  void copyToClipboard() {
    if (generatedContent != null) {
      Clipboard.setData(ClipboardData(text: generatedContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Résultat copié dans le presse-papiers')),
      );
    }
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
  }

  Future<void> stopListening() async {
    await speechToText.stop();
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  Future<void> downloadImage() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Téléchargement en cours...'),
                ],
              ),
            );
          },
        );

        final dio = Dio();
        final response = await dio.get(generatedImageUrl!);

        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['isSuccess']
                  ? 'Image téléchargée avec succès'
                  : 'Échec du téléchargement de l\'image',
            ),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        print('Erreur lors du téléchargement de l\'image : $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'L\'autorisation de stockage est nécessaire pour télécharger l\'image'),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purpleAccent.shade100,
                Colors.deepPurple,
              ],
            ),
          ),
        ),
       actions: [
         IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 30,
            ),
          ),
         ZoomIn(
            delay: Duration(milliseconds: start + 3 * delay),
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () async {
                if (await speechToText.hasPermission &&
                    speechToText.isNotListening) {
                  await startListening();
                } else if (speechToText.isListening) {
                  final speech = await openAIService.isArtPromptAPI(lastWords);
                  if (speech.contains('https')) {
                    generatedImageUrl = speech;
                    generatedContent = null;
                  } else {
                    generatedImageUrl = null;
                    generatedContent = speech;
                    await systemSpeak(speech);
                  }
                  await stopListening();
                } else {
                  initSpeechToText();
                }
              },
              child: Image.asset(
                speechToText.isListening
                    ? "assets/images/leading.png"
                    : "assets/images/sound.png",
              ),
            ),
          ),
       ],
        title: BounceInDown(
          child: const Text(
            'DJANI GPT',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Times New Roman",
            ),
          ),
        ),
        leading: Image.asset("assets/images/leading.png"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            ZoomIn(
              child: Image.asset(
                'assets/images/assistant_iconassistant_icon.png',
                width: 150,
                height: 150,
              ),
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.purpleAccent.shade100,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                    color: Colors.black87,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: copyToClipboard,
                              icon: Icon(
                                Icons.copy,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          generatedContent == null
                              ? 'Bonjour, quelle tâche puis-je faire pour vous ?'
                              : generatedContent!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: generatedContent == null ? 25 : 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),    
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    IconButton(
                      onPressed:
                          generatedImageUrl != null ? downloadImage : null,
                      icon: Icon(Icons.save_alt_outlined),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(generatedImageUrl!),
                    ),
                  ],
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Fonctionnalités',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Colors.deepPurple,
                      headerText: 'DJANI GPT',
                      descriptionText:
                          'Une façon plus intelligente de rester organisé et informé avec DJANI GPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Colors.deepPurple,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Inspirez-vous et restez créatif avec votre assistant personnel optimisé par Dall-E",',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Colors.deepPurple,
                      headerText: 'Assistant vocal intelligent',
                      descriptionText:
                          'Obtenez le meilleur des deux mondes avec un assistant vocal optimisé par Dall-E et DJANI GPT',
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 100,), 
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton:  Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                    Colors.deepPurpleAccent.shade100,
                    Colors.deepPurple,
                   ],
                  ),
                  borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 25,),
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color.fromARGB(221, 240, 228, 228),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: textController,
                          decoration: InputDecoration(
                            hintText: "Rechercher...",
                            enabledBorder: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [
                          Colors.purpleAccent.shade100,
                          Colors.deepPurple,
                        ])),
                    child: InkWell(
                                            onTap: () async {
                          String question = textController.text;
                          if (question.isNotEmpty) {
                            setState(() {
                              processQuestion(question);
                            });

                            final speech = await openAIService.isArtPromptAPI(question);

                            if (speech.contains('https')) {
                              generatedImageUrl = speech;
                              generatedContent = null;
                              setState(() {});
                            } else {
                              generatedImageUrl = null;
                              generatedContent = speech;
                              setState(() {
                                isProcessing = true;
                              });
                              await systemSpeak(speech);
                            }
                          }
                        },

                       child: Icon(Icons.send,color: Colors.white,),
                    ),
                    
                  ),
                ],
              ),
              
            ),
    );
  }
}