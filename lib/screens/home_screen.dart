// ignore_for_file: non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_app/rounded_button.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../main.dart';

int lol = 0;

String msg = 'hello';
int total = 0, p1_count = 0, p2_count = 0, p1_cost = 199, p2_cost = 499;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String id = "home_screen";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MqttServerClient client;
  Future<MqttServerClient> connect() async {
    print("before client");
    client =
        MqttServerClient.withPort('test.mosquitto.org', MyApp.clientId, 1883);

    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.keepAlivePeriod = 20;
    print("before conn");
    final connMessage = MqttConnectMessage()
        // .authenticateAs('admin', 'smartboat@rec&adr')
        // ignore: deprecated_member_use
        .withClientIdentifier(MyApp.clientId)
        // ignore: deprecated_member_use
        .keepAliveFor(6000)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    print("before try");
    try {
      await client.connect();
      print("inside try");
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      lol++;
      print('Received message:$payload from topic: ${c[0].topic}>');
      msg = payload;
      print("The message is " + msg);
      setState(() {});

      if (msg == "14718612223") {
        p1_count++;
        total += p1_cost;
      }
      if (msg == "2119223118") {
        p2_count++;
        total += p2_cost;
      }
    });

    return client;
  }

// connection succeeded
  void onConnected() {
    print('Connected');
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String? topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  @override
  void initState() {
    super.initState();

    void start() async {
      await connect();
      client.subscribe("iot/rfid/tag", MqttQos.atLeastOnce);
    }

    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEBF1F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffEBF1F4),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // Navigator.pushNamed(context, THSSettingsPage.id);
        //     },
        //     icon: const Icon(
        //       Icons.delete_forever,
        //       color: Colors.black,
        //     ),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: const Color(0xffEBF1F4),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$lol Items",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, THSSettingsPage.id);
                        },
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.black54,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: p1_count > 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: const Color.fromARGB(31, 134, 133, 133),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  width: 150,
                                  height: 150,
                                  child: Image.network(
                                      "https://m.media-amazon.com/images/I/7145NGq89bL._AC_UY218_.jpg"),
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                     mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "PS4 console",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      Text(
                                        "\$ $p1_cost.00   x   $p1_count",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: p2_count > 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: const Color.fromARGB(31, 134, 133, 133),
                            child: Row(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  child: Image.network(
                                      "https://m.media-amazon.com/images/I/71xb2xkN5qL._AC_UY218_.jpg"),
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "iPhone 13",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      Text(
                                        "\$ $p2_cost.00   x   $p2_count",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(
                  height: 50,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 35),
                        ),
                        Text(
                          "\$ $total.00",
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 25),
                        )
                      ],
                    ),
                  ),
                ),
                RoundedButton(
                  title: "Buy Now",
                  color: Colors.black,
                  onPressed: () {},
                  width: MediaQuery.of(context).size.width * 0.9,
                  fontSize: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}