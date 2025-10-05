import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutcom/viewmodels/cart_viewmodel.dart';
import 'package:flutcom/viewmodels/products_viewmodel.dart';
import 'package:flutcom/repositories/product_repository.dart';
import 'package:flutcom/models/product.dart';

class MyHomePage extends StatefulWidget {
  final ProductRepository? repo;

  const MyHomePage({Key? key, this.repo}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// --- Tests ---
void main() {
  group('MyHomePage Widget (in-file) Tests', () {
    late CartViewModel cartViewModel;
    late ProductsViewModel productsViewModel;

    setUp(() {
      cartViewModel = CartViewModel();
      productsViewModel = ProductsViewModel();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<CartViewModel>.value(value: cartViewModel),
          ChangeNotifierProvider<ProductsViewModel>.value(
              value: productsViewModel),
        ],
        child: MaterialApp(
          home: const MyHomePage(),
          routes: {
            '/catalog': (context) => const Scaffold(
                  body: Text('Catalog Page'),
                ),
            '/products': (context) => const Scaffold(
                  body: Text('Products Page'),
                ),
            '/cart': (context) => const Scaffold(
                  body: Text('Cart Page'),
                ),
            '/orders': (context) => const Scaffold(
                  body: Text('Orders Page'),
                ),
          },
        ),
      );
    }

    testWidgets('shows app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('ShopFlutter'), findsOneWidget);
    });

    testWidgets('tapping search navigates to catalog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final searchInkWell = find.byKey(const Key('home_search_inkwell'));
      await tester.tap(searchInkWell);
      await tester.pumpAndSettle();

      expect(find.text('Catalog Page'), findsOneWidget);
    });
  });
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Charger les produits via le ViewModel existant
    final productsViewModel =
        Provider.of<ProductsViewModel>(context, listen: false);
    productsViewModel.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    final productsViewModel = Provider.of<ProductsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopFlutter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              child: Text("Menu"),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildCategories(context),
            const SizedBox(height: 24),
            _buildFeatured(productsViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: const [
        Icon(Icons.storefront, size: 32),
        SizedBox(width: 8),
        Text(
          'Bienvenue 👋',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return InkWell(
      key: const Key('home_search_inkwell'),
      onTap: () => Navigator.pushNamed(context, '/catalog'),
      child: IgnorePointer(
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _quickAction(context, Icons.list_alt, 'Catalogue',
            () => Navigator.pushNamed(context, '/catalog')),
        _quickAction(context, Icons.shopping_bag, 'Produits',
            () => Navigator.pushNamed(context, '/products')),
        _quickAction(context, Icons.shopping_cart, 'Panier',
            () => Navigator.pushNamed(context, '/cart')),
        _quickAction(context, Icons.receipt_long, 'Commandes',
            () => Navigator.pushNamed(context, '/orders')),
      ],
    );
  }

  Widget _quickAction(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      "men's clothing",
      'jewelery',
      'electronics',
      "women's clothing",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: categories
              .map((cat) => ActionChip(
                    label: Text(cat),
                    onPressed: () => Navigator.pushNamed(context, '/catalog'),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFeatured(ProductsViewModel productsViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À la une',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (productsViewModel.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (productsViewModel.products.isEmpty)
          const Center(child: Text('Aucun produit'))
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: productsViewModel.products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = productsViewModel.products[index];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(product.image, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
