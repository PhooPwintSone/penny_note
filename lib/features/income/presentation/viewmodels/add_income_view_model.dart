import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/income.dart';
import '../providers/income_providers.dart';

class AddIncomeFormState {
  const AddIncomeFormState({
    this.amountText = '',
    this.note = '',
    this.categoryId,
    required this.date,
    this.editingId,
    this.isSaving = false,
    this.errorMessage,
  });

  final String amountText;
  final String note;
  final int? categoryId;
  final DateTime date;
  final int? editingId;
  final bool isSaving;
  final String? errorMessage;

  int? get amountCents => parseAmountToCents(amountText);

  bool get isEditing => editingId != null;

  bool get canSubmit => amountCents != null && categoryId != null && !isSaving;

  AddIncomeFormState copyWith({
    String? amountText,
    String? note,
    int? categoryId,
    DateTime? date,
    int? editingId,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddIncomeFormState(
      amountText: amountText ?? this.amountText,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      editingId: editingId ?? this.editingId,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AddIncomeViewModel extends Notifier<AddIncomeFormState> {
  AddIncomeViewModel(this.initialIncome);

  final Income? initialIncome;

  @override
  AddIncomeFormState build() {
    final income = initialIncome;
    if (income == null) {
      return AddIncomeFormState(date: DateTime.now());
    }

    return AddIncomeFormState(
      amountText: formatCentsForInput(income.amountCents),
      note: income.note,
      categoryId: income.category.id,
      date: income.date,
      editingId: income.id,
    );
  }

  void setAmount(String value) {
    state = state.copyWith(amountText: value, clearError: true);
  }

  void setNote(String value) {
    state = state.copyWith(note: value, clearError: true);
  }

  void selectCategory(int categoryId) {
    state = state.copyWith(categoryId: categoryId, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Saves the income entry. Returns `true` when the screen should close.
  Future<bool> submit() async {
    // A rapid double-tap must not create two income entries.
    if (state.isSaving) return false;

    final amountCents = state.amountCents;
    final categoryId = state.categoryId;

    if (amountCents == null) {
      state = state.copyWith(errorMessage: 'Enter an amount like 1,500.');
      return false;
    }
    if (categoryId == null) {
      state = state.copyWith(errorMessage: 'Choose an income category.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final editingId = state.editingId;
      if (editingId == null) {
        await ref.read(addIncomeUseCaseProvider)(
          amountCents: amountCents,
          categoryId: categoryId,
          note: state.note,
          date: state.date,
        );
      } else {
        await ref.read(updateIncomeUseCaseProvider)(
          id: editingId,
          amountCents: amountCents,
          categoryId: categoryId,
          note: state.note,
          date: state.date,
        );
      }
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(isSaving: false, errorMessage: failure.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: state.isEditing
            ? 'Could not update this income entry.'
            : 'Could not save this income entry.',
      );
      return false;
    }
  }
}

final addIncomeViewModelProvider = NotifierProvider.autoDispose
    .family<AddIncomeViewModel, AddIncomeFormState, Income?>(
      AddIncomeViewModel.new,
    );
