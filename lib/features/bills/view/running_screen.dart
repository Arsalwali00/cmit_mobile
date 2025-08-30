import 'package:flutter/material.dart';
import 'dart:math' as math;

class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});

  @override
  _RunningScreenState createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  double _distance = 8.5; // Current distance in km
  final double _distanceGoal = 10.0; // Distance goal in km
  double _pace = 5.5; // Average pace in min/km
  int _caloriesBurned = 450; // Calories burned
  final int _caloriesGoal = 600; // Calories goal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: Colors.teal[400]!,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            _distance = 8.5;
            _pace = 5.5;
            _caloriesBurned = 450;
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quick Log",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800]!,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.teal[400]!, size: 24),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Running Metrics",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800]!,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildPaceCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDistanceCard()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCaloriesCard(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Runs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800]!,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]!, size: 24),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Running Dashboard",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.grey[900]!,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.teal[400]!),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPaceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.teal[400]!, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Average Pace",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900]!,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${_pace.toStringAsFixed(1)}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[900]!,
              ),
            ),
          ),
          Text(
            "min/km",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600]!,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: CustomPaint(
              painter: PacePainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard() {
    double distanceProgress = _distance / _distanceGoal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_run, color: Colors.teal[400]!, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Distance",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900]!,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$_distance / ${_distanceGoal}km",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[900]!,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40 * distanceProgress,
                      color: Colors.teal[400]!.withOpacity(0.3),
                      child: CustomPaint(
                        painter: WavePainter(),
                        child: const SizedBox.expand(),
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

  Widget _buildCaloriesCard() {
    double progress = _caloriesBurned / _caloriesGoal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.teal[400]!, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Calories Burned",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900]!,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$_caloriesBurned",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900]!,
                    ),
                  ),
                ),
                Text(
                  "Goal $_caloriesGoal kcal",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600]!,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300]!,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[400]!),
                ),
                Icon(
                  Icons.directions_run,
                  color: Colors.teal[400]!,
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    double width = size.width;
    double height = size.height;
    double segment = width / 10;

    path.moveTo(0, height / 2);
    for (int i = 0; i < 10; i++) {
      double x = i * segment;
      double y = height / 2 - math.sin((x / width) * 2 * math.pi) * (height * 0.3);
      path.lineTo(x + segment, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal[400]!.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    double width = size.width;
    double height = size.height;
    double waveHeight = height * 0.3;
    double waveLength = width / 2;

    path.moveTo(0, height);
    for (double x = 0; x <= width; x += 1) {
      double y = height - waveHeight * (1 + math.sin((x / waveLength) * 2 * math.pi)) / 2;
      path.lineTo(x, y);
    }
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}