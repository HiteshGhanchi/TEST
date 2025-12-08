import 'package:flutter/material.dart';

final Color _primaryGreen = Colors.green.shade700;
final Color _userBubbleColor = Colors.orange.shade600;

class AdvisoryChatScreen extends StatelessWidget {
  const AdvisoryChatScreen({super.key});

  final List<Map<String, dynamic>> _messages = const [
    {'sender': 'bot', 'text': 'Hello! How can I assist you with your farm today?'},
    {'sender': 'user', 'text': 'What are the current mandi prices for soybeans in my area?'},
    {'sender': 'bot', 'text': 'Fetching prices', 'isThinking': true},
    // Placeholder for Mandi Price result
    {'sender': 'bot', 'text': 'The average Mandi price for Soybeans (October 2024) in your region is ₹4,850/Quintal. This is based on real-time e-NAM data.'},
  ];

  Widget _buildChatBubble(BuildContext context, Map<String, dynamic> message) {
    final bool isBot = message['sender'] == 'bot';
    final Color bubbleColor = isBot ? Colors.grey.shade200 : _userBubbleColor;
    final Color textColor = isBot ? Colors.black87 : Colors.white;
    
    // FIXED: Use dynamic width (75% of screen width) to prevent overflow
    final double maxWidth = MediaQuery.of(context).size.width * 0.75; 

    // Check for thinking state
    if (message['isThinking'] == true) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16).copyWith(
            topLeft: isBot ? Radius.zero : const Radius.circular(16),
            topRight: isBot ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message['text'] as String, style: TextStyle(color: textColor, fontStyle: FontStyle.italic)),
            const SizedBox(width: 8),
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16).copyWith(
          topLeft: isBot ? Radius.zero : const Radius.circular(16),
          topRight: isBot ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Text(
        message['text'] as String,
        style: TextStyle(color: textColor),
      ),
    );
  }
  
  Widget _buildQuickActionChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: TextStyle(color: Colors.grey.shade800)),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Advisory Chat', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Chat Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isBot = message['sender'] == 'bot';
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    if (isBot) 
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.android, size: 24, color: Colors.white), 
                      ),
                    const SizedBox(width: 8),
                    // Bubble is now properly constrained by _buildChatBubble
                    _buildChatBubble(context, message),
                    const SizedBox(width: 8),
                    if (!isBot) 
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 24, color: Colors.white),
                      ),
                  ],
                );
              },
            ),
          ),
          
          // Quick Action Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildQuickActionChip('Latest Wheat Prices'),
                _buildQuickActionChip('Weather Forecast'),
                _buildQuickActionChip('Pest Control Tips'),
                _buildQuickActionChip('Irrigation Advice'),
              ],
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 8.0, top: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryGreen.withAlpha(25),
                  ),
                  child: Icon(Icons.mic_none, color: _primaryGreen, size: 28),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}