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
  String _tab = 'expense';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final list = provider.categories.where((c) => c.type == _tab).toList();
    final counts = <int, int>{};
    for (final t in provider.transactions) {
      if (t.categoryId != null) counts[t.categoryId!] = (counts[t.categoryId!] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Kategori'),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _Tab(label: 'Pengeluaran', selected: _tab == 'expense', onTap: () => setState(() => _tab = 'expense')),
            const SizedBox(width: 8),
            _Tab(label: 'Pemasukan', selected: _tab == 'income', onTap: () => setState(() => _tab = 'income')),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: list.isEmpty
              ? EmptyState(message: 'Belum ada kategori ${_tab == "income" ? "pemasukan" : "pengeluaran"}.')
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, mainAxisExtent: 76, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final c = list[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
                      child: Row(
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: hexToColor(c.color), shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13.5)),
                                Text('${counts[c.id] ?? 0} transaksi', style: const TextStyle(color: AppColors.mutedDim, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.muted), onPressed: () => _openForm(context, existing: c), visualDensity: VisualDensity.compact),
                          IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.muted), onPressed: () => _confirmDelete(context, c), visualDensity: VisualDensity.compact),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus kategori?'),
        content: const Text('Transaksi yang sudah terkait kategori ini tidak akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<AppProvider>().deleteCategory(c.id);
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      }
    }
  }

  void _openForm(BuildContext context, {Category? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CategoryForm(existing: existing, defaultType: _tab),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accent.withOpacity(0.4) : AppColors.cardBorder),
        ),
        child: Text(label, style: TextStyle(color: selected ? AppColors.accent : AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
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
    _name.text = widget.existing?.name ?? '';
    _type = widget.existing?.type ?? widget.defaultType;
    _color = widget.existing != null ? hexToColor(widget.existing!.color) : AppColors.categoryPalette.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.existing == null ? 'Tambah Kategori' : 'Ubah Kategori',
                  style: const TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: _typeOption('income', 'Pemasukan', AppColors.income)),
                const SizedBox(width: 8),
                Expanded(child: _typeOption('expense', 'Pengeluaran', AppColors.expense)),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              const Text('Warna', style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: [
                  for (final c in AppColors.categoryPalette)
                    InkWell(
                      onTap: () => setState(() => _color = c),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle,
                          border: _color.value == c.value ? Border.all(color: Colors.white, width: 2) : null,
                        ),
                      ),
                    ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.expense, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan'),
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
    final selected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color.withOpacity(0.4) : AppColors.cardBorder),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: selected ? color : AppColors.muted, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  String _colorToHex(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final provider = context.read<AppProvider>();
      if (widget.existing == null) {
        await provider.addCategory(_name.text.trim(), _type, _colorToHex(_color));
      } else {
        await provider.editCategory(widget.existing!.id, _name.text.trim(), _type, _colorToHex(_color));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
