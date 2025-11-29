import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/background_image_wrapper.dart';

class PipprCoinProduct {
  final String amountStr;
  final String productId;
  final double price;
  int get amount => int.tryParse(amountStr) ?? 0;
  const PipprCoinProduct(this.amountStr, this.productId, this.price);
}


class PipprCoinProducts {
  static const List<PipprCoinProduct> all = [
    PipprCoinProduct('32', 'Pippr', 0.99),
    PipprCoinProduct('60', 'Pippr1', 1.99),
    PipprCoinProduct('96', 'Pippr2', 2.99),
    PipprCoinProduct('155', 'Pippr4', 4.99),
    PipprCoinProduct('189', 'Pippr5', 5.99),
    PipprCoinProduct('359', 'Pippr9', 9.99),
    PipprCoinProduct('729', 'Pippr19', 19.99),
    PipprCoinProduct('1346', 'Pippr39', 39.99),
    PipprCoinProduct('1869', 'Pippr49', 49.99),
    PipprCoinProduct('3799', 'Pippr99', 99.90),
  ];
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _purchasePending = false;
  int _coins = 0;
  final Set<String> _processedPurchases = {}; // Track processed purchases
  bool _isInitialized = false; // Flag for initialization status
  int _selectedProductIndex = 0; // Track selected product index

  List<PipprCoinProduct> get _coinProducts => PipprCoinProducts.all;

  @override
  void initState() {
    super.initState();
    
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Error in IAP Stream: $error");
    });
    _loadCoins();
    _initInAppPurchase();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    // Support both old and new keys for backward compatibility
    int coins = prefs.getInt('pipprCoins') ?? 
                prefs.getInt('pipprCoins') ?? 
                prefs.getInt('pipprDiamonds') ?? 0;
    debugPrint('Loading Pippr coins: $coins');
      setState(() {
        _coins = coins;
        // Set initialization flag if not already set
        if (!_isInitialized) {
          _isInitialized = true;
          debugPrint('Initialized from _loadCoins');
        }
      });
      // Migrate old keys to new key if exists
      if (prefs.getInt('pipprCoins') != null || prefs.getInt('pipprDiamonds') != null) {
        await prefs.setInt('pipprCoins', coins);
      }
  }

  Future<void> _saveCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Saving Pippr coins: current=$_coins, adding=$amount, new=${_coins + amount}');
    debugPrint('Call stack: ${StackTrace.current}');
    setState(() {
      _coins += amount;
    });
    await prefs.setInt('pipprCoins', _coins);
    // Also update old key for backward compatibility
    await prefs.setInt('pipprCoins', _coins);
  }

  Future<void> _initInAppPurchase() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    debugPrint('Store availability: $isAvailable');
    
    if (!isAvailable) {
      setState(() {
        _isLoading = false;
        _isInitialized = true; // Mark as initialized even on error
      });
      return;
    }
    
    final Set<String> productIds = _coinProducts.map((e) => e.productId).toSet();
    debugPrint('Querying products: $productIds');
    
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      debugPrint('Found ${response.productDetails.length} products');
      debugPrint('Product IDs: ${response.productDetails.map((p) => p.id).toList()}');
      
      setState(() {
        _products = response.productDetails;
        _isLoading = false;
        _isInitialized = true; // Mark initialization complete
      });
      debugPrint('InAppPurchase initialized successfully');
      
      if (response.productDetails.isEmpty) {
        // _showSnackBar("No products available");
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() {
        _isLoading = false;
        _isInitialized = true; // Mark as initialized even on error
      });
      _showSnackBar("Failed to load products: $e");
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    // Ignore purchase updates during initialization
    if (!_isInitialized) {
      debugPrint('Ignoring purchase updates during initialization');
      return;
    }
    
    for (var purchaseDetails in purchaseDetailsList) {
      debugPrint('Purchase status: ${purchaseDetails.status} for product: ${purchaseDetails.productID}');
      
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
          // Handle new purchases and restored purchases
          _handleSuccessfulPurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          setState(() {
            _purchasePending = false;
          });
        }
        // completePurchase is now handled in _handleSuccessfulPurchase
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    // Check if purchase has already been processed
    String purchaseKey = '${purchaseDetails.productID}_${purchaseDetails.purchaseID}_${purchaseDetails.status}';
    if (_processedPurchases.contains(purchaseKey)) {
      debugPrint('Purchase already processed: $purchaseKey');
      return;
    }
    
    // Add to processed list
    _processedPurchases.add(purchaseKey);
    
    debugPrint('Handling successful purchase: ${purchaseDetails.productID} (${purchaseDetails.status})');
    debugPrint('Available product IDs: ${_coinProducts.map((p) => p.productId).toList()}');
    
    setState(() {
      _purchasePending = false;
    });
    
    final product = _coinProducts.firstWhere(
      (e) => e.productId == purchaseDetails.productID, 
      orElse: () {
        debugPrint('Product not found in configuration: ${purchaseDetails.productID}');
        return PipprCoinProduct('', '', 0);
      }
    );
    
    if (product.amount > 0) {
      debugPrint('Processing purchase: ${product.amount} coins for product ${purchaseDetails.productID}');
      await _saveCoins(product.amount);
      _showSnackBar("Purchase successful! +${product.amount} Coins");
    } else {
      debugPrint('Product amount is 0 or product not found: ${purchaseDetails.productID}');
    }
    
    // Always complete the purchase
    debugPrint('Completing purchase: ${purchaseDetails.productID}');
    await _inAppPurchase.completePurchase(purchaseDetails);
  }

  void _showSnackBar(String msg) {
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

  Future<void> _processPurchase(String productId) async {
    debugPrint('Attempting to purchase product: $productId');
    debugPrint('Available products: ${_products.map((p) => p.id).toList()}');
    
    ProductDetails? product;
    try {
      product = _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      product = null;
    }
    if (product == null) {
      debugPrint('Product not found: $productId');
      _showSnackBar("Product not available");
      return;
    }
    
    debugPrint('Product found: ${product.id} - ${product.title} - ${product.price}');
    
    setState(() {
      _purchasePending = true;
    });
    
    try {
      // Add a short delay to ensure the system is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      debugPrint('Starting purchase for: ${product.id}');
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      debugPrint('Purchase initiated successfully');
    } catch (e) {
      debugPrint('Error starting purchase: $e');
      setState(() {
        _purchasePending = false;
      });
      _showSnackBar("Error starting purchase: $e");
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
                      
                      // Wallet balance card
                      _buildWalletBalanceCard(),
                      const SizedBox(height: 30),
                      
                      // Select top-up amount title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          'Select Top-up Amount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Product grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildProductGrid(),
                      ),
                      const SizedBox(height: 30),
                      
                      // Recharge button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildRechargeButton(),
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
            'Wallet',
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

  Widget _buildWalletBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coins',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Coin icon
            SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                'assets/pippr_pay_gold.webp',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Column(
      children: _coinProducts.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        ProductDetails? product;
        try {
          product = _products.firstWhere((p) => p.id == item.productId);
        } catch (e) {
          product = null;
        }
        final priceStr = product != null 
            ? product.price.replaceAll('US\$', '\$')
            : '\$${item.price.toStringAsFixed(2)}';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildProductCard(item, priceStr, index == _selectedProductIndex),
        );
      }).toList(),
    );
  }

  Widget _buildProductCard(PipprCoinProduct item, String priceStr, bool isSelected) {
    return GestureDetector(
      onTap: _purchasePending ? null : () {
        // Toggle selected state
        setState(() {
          _selectedProductIndex = _coinProducts.indexOf(item);
        });
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.primaryColor.withOpacity(0.3), 
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left diamond icon
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/pippr_pay_gold.webp',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        size: 28,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Center coin amount info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        '${item.amount} Coins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: isSelected ? FontStyle.italic : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Premium Currency',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Right price button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priceStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Selected indicator
              if (isSelected) ...[
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRechargeButton() {
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
          onTap: _purchasePending ? null : () {
            // Purchase the selected product
            if (_selectedProductIndex < _coinProducts.length) {
              final selectedProduct = _coinProducts[_selectedProductIndex];
              _processPurchase(selectedProduct.productId);
            }
          },
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
                    'Recharge Now',
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
}
