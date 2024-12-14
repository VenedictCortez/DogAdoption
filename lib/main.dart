import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(DogAdoptionApp());
}

class DogAdoptionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dog Adoption Companion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',  // Set SplashScreen as the initial route
      routes: {
        '/': (context) => SplashScreen(),  // SplashScreen route
        '/home': (context) => HomePage(),  // HomePage route
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? dogImageUrl;

  @override
  void initState() {
    super.initState();
    fetchRandomDogImage();
    navigateToNextScreen();
  }

  Future<void> fetchRandomDogImage() async {
    const String apiUrl = 'https://dog.ceo/api/breeds/image/random';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          dogImageUrl = data['message'];
        });
      }
    } catch (error) {
      print('Error fetching dog image: $error');
    }
  }

  void navigateToNextScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (dogImageUrl != null)
              Image.network(
                dogImageUrl!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Dog Adoption Companion App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> breeds = [
    'labrador',
    'goldenretriever',
    'germanshepherd',
    'bulldog',
    'beagle',
    'poodle',
    'rottweiler',
    'dachshund',
  ];

  Map<String, String> breedImages = {};

  @override
  void initState() {
    super.initState();
    fetchBreedImages();
  }

  Future<void> fetchBreedImages() async {
    for (String breed in breeds) {
      final url = 'https://dog.ceo/api/breed/$breed/images/random';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            breedImages[breed] = data['message'];
          });
        }
      } catch (error) {
        print('Error fetching image for $breed: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Breeds'),
      ),
      body: breedImages.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        padding: EdgeInsets.all(10),
        itemCount: breeds.length,
        itemBuilder: (context, index) {
          final breed = breeds[index];
          final imageUrl = breedImages[breed] ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BreedPage(breed: breed),
                ),
              );
            },
            child: Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    )
                  else
                    Center(child: CircularProgressIndicator()),
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text(
                      breed[0].toUpperCase() + breed.substring(1),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BreedPage extends StatelessWidget {
  final String breed;

  // List of dogs with breed and names
  final List<Map<String, String>> dogs = [
    {'name': 'Buddy', 'image': 'https://dog.ceo/api/breed/labrador/images/random'},
    {'name': 'Max', 'image': 'https://dog.ceo/api/breed/labrador/images/random'},
    {'name': 'Bella', 'image': 'https://dog.ceo/api/breed/labrador/images/random'},
    {'name': 'Charlie', 'image': 'https://dog.ceo/api/breed/labrador/images/random'},
  ];

  BreedPage({required this.breed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$breed Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Here are some dogs of the $breed breed:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: dogs.length,
              itemBuilder: (context, index) {
                final dog = dogs[index];
                final dogImageUrl = dog['image']!;
                return GestureDetector(
                  onTap: () {
                    // Navigate to DogDetailPage on tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DogDetailPage(dogName: dog['name']!, breed: breed),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FutureBuilder<String>(
                          future: _fetchDogImage(dogImageUrl),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Icon(Icons.error));
                            }
                            return Image.network(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: Text(
                            dog['name']!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _fetchDogImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message']; // Return the image URL
      } else {
        throw Exception('Failed to load dog image');
      }
    } catch (e) {
      print('Error fetching dog image: $e');
      return 'https://www.example.com/placeholder.jpg'; // Placeholder image in case of error
    }
  }
}

class DogDetailPage extends StatelessWidget {
  final String dogName;
  final String breed;

  DogDetailPage({required this.dogName, required this.breed});

  String generateRandomContact() {
    final randomPhoneNumbers = [
      '+1 555-1234',
      '+1 555-5678',
      '+1 555-8765',
      '+1 555-4321',
    ];
    return randomPhoneNumbers[(dogName.length + breed.length) % randomPhoneNumbers.length];
  }

  String generateRandomEmail() {
    final randomEmails = [
      'contact@dogadopt.com',
      'info@dogadopt.com',
      'help@dogadopt.com',
      'support@dogadopt.com',
    ];
    return randomEmails[(dogName.length + breed.length) % randomEmails.length];
  }

  @override
  Widget build(BuildContext context) {
    final contactNumber = generateRandomContact();
    final email = generateRandomEmail();

    return Scaffold(
      appBar: AppBar(
        title: Text('$dogName Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $dogName',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Breed: $breed',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Contact Number: $contactNumber',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous page
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}