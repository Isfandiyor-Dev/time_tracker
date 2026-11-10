import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/localized_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/project.dart';
import '../../generated/locale_keys.g.dart';
import '../cubit/tracker_cubit.dart';
import '../widgets/anchored_dropdown_field.dart';

class ProjectEditorPage extends StatefulWidget {
  const ProjectEditorPage({super.key, this.project});

  final Project? project;

  @override
  State<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

class _ProjectEditorPageState extends State<ProjectEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _rate;
  late String _currency;
  bool _saving = false;

  static const currencies = ['UZS', 'USD', 'EUR', 'RUB', 'KZT', 'GBP'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.project?.name ?? '');
    _rate = TextEditingController(
      text: widget.project?.hourlyRate.toString() ?? '',
    );
    _currency = widget.project?.currency ?? 'UZS';
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<TrackerCubit>().saveProject(
        id: widget.project?.id ?? 0,
        name: _name.text,
        currency: _currency,
        hourlyRate: double.parse(_rate.text.replaceAll(',', '.')),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizedErrorMessage(error))));
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final project = widget.project;
    if (project == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.projects_deleteTitle.tr()),
        content: Text(
          LocaleKeys.projects_deleteMessage.tr(
            namedArgs: {'project': project.name},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(LocaleKeys.common_delete.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await context.read<TrackerCubit>().deleteProject(project);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizedErrorMessage(error))));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.project == null
                  ? LocaleKeys.projects_addTitle
                  : LocaleKeys.projects_editTitle)
              .tr(),
        ),
        actions: [
          if (widget.project != null)
            IconButton(
              tooltip: LocaleKeys.projects_deleteTooltip.tr(),
              onPressed: _saving ? null : _delete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(Icons.folder_rounded, size: 72, color: AppColors.lime),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: LocaleKeys.projects_nameLabel.tr(),
                  prefixIcon: const Icon(Icons.folder_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? LocaleKeys.projects_nameRequired.tr()
                    : null,
              ),
              const SizedBox(height: 14),
              AnchoredDropdownField<String>(
                value: _currency,
                items: {for (final currency in currencies) currency: currency},
                labelText: LocaleKeys.projects_currencyLabel.tr(),
                prefixIcon: Icons.payments_outlined,
                onChanged: (value) => setState(() => _currency = value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: LocaleKeys.projects_hourlyRateLabel.tr(),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  return parsed == null || parsed < 0
                      ? LocaleKeys.projects_rateRequired.tr()
                      : null;
                },
              ),
              const SizedBox(height: 10),
              Text(
                LocaleKeys.projects_historyHint.tr(),
                style: const TextStyle(color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(LocaleKeys.common_save.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
