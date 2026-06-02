import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController buyerController = TextEditingController();
  final Map<int, int> _cart = {};
  List _cachedTickets = [];

  // ==========================================
  // PERUBAHAN TAHAP 1: Kunci API & Palet Warna Baru
  // ==========================================
  late Future<List<dynamic>> _futureTickets;

  final Color primaryBlue = const Color(0xFF0F172A); // Slate Ultra Dark
  final Color accentBlue = const Color(0xFF2563EB);  // Royal Blue Modern
  final Color bgGray = const Color(0xFFF8FAFC);      // Off-white bersih
  final Color surfaceWhite = Colors.white;
  final Color textDark = const Color(0xFF0F172A);
  final Color textMuted = const Color(0xFF64748B);   // Warna teks sekunder

  @override
  void initState() {
    super.initState();
    // Memicu API hanya 1 kali saat halaman pertama kali dibuka
    _futureTickets = ApiService.getTickets().then((value) => value as List<dynamic>);
  }
  // ==========================================

  int _calculateTotal() {
    int total = 0;
    _cart.forEach((id, qty) {
      var ticket = _cachedTickets.firstWhere((t) => t['id'] == id, orElse: () => null);
      if (ticket != null) total += (ticket['price'] as int) * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    int totalBayar = _calculateTotal();

    return Scaffold(
      backgroundColor: bgGray,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Informasi Pembeli", Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildBuyerInput(),
                      const SizedBox(height: 32),
                      _buildSectionHeader("Katalog Tiket", Icons.confirmation_number_outlined),
                      const SizedBox(height: 16),
                      _buildTicketList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (totalBayar > 0) _buildAnimatedFloatingBar(totalBayar),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140.0,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Pesan Tiket",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5, color: Colors.white,),
        ),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryBlue, accentBlue],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -20,
              child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
        ),
      ],
    );
  }

  Widget _buildBuyerInput() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: TextField(
        controller: buyerController,
        style: TextStyle(color: textDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Nama lengkap sesuai identitas",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.badge_outlined, color: primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    return FutureBuilder(
      future: ApiService.getTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.only(top: 50),
            child: CircularProgressIndicator(),
          ));
        }
        if (!snapshot.hasData) return const Center(child: Text("Gagal memuat tiket"));
        
        _cachedTickets = snapshot.data as List;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cachedTickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildModernTicketCard(_cachedTickets[index]),
        );
      },
    );
  }

  Widget _buildModernTicketCard(Map t) {
    int id = t['id'];
    int qty = _cart[id] ?? 0;
    bool isSelected = qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? primaryBlue.withOpacity(0.3) : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.confirmation_num, color: primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                const SizedBox(height: 4),
                Text("Rp ${t['price']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
          _buildQtySelector(id, qty),
        ],
      ),
    );
  }

  Widget _buildQtySelector(int id, int qty) {
    return Container(
      decoration: BoxDecoration(color: bgGray, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          _miniBtn(Icons.remove, () => setState(() => _cart[id] = (qty > 0) ? qty - 1 : 0)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              key: ValueKey(qty),
              width: 35, 
              child: Center(child: Text("$qty", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)))
            ),
          ),
          _miniBtn(Icons.add, () => setState(() => _cart[id] = qty + 1)),
        ],
      ),
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback tap) {
    return IconButton(
      onPressed: tap,
      icon: Icon(icon, size: 16, color: primaryBlue),
      splashRadius: 20,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildAnimatedFloatingBar(int total) {
    return Positioned(
      bottom: 20, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: textDark.withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("TOTAL HARGA", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900)),
                Text("Rp $total", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _startPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  void _startPayment() {
    if (buyerController.text.isEmpty) {
      _showSnack("Mohon isi nama lengkap Anda", Colors.orange);
      return;
    }
    _showMainPaymentSheet();
  }

  void _showMainPaymentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Pilih Metode Bayar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _methodTile(Icons.qr_code_scanner_rounded, "QRIS", "All Payment", () => _showQRISDialog()),
            _methodTile(Icons.account_balance_rounded, "Transfer Bank", "BCA, Mandiri, BNI", () => _showBankSubSheet()),
            _methodTile(Icons.account_balance_wallet_rounded, "E-Wallet", "Dana, OVO, LinkAja", () => _showWalletSubSheet()),
          ],
        ),
      ),
    );
  }

  void _showBankSubSheet() {
    Navigator.pop(context);
    _showSubSheet("Pilih Bank", [
      {"n": "BCA", "d": "Bank Central Asia", "i": Icons.account_balance},
      {"n": "Mandiri", "d": "Bank Mandiri", "i": Icons.account_balance},
      {"n": "BNI", "d": "Bank Negara Indonesia", "i": Icons.account_balance},
      {"n": "BRI", "d": "Bank Rakyat Indonesia", "i": Icons.account_balance},
    ]);
  }

  void _showWalletSubSheet() {
    Navigator.pop(context);
    _showSubSheet("Pilih E-Wallet", [
      {"n": "Dana", "d": "Dompet Digital DANA", "i": Icons.smartphone_rounded},
      {"n": "OVO", "d": "OVO Cash", "i": Icons.smartphone_rounded},
      {"n": "ShopeePay", "d": "ShopeePay Indonesia", "i": Icons.smartphone_rounded},
      {"n": "LinkAja", "d": "LinkAja Digital", "i": Icons.smartphone_rounded},
    ]);
  }

  void _showSubSheet(String title, List items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () { Navigator.pop(context); _showMainPaymentSheet(); },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map((i) => _subMethodTile(i['n'], i['d'], i['i'])).toList(),
          ],
        ),
      ),
    );
  }

  void _showQRISDialog() {
    Navigator.pop(context);
    int total = _calculateTotal();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Scan to Pay", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 10),
            Text("Rp $total", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgGray, borderRadius: BorderRadius.circular(20)),
              child: Image.network("https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=POOLTICK-$total"),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); _executePayment("QRIS"); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 15)
                ),
                child: const Text("SAYA SUDAH BAYAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodTile(IconData icon, String title, String sub, VoidCallback tap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgGray, borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: primaryBlue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: tap,
    );
  }

  Widget _subMethodTile(String name, String detail, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: primaryBlue, size: 22),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(detail, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () { Navigator.pop(context); _executePayment(name); },
    );
  }

  Future<void> _executePayment(String method) async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => Center(child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: const CircularProgressIndicator(),
      ))
    );

    bool allOk = true;
    for (var id in _cart.keys) {
      int qty = _cart[id]!;
      for (int i = 0; i < qty; i++) {
        bool res = await ApiService.beliTiket(id, buyerController.text);
        if (!res) allOk = false;
      }
    }

    Navigator.pop(context);
    if (allOk) {
      _showSnack("Tiket berhasil dipesan via $method!", Colors.green);
      setState(() => _cart.clear());
      buyerController.clear();
    } else {
      _showSnack("Beberapa tiket gagal dipesan.", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(20),
    ));
  }
}