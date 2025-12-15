import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewScreen extends StatelessWidget {
  final Review review;

  const ReviewScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FlickReview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.profileImage),
                  radius: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text("${review.rating}/10"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(review.fullReview, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
