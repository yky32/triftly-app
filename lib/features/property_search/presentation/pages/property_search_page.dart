import 'package:flutter/material.dart';

class PropertySearchPage extends StatelessWidget {
  const PropertySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Purple header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
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
              children: [
                // Top bar with back arrow, search, and filter
                Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Bangalore, IN',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter tags
                Row(
                  children: [
                    _buildFilterTag('Villa', true),
                    const SizedBox(width: 12),
                    _buildFilterTag('English', false),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // First property card
                _buildPropertyCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400',
                  agentName: 'Sierra Augustine',
                  agentRole: 'Sales Manager | M&H Builders',
                  agentImage:
                      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80',
                  areas: 'Bangalore, Mumbai, Chennai',
                  propertyCount: '20+',
                ),
                const SizedBox(height: 20),
                // Second property card
                _buildPropertyCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
                  agentName: 'Christopher Patt',
                  agentRole: 'Sales Manager | M&H Builders',
                  agentImage:
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80',
                  areas: 'Bangalore, Mumbai, Chennai',
                  propertyCount: '20+',
                ),
                const SizedBox(height: 20),
                // Map View button
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Map View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6B46C1) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.close,
              size: 16,
              color: const Color(0xFF6B46C1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyCard({
    required String imageUrl,
    required String agentName,
    required String agentRole,
    required String agentImage,
    required String areas,
    required String propertyCount,
  }) {
    return Container(
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
          // Property image
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Agent info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(agentImage),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            agentRole,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.message,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF8B5CF6),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Areas of operation',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            areas,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          propertyCount,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        const Text(
                          'Property\nlisted',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
