import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/category.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  String _tab = 'expense'; // Logika asli dipertahankan

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>(); // Logika asli dipertahankan
    final list = provider.categories.where((c) => c.type == _tab).toList(); // Logika asli dipertahankan
    final counts = <int, int>{}; // Logika asli dipertahankan
    for (final t in provider.transactions) {
      if (t.categoryId != null) counts[t.categoryId!] = (counts[t.categoryId!] ?? 0) + 1; // Logika asli dipertahankan
    }

    return Padding(
      // Memberikan padding halaman agar senada dengan halaman dashboard yang luas dan bersih
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row atas: Memisahkan Judul Halaman dan Tombol Tambah agar terlihat premium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategori',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton.filled(
                onPressed: () => _openForm(context), // Logika asli dipertahankan
                icon: const Icon(Icons.add_rounded, size: 26, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Container Tab Selektor yang dibuat modern (seperti pil menyatu)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBorder.withOpacity(0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Tab(
                    label: 'Pengeluaran', 
                    selected: _tab == 'expense', 
                    onTap: () => setState(() => _tab = 'expense'), // Logika asli dipertahankan
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _Tab(
                    label: 'Pemasukan', 
                    selected: _tab == 'income', 
                    onTap: () => setState(() => _tab = 'income'), // Logika asli dipertahankan[cite: 2]
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: list.isEmpty
                ? EmptyState(message: 'Belum ada kategori ${_tab == "income" ? "pemasukan" : "pengeluaran"}.') // Logika asli dipertahankan[cite: 2]
                : GridView.builder(
                    // Mengubah grid agar jaraknya sedikit lebih lapang dan proporsional
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320, 
                      mainAxisExtent: 84, // Ditambah sedikit dari 76 agar ada ruang napas komponen di dalamnya
                      crossAxisSpacing: 14, 
                      mainAxisSpacing: 14,
                    ),
                    itemCount: list.length, // Logika asli dipertahankan[cite: 2]
                    itemBuilder: (context, i) {
                      final c = list[i]; // Logika asli dipertahankan[cite: 2]
                      final categoryColor = hexToColor(c.color);
                      
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24), // Melengkung 24 agar konsisten
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Indikator Warna Kategori dibuat lebih premium (lingkaran berpendar dengan warna senada)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 10, 
                                  height: 10, 
                                  decoration: BoxDecoration(
                                    color: categoryColor, 
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    c.name, // Logika asli dipertahankan[cite: 2]
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis, 
                                    style: const TextStyle(
                                      color: AppColors.text, 
                                      fontWeight: FontWeight.bold, // Lebih tebal dan elegan
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${counts[c.id] ?? 0} transaksi', // Logika asli dipertahankan[cite: 2]
                                    style: const TextStyle(
                                      color: AppColors.mutedDim, 
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Desain ulang tombol aksi edit & hapus agar lebih minimalis dan bersih
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.muted), 
                              onPressed: () => _openForm(context, existing: c), // Logika asli dipertahankan[cite: 2]
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense), // Warna merah pudar untuk tombol hapus agar intuitif
                              onPressed: () => _confirmDelete(context, c), // Logika asli dipertahankan[cite: 2]
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi hapus dibuat melengkung modern
  Future<void> _confirmDelete(BuildContext context, Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus kategori?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('Transaksi yang sudah terkait kategori ini tidak akan ikut terhapus.'),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Batal', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Hapus', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<AppProvider>().deleteCategory(c.id); // Logika asli dipertahankan[cite: 2]
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(extractErrorMessage(e)))); // Logika asli dipertahankan[cite: 2]
      }
    }
  }

  void _openForm(BuildContext context, {Category? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), // Sudut bottomsheet diubah menjadi 28 agar sangat halus
      builder: (_) => _CategoryForm(existing: existing, defaultType: _tab), // Logika asli dipertahankan[cite: 2]
    );
  }
}

// Widget Tab yang didesain ulang menyerupai "Pill/Segmented Control" modern
class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent, // Berpindah ke warna solid accent saat dipilih
          borderRadius: BorderRadius.circular(100),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
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
            color: selected ? Colors.white : AppColors.muted, 
            fontSize: 13, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CategoryForm extends StatefulWidget {
  final Category? existing;
  final String defaultType;
  const _CategoryForm({this.existing, required this.defaultType});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late String _type;
  late Color _color;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.text = widget.existing?.name ?? ''; // Logika asli dipertahankan[cite: 2]
    _type = widget.existing?.type ?? widget.defaultType; // Logika asli dipertahankan[cite: 2]
    _color = widget.existing != null ? hexToColor(widget.existing!.color) : AppColors.categoryPalette.first; // Logika asli dipertahankan[cite: 2]
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis handle kecil di bagian atas BottomSheet ala iOS/aplikasi modern
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.existing == null ? 'Tambah Kategori' : 'Ubah Kategori', // Logika asli dipertahankan[cite: 2]
                style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Selektor tipe (Pemasukan/Pengeluaran) yang dimodernisasi
              Row(children: [
                Expanded(child: _typeOption('income', 'Pemasukan', AppColors.income)),
                const SizedBox(width: 10),
                Expanded(child: _typeOption('expense', 'Pengeluaran', AppColors.expense)),
              ]),
              const SizedBox(height: 18),
              
              TextFormField(
                controller: _name, // Logika asli dipertahankan[cite: 2]
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Nama Kategori',
                  labelStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
                  floatingLabelStyle: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: AppColors.cardBorder.withOpacity(0.15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null, // Logika asli dipertahankan[cite: 2]
              ),
              const SizedBox(height: 18),
              
              const Text('WARNA KATEGORI', style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12, 
                runSpacing: 12,
                children: [
                  for (final c in AppColors.categoryPalette) // Logika asli dipertahankan[cite: 2]
                    InkWell(
                      onTap: () => setState(() => _color = c), // Logika asli dipertahankan[cite: 2]
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32, 
                        height: 32,
                        decoration: BoxDecoration(
                          color: c, 
                          shape: BoxShape.circle,
                          boxShadow: _color.value == c.value 
                              ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                              : null,
                          border: _color.value == c.value 
                              ? Border.all(color: Colors.white, width: 2.5) 
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.expense, fontSize: 13, fontWeight: FontWeight.bold)), // Logika asli dipertahankan[cite: 2]
              ],
              const SizedBox(height: 24),
              
              // Tombol aksi bawah (Batal & Simpan) yang dibuat modern
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: AppColors.muted,
                        side: BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit, // Logika asli dipertahankan[cite: 2]
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving // Logika asli dipertahankan[cite: 2]
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _typeOption(String value, String label, Color color) {
    final selected = _type == value; // Logika asli dipertahankan[cite: 2]
    return InkWell(
      onTap: () => setState(() => _type = value), // Logika asli dipertahankan[cite: 2]
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.cardBorder, 
            width: selected ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label, 
          style: TextStyle(
            color: selected ? color : AppColors.muted, 
            fontWeight: FontWeight.bold, 
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _colorToHex(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}'; // Logika asli dipertahankan[cite: 2]

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Logika asli dipertahankan[cite: 2]
    setState(() { _saving = true; _error = null; }); // Logika asli dipertahankan[cite: 2]
    try {
      final provider = context.read<AppProvider>(); // Logika asli dipertahankan[cite: 2]
      if (widget.existing == null) {
        await provider.addCategory(_name.text.trim(), _type, _colorToHex(_color)); // Logika asli dipertahankan[cite: 2]
      } else {
        await provider.editCategory(widget.existing!.id, _name.text.trim(), _type, _colorToHex(_color)); // Logika asli dipertahankan[cite: 2]
      }
      if (mounted) Navigator.pop(context); // Logika asli dipertahankan[cite: 2]
    } catch (e) {
      setState(() => _error = extractErrorMessage(e)); // Logika asli dipertahankan[cite: 2]
    } finally {
      if (mounted) setState(() => _saving = false); // Logika asli dipertahankan[cite: 2]
    }
  }
}