import 'package:flutter/material.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key});

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<CarouselItem> _items = [
    CarouselItem(
      backgroundColor: Colors.blue,
      title: 'Connect With us for more Updates',
      buttonText: 'Connect',
      // Replace with your image path
      backgroundImage: 'assets/images/whatsapp_carousel.png',
    ),
    CarouselItem(
      backgroundColor: Colors.green,
      title: 'Discover Our Latest Features',
      buttonText: 'Learn More',
      // Replace with your image path
      backgroundImage: 'assets/images/whatsapp_carousel.png',
    ),
    CarouselItem(
      backgroundColor: Colors.orange,
      title: 'Join Our Community Today',
      buttonText: 'Sign Up',
      // Replace with your image path
      backgroundImage: 'assets/images/whatsapp_carousel.png',
    ),
    CarouselItem(
      backgroundColor: Colors.purple,
      title: 'Explore Premium Content',
      buttonText: 'Explore',
      // Replace with your image path
      backgroundImage: 'assets/images/whatsapp_carousel.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return CarouselSlide(item: _items[index]);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => buildIndicator(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicator(int index) {
    return Container(
      width: index == _currentPage ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color:
            index == _currentPage ? Colors.blue : Colors.grey.withOpacity(0.5),
      ),
    );
  }
}

class CarouselSlide extends StatelessWidget {
  final CarouselItem item;

  const CarouselSlide({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: item.backgroundColor,
        image: DecorationImage(
          image: AssetImage(item.backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              item.buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarouselItem {
  final Color backgroundColor;
  final String title;
  final String buttonText;
  final String backgroundImage;

  CarouselItem({
    required this.backgroundColor,
    required this.title,
    required this.buttonText,
    required this.backgroundImage,
  });
}
