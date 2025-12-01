import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Color _primaryGreen = Colors.green.shade700;
final Color _darkGreen = Colors.green.shade900;

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _tabIndex = 0; // 0 for Land Details, 1 for Bank Account

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: _primaryGreen) : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? _darkGreen : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Land Details Inputs
        const Text(
          'Survey Number',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'e.g., 123/4A')),
        const SizedBox(height: 16),
        const Text(
          'Khasra Number',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(hintText: 'Enter Khasra number'),
        ),
        const SizedBox(height: 16),
        const Text('Village', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(hintText: 'Enter your village name'),
        ),
        const SizedBox(height: 24),

        // Upload/Link Options
        _buildActionButton(
          text: 'Upload Land Record (Patta/ROR)',
          icon: Icons.upload_file,
          color: Colors.orange.shade400,
          backgroundColor: Colors.orange.shade50,
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('- OR -', style: TextStyle(color: Colors.grey)),
          ),
        ),
        _buildActionButton(
          text: 'Link via DigiLocker',
          icon: Icons.fingerprint,
          color: _darkGreen,
          backgroundColor: _primaryGreen.withAlpha(25),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBankAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank Details Inputs
        const Text(
          'Account Holder Name',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(hintText: 'As per your bank passbook'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Account Number',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Enter your bank account number',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        const Text('IFSC Code', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(hintText: 'Enter bank IFSC code'),
        ),
        const SizedBox(height: 24),

        // UPI Link Option
        _buildActionButton(
          text: 'Link UPI ID',
          icon: Icons.payments,
          color: _darkGreen,
          backgroundColor: _primaryGreen.withAlpha(25),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile Setup',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Step 3 of 3', style: TextStyle(color: _primaryGreen)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background effect mimicking the image (blurred field)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              image: DecorationImage(
                image: const NetworkImage(
                  'https://images.unsplash.com/photo-1542282332-1b112310350d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ), // Placeholder for background image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withAlpha(38), BlendMode.dstATop),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Link Land & Bank',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Securely link your farm and bank details for seamless claims and payments.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Tabs Container
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('Land Details', 0),
                      _buildTabButton('Bank Account', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Content
                _tabIndex == 0
                    ? _buildLandDetailsForm()
                    : _buildBankAccountForm(),

                // Security Note
                Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Your information is encrypted and stored securely.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Space for button at the bottom
              ],
            ),
          ),

          // Fixed Bottom Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 24.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Verify & Complete Setup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
