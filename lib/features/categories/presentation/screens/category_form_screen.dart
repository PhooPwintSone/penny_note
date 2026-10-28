import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  final Category? category;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  late final TextEditingController _nameController;
  late String _iconKey;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _iconKey = widget.category?.icon ?? 'category';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit category' : 'Add category'),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 640,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.xxl,
            ),
            children: [
              TextField(
                controller: _nameController,
                autofocus: !_isEditing,
                maxLength: 40,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Category name',
                  hintText: 'Groceries',
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Icon', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final option in categoryIconOptions)
                    _IconOption(
                      icon: categoryIconFor(option.key),
                      label: option.label,
                      selected: _iconKey == option.key,
                      onTap: () => setState(() {
                        _iconKey = option.key;
                        _errorMessage = null;
                      }),
                    ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Add category'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Enter a category name.');
      return;
    }
    if (_iconKey.isEmpty) {
      setState(() => _errorMessage = 'Choose an icon.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final category = widget.category;
      if (category == null) {
        await ref.read(addCategoryUseCaseProvider)(name: name, icon: _iconKey);
      } else {
        await ref.read(updateCategoryUseCaseProvider)(
          id: category.id,
          name: name,
          icon: _iconKey,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on AppFailure catch (failure) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Could not save this category.';
        });
      }
    }
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : colors.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
              color: selected ? colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: selected ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
