import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// =========================
// 1. DỮ LIỆU SẢN PHẨM
// =========================
class Product {
  final String name;
  final double price;
  final String image;

  const Product({
    required this.name,
    required this.price,
    required this.image,
  });
}

const List<Product> products = [
  Product(name: 'Điện thoại 01', price: 1200.0, image: 'lib/assets/DT01.jpg'),
  Product(name: 'Điện thoại 02', price: 2000.0, image: 'lib/assets/DT02.png'),
  Product(name: 'Điện thoại 03', price: 1500.0, image: 'lib/assets/DT03.webp'),
  Product(name: 'Điện thoại 04', price: 602.2, image: 'lib/assets/DT04.jpg'),
  Product(name: 'Điện thoại 05', price: 1800.0, image: 'lib/assets/DT05.jpg'),
  Product(name: 'Điện thoại 06', price: 2200.0, image: 'lib/assets/DT06.webp'),
  Product(name: 'Điện thoại 07', price: 2000.0, image: 'lib/assets/DT02.png'),
];

// =========================
// 2. APP
// =========================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool started = false;
  bool showCart = false;

  // Danh sách sản phẩm đã mua/chọn
  final List<Product> cart = [];

  void openShop() {
    setState(() {
      started = true;
      showCart = false;
    });
  }

  void openCart() {
    setState(() {
      started = true;
      showCart = true;
    });
  }

  void backToShop() {
    setState(() {
      showCart = false;
    });
  }

  void exitAppScreen() {
    setState(() {
      started = false;
      showCart = false;
    });
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cửa hàng điện thoại',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: started
          ? (showCart
              ? CartPage(
                  cart: cart,
                  onBack: backToShop,
                  onRemove: removeFromCart,
                )
              : ShopPage(
                  cart: cart,
                  onOpenCart: openCart,
                  onAddToCart: addToCart,
                  onExit: exitAppScreen,
                  onOpenShop: openShop,
                ))
          : IntroPage(onStart: openShop),
    );
  }
}

// =========================
// 3. MÀN HÌNH GIỚI THIỆU
// =========================
class IntroPage extends StatelessWidget {
  final VoidCallback onStart;

  const IntroPage({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'lib/assets/logo_huit.webp',
                  fit:BoxFit.contain,
                )
              ),
              const SizedBox(height: 30),
              const Text(
                'Cửa hàng điện thoại',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '140 Lê Trọng Tấn, Tân Phú, TP.Hồ Chí Minh',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// 4. TRANG CỬA HÀNG
// =========================
class ShopPage extends StatelessWidget {
  final List<Product> cart;
  final VoidCallback onOpenCart;
  final Function(Product) onAddToCart;
  final VoidCallback onExit;
  final VoidCallback onOpenShop;

  const ShopPage({
    super.key,
    required this.cart,
    required this.onOpenCart,
    required this.onAddToCart,
    required this.onExit,
    required this.onOpenShop,
  });

  void showAddDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text(
            'Bạn muốn thêm ${product.name} vào Giỏ hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                onAddToCart(product);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} đã được thêm vào giỏ hàng'),
                  ),
                );
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng điện thoại'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: onOpenCart,
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),

      // =========================
      // DRAWER
      // =========================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
              UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text('Cửa hàng điện thoại'),
              accountEmail: Text('shop@example.com'),
              currentAccountPicture: CircleAvatar(
                child: Image.asset(
                  'lib/assets/logo_huit.webp',
                  fit:BoxFit.contain,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Cửa hàng'),
              onTap: () {
                Navigator.pop(context);
                onOpenShop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: Text('Giỏ hàng (${cart.length})'),
              onTap: () {
                Navigator.pop(context);
                onOpenCart();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Thoát'),
              onTap: () {
                Navigator.pop(context);
                onExit();
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            child: const Text(
              'Chọn sản phẩm bạn muốn sử dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              product.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('${product.price}'),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () =>
                                showAddDialog(context, product),
                            icon: const Icon(Icons.add_circle),
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sản phẩm được lựa chọn nhiều nhất',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// 5. TRANG GIỎ HÀNG
// =========================
class CartPage extends StatelessWidget {
  final List<Product> cart;
  final VoidCallback onBack;
  final Function(Product) onRemove;

  const CartPage({
    super.key,
    required this.cart,
    required this.onBack,
    required this.onRemove,
  });

  double get total {
    double result = 0;

    for (final product in cart) {
      result += product.price;
    }

    return result;
  }

  void showRemoveDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text(
            'Bạn muốn loại bỏ ${product.name} ra khỏi giỏ hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                onRemove(product);
                Navigator.pop(context);
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  void showPaymentDialog(BuildContext context) {
    if (cart.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Thanh toán'),
            content: const Text(
              'Bạn chưa có sản phẩm nào trong giỏ hàng!!!!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thanh toán'),
          content: Text(
            'Tổng tiền: ${total.toStringAsFixed(1)}\n'
            'Bạn có muốn xác nhận thanh toán không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Thanh toán'),
                      content: const Text(
                        'Bạn đã thanh toán xong giỏ hàng',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        backgroundColor: Colors.amber,
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Giỏ hàng của bạn',
              style: TextStyle(fontSize: 16),
            ),
          ),

          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text(
                      'Bạn chưa có sản phẩm nào vào giỏ hàng!!!!',
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final product = cart[index];

                      return ListTile(
                        leading:Image.asset(product.image),
                        title: Text(product.name),
                        subtitle: Text('${product.price}'),
                        trailing: IconButton(
                          onPressed: () =>
                              showRemoveDialog(context, product),
                          icon: const Icon(Icons.delete),
                        ),
                      );
                    },
                  ),
          ),

          if (cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Tổng tiền: ${total.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () => showPaymentDialog(context),
              child: const Text('Thanh toán'),
            ),
          ),
        ],
      ),
    );
  }
}
