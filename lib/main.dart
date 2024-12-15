import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

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
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
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
    'pomeranian',
    'pug',
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

  BreedPage({required this.breed});


  final List<String> dogNames = [
    'Buddy', 'Fido', 'Fluffy', 'Lassie', 'Lucky', 'Rex', 'Rover', 'Spot',
    'Duke', 'Elizabeth', 'King', 'Kate', 'Princess',
    'Annie', 'Bella', 'Emily', 'Emma', 'Maggie', 'Molly', 'Sophie',
    'Barney', 'Charlie', 'Dexter', 'Jack', 'Jake', 'Max', 'Oscar',
    'Daisy', 'Lily', 'Rose', 'Tulip', 'Violet',
    'Cooper', 'Ferrari', 'Jazz', 'Kia', 'Ranger',
    'Chef', 'Cocoa', 'Cookie', 'Olive', 'Peanut', 'Pork Chop', 'Pumpkin', 'Sugar', 'Sushi',
    'Comet', 'Cosmo', 'Luna', 'Pluto', 'Star', 'Stella', 'Venus'
  ];

  String getRandomName() {
    final random = Random();
    return dogNames[random.nextInt(dogNames.length)];
  }

  List<Map<String, String>> getDogsForBreed(String breed) {
    return List.generate(4, (index) {
      return {
        'name': getRandomName(), // Assign a random name
        'image': 'https://dog.ceo/api/breed/$breed/images/random',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dogs = getDogsForBreed(breed);

    return Scaffold(
      appBar: AppBar(
        title: Text(breed.toUpperCase(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Available $breed for adoption:',
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
                        builder: (context) =>
                            DogDetailPage(dogName: dog['name']!, breed: breed),
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
        return data['message'];
      } else {
        throw Exception('Failed to load dog image');
      }
    } catch (e) {
      print('Error fetching dog image: $e');
      return 'https://www.example.com/placeholder.jpg';
    }
  }
}

class DogDetailPage extends StatelessWidget {
  final String dogName;
  final String breed;

  DogDetailPage({required this.dogName, required this.breed});

  String generateRandomContact() {
    final randomPhoneNumbers = [
      '+63 912 345 6789', '+63 923 456 7890', '+63 934 567 8901', '+63 945 678 9012',
      '+63 956 789 0123', '+63 967 890 1234', '+63 978 901 2345', '+63 989 012 3456',
      '+63 990 123 4567', '+63 901 234 5678'
    ];
    return randomPhoneNumbers[(dogName.length + breed.length) % randomPhoneNumbers.length];
  }

  String generateRandomEmail() {
    final randomEmails = [
      'buddy123@dogadopt.com', 'fido456@dogadopt.com', 'fluffy789@dogadopt.com',
      'lassie321@dogadopt.com', 'lucky654@dogadopt.com', 'rex987@dogadopt.com',
      'rover234@dogadopt.com', 'spot567@dogadopt.com', 'duke890@dogadopt.com',
      'elizabeth112@dogadopt.com'
    ];
    return randomEmails[(dogName.length + breed.length) % randomEmails.length];
  }
  String generateRandomCharacteristics() {
    final randomCharacteristics = [
      'Loyal', 'Friendly', 'Playful', 'Energetic', 'Affectionate', 'Intelligent',
      'Curious', 'Alert', 'Protective', 'Brave', 'Gentle', 'Obedient', 'Trainable',
      'Adaptable', 'Cheerful', 'Social', 'Independent', 'Loving', 'Patient', 'Quiet',
      'Active', 'Agile', 'Hardworking', 'Strong', 'Confident', 'Courageous', 'Easygoing',
      'Sensitive', 'Reliable', 'Devoted', 'Fearless', 'Mischievous', 'Clumsy', 'Clever',
      'Faithful', 'Dutiful', 'Watchful', 'Trusting', 'Comical', 'Shy', 'Excitable',
      'Focused', 'Tolerant', 'Resourceful', 'Kind', 'Perceptive', 'Fun-loving',
      'Determined', 'Vocal', 'Companionable', 'Outgoing'
    ];
    return randomCharacteristics[(dogName.length + breed.length) % randomCharacteristics.length];
  }

  String generateRandomCon() {
    final randomCon = [
      'Requires daily exercise', 'Needs regular grooming', 'Can be expensive to care for',
      'May bark excessively', 'Can chew or destroy furniture', 'Needs training',
      'Requires constant attention as a puppy', 'May shed a lot', 'Can be aggressive if not socialized',
      'May have separation anxiety', 'Requires regular veterinary checkups',
      'Can bring in dirt or mud', 'May chase small animals', 'Needs time and patience',
      'Can develop health problems with age', 'Can be noisy', 'Might not get along with other pets',
      'Needs a proper diet', 'Can be difficult to house-train', 'May jump on people',
      'Requires vaccinations', 'Can be stubborn', 'Might not be allowed in rented housing',
      'Can attract fleas or ticks', 'Needs a lot of space in some cases'
    ];
    return randomCon[(dogName.length + breed.length) % randomCon.length];
  }

    @override
    Widget build(BuildContext context) {
      final contactNumber = generateRandomContact();
      final email = generateRandomEmail();
      final characteristic = generateRandomCharacteristics();
      final con = generateRandomCon();

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
              SizedBox(height: 10),
              Text(
                'Characteristic: $characteristic',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Con: $con',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back'),
              ),
            ],
          ),
        ),
      );
    }
  }