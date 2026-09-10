import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../api_service.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await ApiService.fetchItems();
    setState(() {
      _products = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CraftTheme.creamBase,
      appBar: AppBar(
        backgroundColor: CraftTheme.creamBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: CraftTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Items & Orders",
          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: CraftTheme.terracottaPrimary,
          unselectedLabelColor: CraftTheme.mutedText,
          indicatorColor: CraftTheme.terracottaPrimary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Active Catalog (4)"),
            Tab(text: "Incoming Orders (2)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Products
          _buildProductsList(),

          // Tab 2: Orders
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: CraftTheme.terracottaPrimary));
    }

    if (_products.isEmpty) {
      // Fallback sample cards if database empty
      return _buildSampleProductsList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final item = _products[index];
        return _buildItemCard(
          title: item["title"] ?? "Untitled Craft",
          price: "₹${(item["buyer_price"] as num?)?.toInt() ?? 850}",
          status: item["status"] ?? "Published on ONDC",
          category: item["category"] ?? "Textile",
          icon: Icons.checkroom_rounded,
        );
      },
    );
  }

  Widget _buildSampleProductsList() {
    final sampleItems = [
      {"title": "Red Chanderi Silk Saree", "price": "₹1,250", "status": "Live on ONDC", "category": "Textile", "icon": Icons.checkroom_rounded},
      {"title": "Terracotta Painted Water Jug", "price": "₹650", "status": "Live on GeM", "category": "Pottery", "icon": Icons.local_florist_rounded},
      {"title": "Handcrafted Brass Necklace", "price": "₹890", "status": "Live on ONDC", "category": "Jewelry", "icon": Icons.diamond_rounded},
      {"title": "Carved Teakwood Box", "price": "₹1,100", "status": "Draft", "category": "Woodcraft", "icon": Icons.inventory_2_rounded},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sampleItems.length,
      itemBuilder: (context, index) {
        final item = sampleItems[index];
        return _buildItemCard(
          title: item["title"] as String,
          price: item["price"] as String,
          status: item["status"] as String,
          category: item["category"] as String,
          icon: item["icon"] as IconData,
        );
      },
    );
  }

  Widget _buildItemCard({
    required String title,
    required String price,
    required String status,
    required String category,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CraftTheme.terracottaLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: CraftTheme.terracottaPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: CraftTheme.greenLight, borderRadius: BorderRadius.circular(999)),
                      child: Text(status, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.greenTint)),
                    ),
                    const SizedBox(width: 8),
                    Text(category, style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText)),
                  ],
                ),
              ],
            ),
          ),
          Text(price, style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final sampleOrders = [
      {"orderId": "ORD-8821", "title": "Red Chanderi Silk Saree", "buyer": "Anita S. (Jaipur)", "amount": "₹1,250", "status": "Ready to Ship"},
      {"orderId": "ORD-8819", "title": "Terracotta Painted Water Jug", "buyer": "Rajesh K. (Delhi)", "amount": "₹650", "status": "In Transit"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sampleOrders.length,
      itemBuilder: (context, index) {
        final order = sampleOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CraftTheme.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CraftTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order["orderId"]!, style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: CraftTheme.blueLight, borderRadius: BorderRadius.circular(999)),
                    child: Text(order["status"]!, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.blueTint)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(order["title"]!, style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Buyer: ${order["buyer"]!}", style: GoogleFonts.notoSans(fontSize: 13, color: CraftTheme.mutedText)),
                  Text(order["amount"]!, style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
