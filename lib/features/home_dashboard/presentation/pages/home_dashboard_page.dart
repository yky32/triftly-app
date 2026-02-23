import 'package:flutter/material.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Purple header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, color: Colors.white, size: 24),
                    Row(
                      children: [
                        const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Greeting
                const Text(
                  'Hello, Kevin Hart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your dream property awaits',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                // Tab navigation
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Buy', true),
                      _buildTab('Rent', false),
                      _buildTab('Agents', false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Search bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Search your dream property',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Featured Properties
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Properties',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'VIEW ALL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFeaturedProperty(
                        imageUrl:
                            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400',
                        price: '₹4,00,00,00',
                        type: 'APARTMENT',
                        title: 'Milano Builders & Promotors',
                        address:
                            '2118 Thornridge Cir. Syracuse, Connecticut 35624.',
                        bedrooms: 3,
                        bathrooms: 3,
                        sqft: 1510,
                      ),
                      const SizedBox(width: 16),
                      _buildFeaturedProperty(
                        imageUrl:
                            'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
                        price: '₹3,50,00,00',
                        type: 'APARTMENT',
                        title: 'Milano Builders & Promotors',
                        address:
                            '2118 Thornridge Cir. Syracuse, Connecticut 35624.',
                        bedrooms: 2,
                        bathrooms: 2,
                        sqft: 1200,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Newly Added Properties
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Newly Added Properties',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'VIEW ALL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNewProperty(
                        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=200',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNewProperty(
                        'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=200',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Home', true),
            _buildBottomNavItem(Icons.search, 'Search', false),
            _buildBottomNavItem(Icons.business, 'Agent', false),
            _buildBottomNavItem(Icons.person, 'Account', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProperty({
    required String imageUrl,
    required String price,
    required String type,
    required String title,
    required String address,
    required int bedrooms,
    required int bathrooms,
    required int sqft,
  }) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'FOR SALE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPropertyFeature(Icons.bed, '$bedrooms Bedroom'),
                    const SizedBox(width: 16),
                    _buildPropertyFeature(
                        Icons.bathtub, '$bathrooms Bathrooms'),
                    const Spacer(),
                    _buildPropertyFeature(Icons.square_foot, '$sqft Sq ft'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNewProperty(String imageUrl) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'FOR SALE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
