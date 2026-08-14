import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/lot_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/firebase_providers.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_field.dart';

class HtxCreateLotScreen extends ConsumerStatefulWidget {
  const HtxCreateLotScreen({super.key});
  @override ConsumerState<HtxCreateLotScreen> createState() => _State();
}

class _State extends ConsumerState<HtxCreateLotScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _priceCtrl  = TextEditingController();
  final _totalCtrl  = TextEditingController();
  final _moqCtrl    = TextEditingController(text: '100');
  final _provinceCtrl = TextEditingController();
  final _harvestCtrl  = TextEditingController();
  final _readyCtrl    = TextEditingController();
  final _packCtrl     = TextEditingController();
  String _category = 'rau';
  bool _allowNeg   = true;
  bool _isLoading  = false;
  int  _step       = 1;
  final _cats = ['rau', 'cu', 'qua', 'gao', 'khac'];
  final _catLabels = ['Rau', 'Củ', 'Quả', 'Gạo', 'Khác'];

  @override
  void dispose() {
    for (final c in [_nameCtrl,_priceCtrl,_totalCtrl,_moqCtrl,
        _provinceCtrl,_harvestCtrl,_readyCtrl,_packCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      final db  = ref.read(firestoreProvider);
      final ref2 = db.collection(AppConstants.lotsCol).doc();
      final now  = DateTime.now();
      final lot  = LotModel(
        id: ref2.id, sellerId: user.uid,
        sellerName: user.orgName ?? user.displayName,
        name: _nameCtrl.text.trim(), category: _category,
        code: 'LO-${_category.toUpperCase()}-${now.year}${now.month.toString().padLeft(2,'0')}'
              '${now.day.toString().padLeft(2,'0')}-${ref2.id.substring(0,4).toUpperCase()}',
        imageUrls: [],
        pricePerKg: double.tryParse(_priceCtrl.text.replaceAll(',','')) ?? 0,
        totalKg:    double.tryParse(_totalCtrl.text) ?? 0,
        remainKg:   double.tryParse(_totalCtrl.text) ?? 0,
        moqKg:      double.tryParse(_moqCtrl.text) ?? 100,
        province: _provinceCtrl.text.trim(),
        harvestDate: _harvestCtrl.text.trim(),
        readyDate:   _readyCtrl.text.trim(),
        packingSpec: _packCtrl.text.trim(),
        allowNegotiate: _allowNeg,
        createdAt: now, updatedAt: now,
      );
      await ref2.set(lot.toFirestore());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã đăng lô hàng thành công!'),
          backgroundColor: AppColors.primaryGreen));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi: $e'), backgroundColor: AppColors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Đăng lô hàng – Bước $_step/2'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _step == 1 ? context.pop() : setState(() => _step = 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Step bar
              Row(children: [1,2].map((s) => Expanded(child: Container(
                height: 4, margin: EdgeInsets.only(right: s < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: s <= _step ? AppColors.primaryGreen : AppColors.divider,
                  borderRadius: BorderRadius.circular(2)),
              ))).toList()),
              const SizedBox(height: 20),
              Text(_step == 1 ? 'Thông tin cơ bản' : 'Nguồn gốc và chất lượng',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold,
                    letterSpacing: -0.3)),
              const SizedBox(height: 20),

              if (_step == 1) ...[
                AppField(label: 'Tên nông sản', controller: _nameCtrl,
                  required: true, validator: (v) => v!.trim().isEmpty ? 'Bắt buộc' : null),
                const SizedBox(height: 14),
                const Text('Danh mục',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: Row(children: List.generate(_cats.length, (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_catLabels[i]),
                      selected: _category == _cats[i],
                      onSelected: (_) => setState(() => _category = _cats[i]),
                      selectedColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: _category == _cats[i] ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w500, fontSize: 13),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: _category == _cats[i] ? AppColors.primaryGreen : AppColors.divider),
                      showCheckmark: false,
                    ),
                  )))),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: AppField(label: 'Giá đề nghị (₫/kg)',
                    controller: _priceCtrl, required: true,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Bắt buộc' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: AppField(label: 'Tổng số lượng', controller: _totalCtrl,
                    suffix: 'kg', required: true, keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Bắt buộc' : null)),
                ]),
                const SizedBox(height: 14),
                AppField(label: 'Đặt tối thiểu', controller: _moqCtrl,
                  suffix: 'kg', keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cho phép thương lượng giá',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const Text('Người mua có thể gửi đề nghị giá',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                  Switch(value: _allowNeg, onChanged: (v) => setState(() => _allowNeg = v),
                    activeColor: AppColors.primaryGreen),
                ]),
                const SizedBox(height: 24),
                AppButton(label: 'Tiếp tục', onPressed: () {
                  if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _totalCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
                    return;
                  }
                  setState(() => _step = 2);
                }),
              ] else ...[
                AppField(label: 'Tỉnh/Thành phố', controller: _provinceCtrl,
                  required: true, prefixIcon: Icons.location_on_outlined,
                  validator: (v) => v!.trim().isEmpty ? 'Bắt buộc' : null),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: AppField(label: 'Ngày thu hoạch',
                    controller: _harvestCtrl, prefixIcon: Icons.calendar_today_outlined,
                    hint: 'DD/MM/YYYY')),
                  const SizedBox(width: 12),
                  Expanded(child: AppField(label: 'Ngày giao được',
                    controller: _readyCtrl, prefixIcon: Icons.event_available_outlined,
                    hint: 'DD/MM/YYYY')),
                ]),
                const SizedBox(height: 14),
                AppField(label: 'Quy cách đóng gói', controller: _packCtrl,
                  hint: 'VD: Thùng carton 10 kg, lót giấy'),
                const SizedBox(height: 24),
                AppButton(label: 'Đăng lô hàng', isLoading: _isLoading, onPressed: _submit),
                const SizedBox(height: 12),
                AppButton(label: 'Lưu bản nháp', variant: AppButtonVariant.outline,
                  onPressed: () => context.pop()),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
