import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool connected;
  late bool statusLed;
  bool onConveyor = false,onDirection = false;
  late IOWebSocketChannel channel;
  late String errorOccured, dataReceived;
  Color colorFL = Colors.transparent;
  Color colorBL = Colors.transparent;
  Color colorFR = Colors.transparent;
  Color colorBR = Colors.transparent;
  Color collor = const Color(0xffC5C5C5);

  @override
  void initState() {
    // TODO: implement initState
    _tryConnect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('change direction'),
                  Switch(
                      value: onDirection,
                      onChanged: (val) {
                        setState(() {
                          onDirection = val;
                          if(onDirection){
                            _sendData('rotateCW');
                          }else{
                            _sendData('rotateCCW');
                          }
                        });
                      }),
                ],
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  Container(
                    height: 50,
                    width: 100,
                    //color: Colors.blue,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue),
                    child: TextButton(
                      onPressed: () {
                        _tryConnect();
                        print(connected);
                      },
                      child: const Text(
                        'Connect',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                        'connection Status : ${connected ? 'connected' : 'not connected'}'),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Start Conveyor'),
                  Switch(
                      value: onConveyor,
                      onChanged: (val) {
                        setState(() {
                          onConveyor = val;
                          if(onConveyor){
                            _sendData('onConveyor');
                          }else{
                            _sendData('offConveyor');
                          }
                        });
                      }),
                ],
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buttonDesign(Icons.expand_less, "forwardLeft", colorFL),
                      buttonDesign(Icons.expand_more, "backwardLeft", colorBL),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buttonDesign(Icons.expand_less, "forwardRight", colorFR),
                      buttonDesign(Icons.expand_more, "backwardRight", colorBR)
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buttonDesign(IconData icon, String data, Color color) {
    return GestureDetector(
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 100,
        ),
      ),
      onTapDown: (detail) {
        setState(() {
          if (data == 'forwardLeft') {
            colorFL = const Color(0xffC5C5C5);
          } else if (data == "backwardLeft") {
            colorBL = const Color(0xffC5C5C5);
          } else if (data == "forwardRight") {
            colorFR = const Color(0xffC5C5C5);
          } else if (data == "backwardRight") {
            colorBR = const Color(0xffC5C5C5);
          }
        });
        //_sendData(data);
      },
      onLongPressStart: (detail) {
        setState(() {
          if (data == 'forwardLeft') {
            colorFL = const Color(0xffC5C5C5);
          } else if (data == "backwardLeft") {
            colorBL = const Color(0xffC5C5C5);
          } else if (data == "forwardRight") {
            colorFR = const Color(0xffC5C5C5);
          } else if (data == "backwardRight") {
            colorBR = const Color(0xffC5C5C5);
          }
        });
        _sendData(data);
      },
      onTapUp: (detail) {
        setState(() {
          if (data == 'forwardLeft') {
            colorFL = Colors.transparent;
          } else if (data == "backwardLeft") {
            colorBL = Colors.transparent;
          } else if (data == "forwardRight") {
            colorFR = Colors.transparent;
          } else if (data == "backwardRight") {
            colorBR = Colors.transparent;
          }
        });
        _sendData("stop");
      },
      onLongPressUp: () {
        setState(() {
          if (data == 'forwardLeft') {
            colorFL = Colors.transparent;
          } else if (data == "backwardLeft") {
            colorBL = Colors.transparent;
          } else if (data == "forwardRight") {
            colorFR = Colors.transparent;
          } else if (data == "backwardRight") {
            colorBR = Colors.transparent;
          }
        });
        _sendData("stop");
      },
    );
  }

  void _sendData(String data) {
    channel.sink.add(data);
  }

  StreamSubscription _tryConnect() {
    connected = false;
    dataReceived = '';

    channel = IOWebSocketChannel.connect("ws://192.168.0.1:81");
    return channel.stream.listen(
      (data) {
        setState(() {
          dataReceived = data;
          if (data == "connected") {
            connected = true;
          } else if (dataReceived == "poweron:success") {
            statusLed = true;
          } else if (dataReceived == "poweroff:success") {
            statusLed = false;
          }
        });
      },
      onDone: () {
        print("Web socket is closed");
        setState(() {
          connected = false;
          dataReceived = "Connection lost";
        });
      },
      onError: (error) {
        print('cannot connect');
        setState(() {
          connected = false;
          dataReceived = "Error : Cannot connect to server";
        });
        //print(error.toString());
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    channel.sink.close();
    super.dispose();
  }
}
