import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List images = [];
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  int currentPage = 1;
  int perPage = 15;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchImageAPI();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(82, 98, 0, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: searchImages,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  GridView.builder(
                    controller: scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      crossAxisCount: 3,
                      childAspectRatio: 2 / 3,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.white,
                        child: Image.network(
                          images[index]['src']['tiny'],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    itemCount: images.length,
                  ),
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchImageAPI() async {
    if (isLoading) {
      return; // Avoid making multiple simultaneous requests
    }

    final query = searchController.text.isNotEmpty
        ? searchController.text
        : 'nature{}'; // Use a default query when the search field is empty

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/v1/search?query=$query&page=$currentPage&per_page=$perPage'),
      headers: {
        'Authorization':
            'GVk5cvfAdb2ymbJ3dHffxLTq7RwHEszqMAKBDT5VTOFDZ0tsY0B23nTy'
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        if (currentPage == 1) {
          images.clear(); // Clear existing images only on the first page
        }
        images.addAll(result['photos']);
        currentPage++; // Increment the page for pagination
      });
    } else {
      print('API request failed with status code: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> searchImages(String query)async {
    setState(() {
      images.clear(); // Clear existing images
      currentPage = 1; // Reset current page when a new search query is entered
       fetchImageAPI(); // Fetch new images based on the search query
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // Reached the bottom of the list, load more images
      fetchImageAPI();
    }
  }
}


