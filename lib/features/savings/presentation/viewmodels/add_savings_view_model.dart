import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
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

  Future<bool> submit() async {
    final amountCents = state.amountCents;
    if (amountCents == null) {
      state = state.copyWith(errorMessage: 'Enter an amount like 1,500.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref.read(addSavingsUseCaseProvider)(
        amountCents: amountCents,
        isWithdrawal: state.isWithdrawal,
        note: state.note,
        date: state.date,
      );
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(isSaving: false, errorMessage: failure.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Could not save this savings entry.',
      );
      return false;
    }
  }
}

final addSavingsViewModelProvider =
    NotifierProvider.autoDispose<AddSavingsViewModel, AddSavingsFormState>(
      AddSavingsViewModel.new,
    );
