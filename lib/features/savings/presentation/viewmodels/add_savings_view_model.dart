import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../../../accounts/domain/entities/account_type.dart';
import '../providers/savings_providers.dart';

class AddSavingsFormState {
  const AddSavingsFormState({
    this.amountText = '',
    this.note = '',
    this.isWithdrawal = false,
    required this.date,
    this.isSaving = false,
    this.errorMessage,
  });

  final String amountText;
  final String note;

  /// `false` = Cash -> Savings, `true` = Savings -> Cash.
  final bool isWithdrawal;
  final DateTime date;
  final bool isSaving;
  final String? errorMessage;

  int? get amountCents => parseAmountToCents(amountText);

  bool get canSubmit => amountCents != null && !isSaving;

  AddSavingsFormState copyWith({
    String? amountText,
    String? note,
    bool? isWithdrawal,
    DateTime? date,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddSavingsFormState(
      amountText: amountText ?? this.amountText,
      note: note ?? this.note,
      isWithdrawal: isWithdrawal ?? this.isWithdrawal,
      date: date ?? this.date,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AddSavingsViewModel extends Notifier<AddSavingsFormState> {
  @override
  AddSavingsFormState build() {
    return AddSavingsFormState(date: DateTime.now());
  }

  void setAmount(String value) {
    state = state.copyWith(amountText: value, clearError: true);
  }

  void setNote(String value) {
    state = state.copyWith(note: value, clearError: true);
  }

  void setType({required bool isWithdrawal}) {
    state = state.copyWith(isWithdrawal: isWithdrawal, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  Future<bool> submit({AppCurrency currency = AppCurrency.mmk}) async {
    // A rapid double-tap must not create two transfers.
    if (state.isSaving) return false;

    final amountCents = state.amountCents;
    if (amountCents == null) {
      state = state.copyWith(errorMessage: 'Enter an amount like 1,500.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref.read(addTransferUseCaseProvider)(
        amountCents: amountCents,
        from: state.isWithdrawal ? AccountType.savings : AccountType.cash,
        to: state.isWithdrawal ? AccountType.cash : AccountType.savings,
        note: state.note,
        date: state.date,
        currency: currency,
      );
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(isSaving: false, errorMessage: failure.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Could not save this transfer.',
      );
      return false;
    }
  }
}

final addSavingsViewModelProvider =
    NotifierProvider.autoDispose<AddSavingsViewModel, AddSavingsFormState>(
      AddSavingsViewModel.new,
    );
