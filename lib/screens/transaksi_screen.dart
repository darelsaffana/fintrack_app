import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';

// Tab "Transaksi": daftar semua transaksi user (bisa difilter semua/pemasukan/
// pengeluaran), plus tombol tambah yang buka form _TransactionForm di bawah.
class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  String _filter = 'all'; // filter aktif: 'all' / 'income' / 'expense'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    // Ambil transaksi sesuai filter, lalu urutkan dari yang tanggalnya paling baru.
    final list = provider.transactions.where((t) => _filter == 'all' || t.type == _filter).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      // Padding halaman luar disamakan agar layout lapang dan konsisten
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Judul halaman disandingkan dengan tombol aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi',
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton.filled(
                onPressed: () => _openForm(context), // Logika asli dipertahankan
                icon: Icon(Icons.add_rounded, size: 26, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent(context),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Container Tab Filter berbentuk pil menyatu (segmented control) yang elegan
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBorder(context).withOpacity(0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    label: 'Semua', 
                    selected: _filter == 'all', 
                    onTap: () => setState(() => _filter = 'all'), // Logika asli dipertahankan[cite: 4]
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _FilterChip(
                    label: 'Pemasukan', 
                    selected: _filter == 'income', 
                    onTap: () => setState(() => _filter == 'income' ? null : _filter = 'income'), // Logika asli dipertahankan[cite: 4]
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _FilterChip(
                    label: 'Pengeluaran', 
                    selected: _filter == 'expense', 
                    onTap: () => setState(() => _filter == 'expense' ? null : _filter = 'expense'), // Logika asli dipertahankan[cite: 4]
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: list.isEmpty
                ? const EmptyState(message: 'Tidak ada transaksi untuk ditampilkan.') // Logika asli dipertahankan[cite: 4]
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(24), // Sudut melengkung 24 agar senada
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: list.length, // Logika asli dipertahankan[cite: 4]
                      itemBuilder: (context, i) => TransactionTile(
                        transaction: list[i], // Logika asli dipertahankan[cite: 4]
                        onEdit: () => _openForm(context, existing: list[i]), // Logika asli dipertahankan[cite: 4]
                        onDelete: () => _confirmDelete(context, list[i]), // Logika asli dipertahankan[cite: 4]
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Konfirmasi dulu sebelum benar-benar hapus transaksi (DELETE /transactions/{id}).
  Future<void> _confirmDelete(BuildContext context, Transaction t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus transaksi?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Transaksi yang dihapus tidak dapat dikembalikan.'),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text('Batal', style: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Hapus', style: TextStyle(color: AppColors.expense(context), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<AppProvider>().deleteTransaction(t.id); // Logika asli dipertahankan[cite: 4]
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(extractErrorMessage(e)))); // Logika asli dipertahankan[cite: 4]
        }
      }
    }
  }

  // Buka bottom sheet form tambah/ubah transaksi. `existing` null = mode
  // tambah, diisi = mode ubah (form terisi otomatis dari data transaksi tsb).
  void _openForm(BuildContext context, {Transaction? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), // Sudut bottomsheet diubah menjadi 28 agar sangat halus
      builder: (_) => _TransactionForm(existing: existing), // Logika asli dipertahankan[cite: 4]
    );
  }
}

// Desain ulang FilterChip dengan visual modern
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent(context).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label, 
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted(context), 
            fontSize: 13, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TransactionForm extends StatefulWidget {
  final Transaction? existing;
  const _TransactionForm({this.existing});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type; // 'income' atau 'expense'
  int? _categoryId;
  final _amount = TextEditingController();
  final _description = TextEditingController();
  late DateTime _date;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Mode ubah -> isi form dari data transaksi yang ada.
    // Mode tambah -> default expense, hari ini, field lain kosong.
    final e = widget.existing;
    _type = e?.type ?? 'expense';
    _categoryId = e?.categoryId;
    _amount.text = e != null ? e.amount.toStringAsFixed(0) : '';
    _description.text = e?.description ?? '';
    _date = e?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    // Dropdown kategori cuma nampilin kategori sesuai tipe yang lagi dipilih
    // (income/expense) — kategori pemasukan gak nyampur sama pengeluaran.
    final cats = _type == 'income' ? provider.incomeCategories : provider.expenseCategories;
    // Kalau kategori yang lagi kepilih ternyata gak ada di daftar tipe yang
    // aktif sekarang (misal abis ganti tipe income->expense), reset ke
    // kategori pertama yang tersedia biar gak nyangkut di ID yang gak valid.
    if (_categoryId == null || !cats.any((c) => c.id == _categoryId)) {
      _categoryId = cats.isNotEmpty ? cats.first.id : null;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis handle bottomsheet minimalis ala aplikasi modern
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.existing == null ? 'Tambah Transaksi' : 'Ubah Transaksi', // Logika asli dipertahankan[cite: 4]
                style: TextStyle(color: AppColors.text(context), fontSize: 18, fontWeight: FontWeight.w800), // Diganti w800 agar konsisten dengan perbaikan error sebelumnya
              ),
              const SizedBox(height: 20),
              
              _typeToggle(),
              const SizedBox(height: 18),
              
              // Kustomisasi dropdown agar bergaya modern
              DropdownButtonFormField<int>(
                value: _categoryId, // Logika asli dipertahankan[cite: 4]
                dropdownColor: AppColors.card(context),
                style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [for (final c in cats) DropdownMenuItem(value: c.id, child: Text(c.name))], // Logika asli dipertahankan[cite: 4]
                onChanged: (v) => setState(() => _categoryId = v), // Logika asli dipertahankan[cite: 4]
              ),
              const SizedBox(height: 16),
              
              // Kustomisasi input Jumlah (Rp)
              TextFormField(
                controller: _amount, // Logika asli dipertahankan[cite: 4]
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  labelStyle: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w500),
                  floatingLabelStyle: TextStyle(color: AppColors.accent(context), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.accent(context), width: 1.5),
                  ),
                ),
                validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Masukkan jumlah yang valid' : null, // Logika asli dipertahankan[cite: 4]
              ),
              const SizedBox(height: 16),
              
              // Kustomisasi pemilih Tanggal
              InkWell(
                onTap: _pickDate, // Logika asli dipertahankan[cite: 4]
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    labelStyle: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w500),
                    filled: true,
                    fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_date.day}/${_date.month}/${_date.year}', // Logika asli dipertahankan[cite: 4]
                        style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.muted(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Kustomisasi input Deskripsi
              TextFormField(
                controller: _description, // Logika asli dipertahankan[cite: 4]
                style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  labelStyle: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w500),
                  floatingLabelStyle: TextStyle(color: AppColors.accent(context), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.accent(context), width: 1.5),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: AppColors.expense(context), fontSize: 13, fontWeight: FontWeight.bold)), // Logika asli dipertahankan[cite: 4]
              ],
              const SizedBox(height: 24),
              
              // Baris tombol aksi bawah
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: AppColors.muted(context),
                        side: BorderSide(color: AppColors.cardBorder(context)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit, // Logika asli dipertahankan[cite: 4]
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent(context),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving // Logika asli dipertahankan[cite: 4]
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tipe Toggle (Pemasukan / Pengeluaran) yang dimodernisasi
  Widget _typeToggle() {
    Widget option(String value, String label, Color color) {
      final selected = _type == value;
      return Expanded(
        child: InkWell(
          // Ganti tipe -> _categoryId di-reset ke null, biar dropdown kategori
          // di atas ke-refresh (lihat pengecekan cats.any(...) di build()).
          onTap: () => setState(() { _type = value; _categoryId = null; }),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label, 
              style: TextStyle(
                color: selected ? color : AppColors.muted(context), 
                fontWeight: FontWeight.bold, 
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBorder(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14), 
        border: Border.all(color: AppColors.cardBorder(context).withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        option('income', 'Pemasukan', AppColors.income(context)), 
        const SizedBox(width: 6),
        option('expense', 'Pengeluaran', AppColors.expense(context)),
      ]),
    );
  }

Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, 
      initialDate: _date, 
      firstDate: DateTime(2020), 
      lastDate: DateTime(2100),
      // Styling DatePicker bawaan agar membulat modern
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Diubah dari DialogTheme menjadi DialogThemeData
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked); // Logika asli dipertahankan
  }

  // Dipanggil saat tombol "Simpan" ditekan -> addTransaction (POST) atau
  // editTransaction (PUT) tergantung mode tambah/ubah, lalu tutup bottom sheet.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final provider = context.read<AppProvider>();
      final amount = double.parse(_amount.text);
      if (widget.existing == null) {
        await provider.addTransaction(categoryId: _categoryId, type: _type, amount: amount, date: _date, description: _description.text.trim());
      } else {
        await provider.editTransaction(widget.existing!.id, categoryId: _categoryId, type: _type, amount: amount, date: _date, description: _description.text.trim());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}