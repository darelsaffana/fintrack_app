import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final list = provider.transactions.where((t) => _filter == 'all' || t.type == _filter).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Transaksi'),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _FilterChip(label: 'Semua', selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
            const SizedBox(width: 8),
            _FilterChip(label: 'Pemasukan', selected: _filter == 'income', onTap: () => setState(() => _filter = 'income')),
            const SizedBox(width: 8),
            _FilterChip(label: 'Pengeluaran', selected: _filter == 'expense', onTap: () => setState(() => _filter = 'expense')),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(message: 'Tidak ada transaksi untuk ditampilkan.')
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) => TransactionTile(
                      transaction: list[i],
                      onEdit: () => _openForm(context, existing: list[i]),
                      onDelete: () => _confirmDelete(context, list[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Transaction t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Transaksi yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<AppProvider>().deleteTransaction(t.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
        }
      }
    }
  }

  void _openForm(BuildContext context, {Transaction? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _TransactionForm(existing: existing),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

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

class _TransactionForm extends StatefulWidget {
  final Transaction? existing;
  const _TransactionForm({this.existing});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  int? _categoryId;
  final _amount = TextEditingController();
  final _description = TextEditingController();
  late DateTime _date;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
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
    final cats = _type == 'income' ? provider.incomeCategories : provider.expenseCategories;
    if (_categoryId == null || !cats.any((c) => c.id == _categoryId)) {
      _categoryId = cats.isNotEmpty ? cats.first.id : null;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.existing == null ? 'Tambah Transaksi' : 'Ubah Transaksi',
                  style: const TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              _typeToggle(),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Kategori'),
                dropdownColor: AppColors.card,
                items: [for (final c in cats) DropdownMenuItem(value: c.id, child: Text(c.name))],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Masukkan jumlah yang valid' : null,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal'),
                  child: Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(color: AppColors.text)),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
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

  Widget _typeToggle() {
    Widget option(String value, String label, Color color) {
      final selected = _type == value;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() { _type = value; _categoryId = null; }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: selected ? color.withOpacity(0.12) : Colors.transparent),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(color: selected ? color : AppColors.muted, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [option('income', 'Pemasukan', AppColors.income), option('expense', 'Pengeluaran', AppColors.expense)]),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

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
