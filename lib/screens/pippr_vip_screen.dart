import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/background_image_wrapper.dart';

class PipprVipScreen extends StatefulWidget {
  final int initialIndex;
  const PipprVipScreen({super.key, this.initialIndex = 0});

  @override
  State<PipprVipScreen> createState() => _PipprVipScreenState();
}

class _PipprVipScreenState extends State<PipprVipScreen> with TickerProviderStateMixin {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isLoading = false; // Changed to false, don't load on initialization
  bool _purchasePending = false;
  int _selectedIndex = 0;
  bool _isPipprVip = false;
  DateTime? _pipprVipExpiry;
  DateTime? _lastSnackBarTime;
  bool _productsLoaded = false; // Flag to track if products are loaded

  // Subscription product configuration
  final List<_PipprVipPlan> _pipprVipPlans = [
    _PipprVipPlan(
      title: '12.99',
      subTitle: 'Per week',
      total: 'Total \$12.99',
      desc: '+7 Days ',
      productId: 'PipprWeekVIP',
      popular: false,
    ),
    _PipprVipPlan(
      title: '49.99',
      subTitle: 'Per month',
      total: 'Total \$49.99',
      desc: '+30 Days ',
      productId: 'PipprMonthVIP',
      popular: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Error in IAP Stream: $error");
    });
    // Remove automatic IAP initialization, use lazy loading instead
    _loadPipprVipStatus();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Lazy load product information, only load when user needs to purchase
  Future<void> _loadProductsIfNeeded() async {
    if (_productsLoaded) {
      return; // If already loaded, return directly
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Store not available");
      return;
    }
    
    final Set<String> productIds = _pipprVipPlans.map((e) => e.productId).toSet();
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      setState(() {
        _products = response.productDetails;
        _isLoading = false;
        _productsLoaded = true; // Mark as loaded
      });
      
      if (response.productDetails.isEmpty) {
        _showSnackBar("No subscription products available");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Failed to load subscription products: $e");
    }
  }

  Future<void> _loadPipprVipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Support both old and new keys for backward compatibility
    setState(() {
      _isPipprVip = prefs.getBool('pipprIsVip') ?? 
                    prefs.getBool('pipprIsVip') ?? false;
      final expiryStr = prefs.getString('pipprVipExpiry') ?? 
                       prefs.getString('pipprVipExpiry');
      _pipprVipExpiry = expiryStr != null ? DateTime.tryParse(expiryStr) : null;
    });
    // Migrate old keys to new keys if exists
    if (prefs.getBool('pipprIsVip') != null) {
      await prefs.setBool('pipprIsVip', _isPipprVip);
    }
    if (prefs.getString('pipprVipExpiry') != null && _pipprVipExpiry != null) {
      await prefs.setString('pipprVipExpiry', _pipprVipExpiry!.toIso8601String());
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      debugPrint('Purchase status: ${purchaseDetails.status}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _purchasePending = true;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() {
            _purchasePending = false;
          });
          _showSnackBar("Purchase failed: ${purchaseDetails.error?.message ?? 'Unknown error'}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          debugPrint('Successful purchase/restore: ${purchaseDetails.productID}');
          await _handleSuccessfulPurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          setState(() {
            _purchasePending = false;
          });
          _showSnackBar("Purchase was canceled");
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    setState(() {
      _purchasePending = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pipprIsVip', true);
    // Also update old key for backward compatibility
    await prefs.setBool('pipprIsVip', true);
    // Calculate expiry date and VIP type
    DateTime now = DateTime.now();
    DateTime expiry;
    String vipType;
    if (purchaseDetails.productID == 'PipprWeekVIP') {
      expiry = now.add(const Duration(days: 7));
      vipType = 'weekly';
    } else if (purchaseDetails.productID == 'PipprMonthVIP') {
      expiry = now.add(const Duration(days: 30));
      vipType = 'monthly';
    } else {
      expiry = now;
      vipType = 'unknown';
    }
    await prefs.setString('pipprVipExpiry', expiry.toIso8601String());
    await prefs.setString('pipprVipType', vipType);
    // Also update old keys for backward compatibility
    await prefs.setString('pipprVipExpiry', expiry.toIso8601String());
    await prefs.setString('pipprVipType', vipType);
    _showSnackBar("Pippr Premium activated!");
    await _loadPipprVipStatus();
  }

  void _showSnackBar(String msg) {
    final now = DateTime.now();
    if (_lastSnackBarTime != null && now.difference(_lastSnackBarTime!).inSeconds < 3) {
      return;
    }
    _lastSnackBarTime = now;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _processPurchase() async {
    // Ensure products are loaded before purchase
    if (!_productsLoaded) {
      await _loadProductsIfNeeded();
    }
    
    final plan = _pipprVipPlans[_selectedIndex];
    ProductDetails? product;
    try {
      product = _products.firstWhere((p) => p.id == plan.productId);
    } catch (e) {
      product = null;
    }
    if (product == null) {
      _showSnackBar("Product not available");
      return;
    }
    setState(() {
      _purchasePending = true;
    });
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      setState(() {
        _purchasePending = false;
      });
      _showSnackBar("Error starting purchase: $e");
    }
  }

  Future<void> _restorePurchases() async {
    // Ensure products are loaded before restore
    if (!_productsLoaded) {
      await _loadProductsIfNeeded();
    }
    
    setState(() {
      _purchasePending = true;
    });
    
    try {
      debugPrint('Starting restore purchases...');
      await _inAppPurchase.restorePurchases();
      _showSnackBar("Restoring purchases... Please wait.");
      
      // Give some time for the restore process to complete
      await Future.delayed(const Duration(seconds: 2));
      
      // Reload VIP status to check if any purchases were restored
      await _loadPipprVipStatus();
      
      if (_isPipprVip) {
        _showSnackBar("Purchases restored successfully! Pippr Premium activated.");
      } else {
        _showSnackBar("No previous purchases found to restore.");
      }
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      _showSnackBar("Error restoring purchases: $e");
    } finally {
      setState(() {
        _purchasePending = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImageWrapper(
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 3,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom AppBar
                      _buildCustomAppBar(),
                      const SizedBox(height: 30),
                      
                      // VIP status card (if activated)
                      if (_isPipprVip && _pipprVipExpiry != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildPipprVipStatusCard(),
                        ),
                        const SizedBox(height: 30),
                      ],
                      
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          'Choose Your Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Subscription plan cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSubscriptionCards(),
                      ),
                      const SizedBox(height: 30),
                      
                      // VIP benefits title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          'VIP Benefits',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // VIP benefits list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildBenefitsList(),
                      ),
                      const SizedBox(height: 30),
                      
                      // Purchase button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildPurchaseButton(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Restore purchases button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildRestoreButton(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Legal section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildLegalSection(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'VIP Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipprVipStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VIP Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires: ${_pipprVipExpiry!.year}-${_pipprVipExpiry!.month.toString().padLeft(2, '0')}-${_pipprVipExpiry!.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCards() {
    return Column(
      children: _pipprVipPlans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        final isSelected = index == _selectedIndex;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.3),
                          AppTheme.primaryColor.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                border: isSelected 
                    ? Border.all(color: AppTheme.primaryColor, width: 2)
                    : Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? AppTheme.primaryColor.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: isSelected ? 20 : 10,
                    offset: Offset(0, isSelected ? 8 : 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content
                  Row(
                    children: [
                      // Left: Price and duration
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '\$${plan.title}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    plan.subTitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            Text(
                              plan.desc,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Right: Selection indicator and popular tag
                      Column(
                        children: [
                          if (plan.popular)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.white
                                  : AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : AppTheme.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isSelected ? Icons.check : Icons.radio_button_unchecked,
                              color: isSelected 
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
               
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

   Widget _buildBenefitsList() {
    final List<_PipprVipPrivilege> privileges = _selectedIndex == 0 ? [
      _PipprVipPrivilege(icon: Icons.video_library, text: 'Unlimited viewing of talent video'),
      _PipprVipPrivilege(icon: Icons.favorite, text: 'Like the talent video'),
      _PipprVipPrivilege(icon: Icons.block, text: 'Remove advertisements'),
      _PipprVipPrivilege(icon: Icons.edit, text: 'Modify custom data')
    ] : [
      _PipprVipPrivilege(icon: Icons.video_library, text: 'Unlimited viewing of talent video'),
      _PipprVipPrivilege(icon: Icons.favorite, text: 'Like the talent video'),
      _PipprVipPrivilege(icon: Icons.block, text: 'Remove advertisements'),
      _PipprVipPrivilege(icon: Icons.edit, text: 'Modify custom data'),
      _PipprVipPrivilege(icon: Icons.people, text: 'Unlimited matching of talent users'), 
    ];

    return Column(
      children: privileges.map((privilege) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              privilege.icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                privilege.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPurchaseButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF46FB6D),
            Color(0xFF3CFFEF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _purchasePending ? null : _processPurchase,
          child: Center(
            child: _purchasePending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Start VIP',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _purchasePending ? null : _restorePurchases,
          child: Center(
            child: _purchasePending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Restore Purchases',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Column(
      children: [
        // Legal links
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => _launchURL('https://www.apple.com/legal/internet-services/terms/site.html'),
              child: Text(
                'EULA',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _launchURL('https://www.privacypolicies.com/live/5673a379-2ddd-45c4-b61e-7743cbed1a88'),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Cancellation instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How to Cancel Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'To cancel your subscription:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Open Settings on your iPhone/iPad',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                '2. Tap your name at the top',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                '3. Tap "Subscriptions"',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                '4. Find "Pippr Premium" and tap it',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                '5. Tap "Cancel Subscription"',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your subscription will remain active until the end of the current billing period.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PipprVipPlan {
  final String title;
  final String subTitle;
  final String total;
  final String desc;
  final String productId;
  final bool popular;
  const _PipprVipPlan({
    required this.title,
    required this.subTitle,
    required this.total,
    required this.desc,
    required this.productId,
    required this.popular,
  });
}



class _PipprVipPrivilege {
  final IconData icon;
  final String text;
  const _PipprVipPrivilege({required this.icon, required this.text});
}