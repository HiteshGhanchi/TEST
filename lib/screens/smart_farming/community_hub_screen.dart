import 'package:flutter/material.dart';

final Color _primaryGreen = Colors.green.shade700;

class CommunityHubScreen extends StatelessWidget {
  const CommunityHubScreen({super.key});

  final List<Map<String, dynamic>> _posts = const [
    {
      'name': 'Alice Farmer',
      'time': '2h ago',
      'question': 'Unusual spots on my tomato leaves?',
      'content':
          'Hey everyone, I\'ve noticed these strange yellow spots appearing on the leaves of my tomato plants. Has anyone seen this before or know what it might be? Any advice would be appreciated!',
      'likes': 12,
      'comments': 5,
      'tag': 'Crop Diseases',
      'userIcon': Icons.person,
    },
    {
      'name': 'Bob Gardner',
      'time': '5h ago',
      'question': 'Great prices for corn at the local market today',
      'content':
          'Just a heads up for anyone selling corn, the prices are really good at the downtown farmer\'s market. Managed to sell my whole batch at a great rate.',
      'likes': 38,
      'comments': 11,
      'tag': 'Market Prices',
      'userIcon': Icons.person,
    },
    {
      'name': 'Chloe Planter',
      'time': '1 day ago',
      'question': 'Need recommendations for organic pest control',
      'content':
          'I\'m having trouble with aphids on my kale. Does anyone have any effective and certified organic solutions they\'d recommend? Trying to avoid chemical pesticides completely.',
      'likes': 21,
      'comments': 9,
      'tag': 'Sustainability',
      'userIcon': Icons.person,
    },
  ];

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26), // Updated from withOpacity
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.brown.shade200,
                child: Icon(
                  post['userIcon'] as IconData,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    post['time'] as String,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question/Title
          Text(
            post['question'] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Content
          Text(
            post['content'] as String,
            style: TextStyle(color: Colors.grey.shade700),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Placeholder for the Image in the design
          if (post['tag'] == 'Crop Diseases')
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.image, size: 50, color: Colors.green.shade300),
              ),
            ),
          const SizedBox(height: 12),

          // Actions (Like, Comment, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post['likes']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post['comments']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              Icon(Icons.share, size: 18, color: Colors.grey.shade600),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Community Hub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTagChip('All Posts', true),
                  _buildTagChip('Crop Diseases', false),
                  _buildTagChip('Market Prices', false),
                  _buildTagChip('Sustainability', false),
                  _buildTagChip('Technology', false),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: _posts
                .map((post) => _buildPostCard(context, post))
                .toList(),
          ),
          // Floating Action Button for New Post
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: _primaryGreen,
                shape: const CircleBorder(),
                child: const Icon(Icons.edit, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.white,
        backgroundColor: _primaryGreen.withAlpha(204), // Updated from withOpacity
        labelStyle: TextStyle(
          color: isSelected ? _primaryGreen : Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isSelected
              ? BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
        onSelected: (selected) {
          // Implement tag selection logic
        },
      ),
    );
  }
}
