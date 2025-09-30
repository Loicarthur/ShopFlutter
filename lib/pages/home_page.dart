import 'package:flutter/material.dart';
import '../widgets/drawer.dart';
import '../widgets/cart_icon_button.dart';
import '../repositories/product_repository.dart';
import '../models/product.dart';
import '../pages/product_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ProductRepository _repo = ProductRepository();
  late Future<List<Product>> _featuredFuture;

  @override
  void initState() {
    super.initState();
    _featuredFuture = _repo.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopFlutter'),
        actions: const [CartIconButton()],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            _buildCategoriesSection(context),
            const SizedBox(height: 16),
            _buildFeaturedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: const [
        Icon(Icons.storefront, size: 32, color: Colors.blue),
        SizedBox(width: 8),
        Text('Bienvenue 👋',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/catalog'),
      child: IgnorePointer(
        ignoring: true,
        child: TextField(
          decoration: InputDecoration(
            hintText:
                'Rechercher des produits... (taper pour ouvrir le catalogue)',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickAction(
          icon: Icons.list_alt,
          label: 'Catalogue',
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/catalog'),
        ),
        _QuickAction(
          icon: Icons.shopping_bag,
          label: 'Produits',
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, '/products'),
        ),
        _QuickAction(
          icon: Icons.shopping_cart,
          label: 'Panier',
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, '/cart'),
        ),
        _QuickAction(
          icon: Icons.receipt_long,
          label: 'Commandes',
          color: Colors.indigo,
          onTap: () => Navigator.pushNamed(context, '/orders'),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final categories = const [
      "men's clothing",
      'jewelery',
      'electronics',
      "women's clothing",
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catégories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(c),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/catalog'),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('À la une',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<Product>>(
            future: _featuredFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucun produit'));
              }
              final products = snapshot.data!.take(8).toList();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = products[index];
                  return _FeaturedCard(product: p);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Product product;
  const _FeaturedCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              productId: product.id,
              product: product,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product.image,
                height: 120,
                width: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(product.formattedPrice,
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
