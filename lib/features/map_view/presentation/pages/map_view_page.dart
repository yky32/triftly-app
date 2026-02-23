import 'package:flutter/material.dart';

class MapViewPage extends StatelessWidget {
  const MapViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F4F8),
                  Color(0xFFD4E8F0),
                  Color(0xFFC4E0EC),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Simulated map roads
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height),
                  painter: MapRoadsPainter(),
                ),
                // Location pins
                const Positioned(
                  top: 180,
                  left: 120,
                  child: _LocationPin(
                    color: Color(0xFF8B5CF6),
                    hasAvatar: true,
                    avatarUrl:
                        'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80',
                  ),
                ),
                const Positioned(
                  top: 220,
                  right: 100,
                  child: _LocationPin(
                    color: Color(0xFF06B6D4),
                    hasAvatar: true,
                    avatarUrl:
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80',
                  ),
                ),
                const Positioned(
                  top: 300,
                  left: 180,
                  child: _LocationPin(
                    color: Color(0xFF10B981),
                    hasAvatar: true,
                    avatarUrl:
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80',
                  ),
                ),
                const Positioned(
                  top: 250,
                  right: 180,
                  child: _LocationPin(
                    color: Color(0xFFF59E0B),
                    hasAvatar: false,
                  ),
                ),
                const Positioned(
                  top: 350,
                  left: 100,
                  child: _LocationPin(
                    color: Color(0xFFEF4444),
                    hasAvatar: false,
                  ),
                ),
              ],
            ),
          ),
          // Top controls
          Positioned(
            top: 60,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.my_location,
                      color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
          // ListView toggle button
          Positioned(
            top: 400,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'ListView',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Property card at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Property image
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Agent info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80'),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sierra Augustine',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Sales Manager | M&H Builders',
                              style: TextStyle(
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
                  // Property details
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Areas of operation',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Bangalore, Mumbai, Chennai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '20+',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          Text(
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
                  const SizedBox(height: 8),
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  final Color color;
  final bool hasAvatar;
  final String? avatarUrl;

  const _LocationPin({
    required this.color,
    required this.hasAvatar,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasAvatar && avatarUrl != null
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.home,
              color: color,
              size: 20,
            ),
    );
  }
}

class MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw some roads
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.6, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
