import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../api_service.dart';
import '../widgets/responsive_container.dart';
import '../widgets/craft_chip.dart';
import '../widgets/craft_empty_state.dart';
import 'camera_screen.dart';

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
          "My Catalog",
          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: CraftTheme.terracottaPrimary,
          unselectedLabelColor: CraftTheme.mutedText,
          indicatorColor: CraftTheme.terracottaPrimary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: "Catalog (${_products.length})"),
            const Tab(text: "Orders & Enquiries (0)"),
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
      return ResponsiveContainer(
        child: CraftEmptyState(
          icon: Icons.inventory_2_outlined,
          title: "No Products Created Yet",
          subtitle: "Start building your digital catalog with photo capture and voice story.",
          buttonLabel: "CREATE PRODUCT",
          onButtonPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            ).then((_) => _loadItems());
          },
        ),
      );
    }

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final item = _products[index];
            final title = item["title"] ?? "Untitled Craft";
            final price = (item["buyer_price"] as num?)?.toInt() ?? 0;
            final statusStr = item["status"] ?? "Draft";
            final category = item["category"] ?? "Handicraft";

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
                    child: const Icon(Icons.checkroom_rounded, color: CraftTheme.terracottaPrimary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            CraftStatusChip.fromStatus(statusStr),
                            const SizedBox(width: 8),
                            Text(category, style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price > 0 ? "₹$price" : "--",
                    style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ResponsiveContainer(
      child: const CraftEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: "No Orders Received Yet",
        subtitle: "Once your catalog items are approved and exported to partner channels, incoming orders will appear here.",
      ),
    );
  }
}

