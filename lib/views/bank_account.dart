import 'package:flutter/material.dart';

import '../controlles/bank_account_controller.dart';
import '../models/bank_account_model.dart';
import 'package:flutter/services.dart';

class BankAccountView extends StatefulWidget {
  const BankAccountView({super.key});

  @override
  State<BankAccountView> createState() => _BankAccountViewState();
}

class _BankAccountViewState extends State<BankAccountView> {
  final c = BankAccountController();
  final _formKey = GlobalKey<FormState>();

  static const Color kPurple = Color(0xFF4F378B);
  static const Color kSoftBg = Color(0xFFF4F1FA);
  static const Color kBorder = Color(0x66B8A9D9);

  @override
  void initState() {
    super.initState();
    c.init();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    c.ibanCtrl.clear();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add IBAN'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: c.ibanCtrl,
            validator: c.validateIban,
             maxLength: 24, 
             inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
             IbanFormatter(),
             ],
            decoration: const InputDecoration(
              labelText: 'IBAN',
              hintText: 'SAxxxxxxxxxxxxxxxxxxxx',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kPurple),
            onPressed: c.isSaving
                ? null
                : () async {
                    final ok = _formKey.currentState?.validate() ?? false;
                    if (!ok) return;
                    await c.addIban();
                    if (!mounted) return;
                    Navigator.pop(ctx);
                  },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BankAccountModel item) async {
    c.ibanCtrl.text = item.iban;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit IBAN'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: c.ibanCtrl,
            validator: c.validateIban,
            decoration: const InputDecoration(
              labelText: 'IBAN',
              hintText: 'SAxxxxxxxxxxxxxxxxxxxx',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kPurple),
            onPressed: c.isSaving
                ? null
                : () async {
                    final ok = formKey.currentState?.validate() ?? false;
                    if (!ok) return;
                    await c.updateIban(id: item.id, newIban: c.ibanCtrl.text);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                  },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BankAccountModel item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete IBAN'),
        content: Text('Are you sure you want to delete:\n${item.iban}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (yes == true) {
      await c.deleteIban(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Bank Account'),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: kPurple,
            onPressed: c.isSaving ? null : _openAddDialog,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: c.isLoading
              ? const Center(child: CircularProgressIndicator())
              : c.error != null
                  ? Center(child: Text(c.error!))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: _Card(
                        borderColor: kBorder,
                        background: kSoftBg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your IBANs',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 10),

                            if (c.accounts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Text('No IBAN added yet. Tap + to add one.'),
                              )
                            else
                              ...c.accounts.map((a) => _IbanTile(
                                    purple: kPurple,
                                    item: a,
                                    onSetDefault: () => c.setDefault(a.id),
                                    onEdit: () => _openEditDialog(a),
                                    onDelete: () => _confirmDelete(a),
                                    disabled: c.isSaving,
                                  )),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color background;

  const _Card({
    required this.child,
    required this.borderColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class _IbanTile extends StatelessWidget {
  final Color purple;
  final BankAccountModel item;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool disabled;

  const _IbanTile({
    required this.purple,
    required this.item,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: purple.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: item.isDefault,
            onChanged: disabled ? null : (_) => onSetDefault(),
            activeColor: purple,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.iban,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  item.isDefault ? 'Default' : 'Tap circle to set default',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: disabled ? null : onEdit,
            icon: Icon(Icons.edit, color: purple),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: disabled ? null : onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),

          ),
        ],
      ),
    );
  }
}

 
class IbanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', '').toUpperCase();

    if (text.length > 24) {
      text = text.substring(0, 24);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
