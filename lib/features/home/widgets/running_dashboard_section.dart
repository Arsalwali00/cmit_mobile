import 'package:flutter/material.dart';

class RunningDashboardSection extends StatelessWidget {
  const RunningDashboardSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Run Reminder Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.teal[50], // Light teal background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal[200]!, width: 1), // Teal border
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_run,
                  color: Colors.teal[400]!, // Teal icon
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Time for your evening run!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900]!,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Scheduled: 6:00 PM",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.close,
                  color: Colors.grey[600]!,
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Pace Tip Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                Icon(
                  Icons.speed,
                  color: Colors.teal[400]!, // Teal icon
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Based on your runs:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900]!,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Try maintaining a 5:30/km pace today",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Weekly Run Streak Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      Icons.fitness_center,
                      color: Colors.teal[400]!, // Teal icon
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "5-day running streak!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayIndicator("M", true),
                    _buildDayIndicator("T", true),
                    _buildDayIndicator("W", true),
                    _buildDayIndicator("T", true),
                    _buildDayIndicator("F", true),
                    _buildDayIndicator("S", false),
                    _buildDayIndicator("S", false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(String day, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.teal[400]! : Colors.grey[300]!, // Teal for completed days
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600]!,
          ),
        ),
      ],
    );
  }
}