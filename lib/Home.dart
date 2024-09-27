import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_gradiate/text_gradiate.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {

 final Gemini gemini = Gemini.instance;


List<ChatMessage> messages = [];

ChatUser CurrentUser = ChatUser(id: '0' , firstName: 'Chat user',profileImage: 'https://static.vecteezy.com/system/resources/previews/019/896/008/original/male-user-avatar-icon-in-flat-design-style-person-signs-illustration-png.png');
ChatUser GeminiUser = ChatUser(id: '1',firstName: 'Gemini ', profileImage: 'https://tse2.mm.bing.net/th?id=OIP.bu6KYmEp11IEkmrrca06pgHaD4&pid=Api&P=0&h=220');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       extendBodyBehindAppBar: true, 
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        title:TextGradiate(
  text: Text(
    'Gemini Chat',
    style: TextStyle(fontSize: 24.0,fontWeight: FontWeight.bold),
  ),
  colors: [Colors.blue, Colors.deepPurple.shade500 , Colors.purple.shade300 , Colors.pink.shade700 ],
  gradientType: GradientType.linear,
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  tileMode: TileMode.clamp,
),
        centerTitle: true,
      backgroundColor: Colors.transparent, 
        elevation: 0,
    
      ),
      body: Stack(
        children: [
           Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://images.pexels.com/photos/27453112/pexels-photo-27453112.jpeg?cs=srgb&dl=pexels-114877721-27453112.jpg&fm=jpg&_gl=1*35z0kp*_ga*OTkzMDk0NjY0LjE2OTgyNTgyNTI.*_ga_8JE65Q40S6*MTcyNzM3MzYzNC4zNi4xLjE3MjczNzM5NzcuMC4wLjA.',
              fit: BoxFit.cover,
          placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.white,)),
        errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          _buildui(),
        ],
      )
    );
  }

  Widget _buildui (){
 
 return DashChat(
  inputOptions: InputOptions(trailing: [
    IconButton(onPressed:_sendMediaMessage,
     icon: Icon(Icons.image,color: Colors.white,))
  ])
  ,
  currentUser: CurrentUser, onSend: _sendMessage, messages: messages);

  }

void _sendMessage(ChatMessage chatmessage){

setState(() {
  messages = [chatmessage,...messages];
});


try{

String Question = chatmessage.text;

 List<Uint8List>? image ;
if(chatmessage.medias?.isNotEmpty??false){
  image =[
    File(chatmessage.medias!.first.url).readAsBytesSync(),
  ];

}
gemini.streamGenerateContent(Question,images: image).listen((event) {
  
  ChatMessage ? lastmessage = messages.firstOrNull ;

if(lastmessage!=null&&lastmessage.user==GeminiUser){
  lastmessage = messages.removeAt(0);
String response = event.content?.parts!.fold('', (previous , current)=> "$previous ${current.text}")??'';

lastmessage.text +=response;
setState(() {
  messages = [lastmessage!,...messages];
});
}else{
  String response = event.content?.parts!.fold('', (previous , current)=> "$previous ${current.text}")??'';
  ChatMessage message = ChatMessage(user: GeminiUser, 
  createdAt: DateTime.now(),
  text: response); 

  setState(() {
    messages = [message,...messages];
  });
};

},);

}catch(e){

print(e.toString());

}


}

void _sendMediaMessage()async{

ImagePicker picker = ImagePicker();
XFile? file = await picker.pickImage(source: ImageSource.gallery);

if(file!=null){
  ChatMessage chatMessage = ChatMessage(user: CurrentUser, createdAt: DateTime.now(),text: 'Describe me this image',medias: [
ChatMedia(url: file.path, fileName: '', type: MediaType.image),
  ]);
  _sendMessage(chatMessage);
}

}

}