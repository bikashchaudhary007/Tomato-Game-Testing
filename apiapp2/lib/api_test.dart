import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiIntegration extends StatefulWidget {
  const ApiIntegration({super.key});

  @override
  State<ApiIntegration> createState() => _ApiIntegrationState();
}

class _ApiIntegrationState extends State<ApiIntegration> {
  late Future<GameData> futureGameData;

  @override
  void initState() {
    super.initState();
    // Initial API call when the widget is created.
    futureGameData = fetchGameDataFromAPI();
  }

  void refreshData() {
    setState(() {
      // Trigger a new API request when the "Refresh" button is pressed.
      futureGameData = fetchGameDataFromAPI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Api App"),
      ),
      body: FutureBuilder<GameData>(
        future: futureGameData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No data available."));
          }

          // Display the image using Image.network
          return Column(
            mainAxisAlignment:
            MainAxisAlignment.center, // Center the contents vertically.
            children: <Widget>[
              Center(
                child: Image.network(
                  snapshot.data?.imageUrl ?? '',
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      children: [
                        Text("Failed to load the image."),
                        Text("Error: ${error.toString()}"),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                  height: 16), // Add some space between the image and the text.
              Text(
                snapshot.data?.solution ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Center the text horizontally.
              ),
              Divider(),

              //Refresh Button
              ElevatedButton(onPressed:refreshData, child: Text('Refresh'))
            ],
          );
        },
      ),
    );
  }
}

Future<GameData> fetchGameDataFromAPI() async {
  final response =
  // await http.get(Uri.parse('https://marcconrad.com/uob/tomato/api.php'));
  await http
      .get(Uri.parse('https://marcconrad.com/uob/tomato/api.php?out=json'));
  if (response.statusCode == 200) {
    Map<String, dynamic> responseJson = json.decode(response.body);
    GameData gameData = createGameData(responseJson);
    return gameData;
  } else {
    throw Exception('Failed to load data from the API');
  }
}

GameData createGameData(Map<String, dynamic> data) {
  String imageUrl = data["question"];
  // print(imageUrl);
  String solution = data["solution"].toString(); // Convert to Strin;
  return GameData(
    imageUrl: imageUrl,
    solution: solution,
  );
}

class GameData {
  final String imageUrl; // Represents the image URL
  final String solution; // Represents the solution string

  GameData({required this.imageUrl, required this.solution});
}
