import 'package:cpkey/CpKeyPlugin.dart';
import 'package:cpkey_example/presentation/common_ui.dart';
import 'package:cpkey_example/presentation/keys/keys_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import 'create_cert_bloc.dart';
import 'package:collection/collection.dart';

// screen
class CreateCertScreen extends StatelessWidget {
  const CreateCertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateCertBloc>(
      create: (context) => getIt<CreateCertBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Создание сертификата')),
        body: const _CreateCertBody(),
      ),
    );
  }
}

class _CreateCertBody extends StatelessWidget {
  const _CreateCertBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCertBloc, CreateCertState>(
      listenWhen: (prev, curr) => curr is CertCreated || curr is CertError,
      listener: (context, state) {
        if (state is CertCreated) {
          context.showInfoDialog(
            "Сертификат успешно создан",
            onConfirm: () => context.read<CreateCertBloc>().add(Exit()),
          );
        } else if (state is CertError) {
          context.showInfoDialog(
            state.message,
            onConfirm: () => context.read<CreateCertBloc>().add(Exit()),
          );
        }
      },
      child: BlocBuilder<CreateCertBloc, CreateCertState>(
        buildWhen: (prev, curr) =>
            curr is CertParamsLoading ||
            curr is CertParamsLoaded ||
            curr is CertCreating,
        builder: (context, state) {
          if (state is CertParamsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CertCreating) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CertParamsLoaded) {
            return CreateCertForm(
              formData: state.formData,
              isSubmitting: state is CertCreating,
              onSubmit: (caId, templateId, name, certStorage) {
                context.read<CreateCertBloc>().add(
                  SubmitCreateCert(
                    caId: caId,
                    templateId: templateId,
                    name: name,
                    certStorage: certStorage,
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class CreateCertForm extends StatefulWidget {
  final CreateCertFormData formData;
  final bool isSubmitting;
  final void Function(
    int caId,
    String templateId,
    String name,
    KeyStorageType certStorage,
  )
  onSubmit;

  const CreateCertForm({
    super.key,
    required this.formData,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<CreateCertForm> createState() => _CreateCertFormState();
}

class _CreateCertFormState extends State<CreateCertForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  DssCaPolicy? _selectedCaPolicy;
  String? _selectedTemplate;
  KeyStorageType? _selectedKeyStorage;

  @override
  void initState() {
    super.initState();
    _initDefaultValues();
  }

  @override
  void didUpdateWidget(covariant CreateCertForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formData != widget.formData) {
      _initDefaultValues();
    }
  }

  void _initDefaultValues() {
    _selectedCaPolicy = widget.formData.policies.firstOrNull;
    _selectedTemplate = _selectedCaPolicy?.templateNames.firstOrNull;
    _selectedKeyStorage = widget.formData.certAvailableStorage.firstOrNull;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = _selectedCaPolicy?.templateNames ?? const [];

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Имя сертификата
            CertNameField(
              controller: _nameController,
              enabled: !widget.isSubmitting,
            ),
            const SizedBox(height: 24),

            // 2. Выбор УЦ
            CaPolicyDropdown(
              value: _selectedCaPolicy,
              items: widget.formData.policies,
              enabled: !widget.isSubmitting,
              onChanged: (policy) {
                setState(() {
                  _selectedCaPolicy = policy;
                  _selectedTemplate = policy.templateNames.firstOrNull;
                });
              },
            ),
            const SizedBox(height: 24),

            // 3. Выбор Шаблона
            TemplateDropdown(
              policyId: _selectedCaPolicy?.id,
              value: templates.contains(_selectedTemplate)
                  ? _selectedTemplate
                  : null,
              items: templates,
              enabled: !widget.isSubmitting,
              onChanged: (template) {
                setState(() => _selectedTemplate = template);
              },
            ),
            const SizedBox(height: 24),

            // 4. Выбор Хранилища
            KeyStorageDropdown(
              value:
                  widget.formData.certAvailableStorage.contains(
                    _selectedKeyStorage,
                  )
                  ? _selectedKeyStorage
                  : null,
              items: widget.formData.certAvailableStorage,
              enabled: !widget.isSubmitting,
              onChanged: (storage) {
                setState(() => _selectedKeyStorage = storage);
              },
            ),
            const SizedBox(height: 48),

            // 5. Кнопка отправки
            SubmitButton(
              isLoading: widget.isSubmitting,
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final policy = _selectedCaPolicy!;
    final template = _selectedTemplate!;
    final storage = _selectedKeyStorage!;

    widget.onSubmit(
      policy.id,
      policy.getTemplateId(template), // Использование extension-метода
      _nameController.text.trim(),
      storage,
    );
  }
}

class CertNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const CertNameField({
    super.key,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: 'Имя сертификата',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Пожалуйста, введите имя сертификата';
        }
        return null;
      },
    );
  }
}

/// Выпадающий список Удостоверяющих Центров
class CaPolicyDropdown extends StatelessWidget {
  final DssCaPolicy? value;
  final List<DssCaPolicy> items;
  final bool enabled;
  final ValueChanged<DssCaPolicy> onChanged;

  const CaPolicyDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DssCaPolicy>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Удостоверяющий центр',
        border: OutlineInputBorder(),
      ),
      items: items
          .where((p) => p.name != null)
          .map((p) => DropdownMenuItem(value: p, child: Text(p.name!)))
          .toList(),
      onChanged: enabled ? (val) => val != null ? onChanged(val) : null : null,
      validator: (val) => val == null ? 'Выберите УЦ' : null,
    );
  }
}

/// Выпадающий список Шаблонов
class TemplateDropdown extends StatelessWidget {
  final int? policyId;
  final String? value;
  final List<String> items;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const TemplateDropdown({
    super.key,
    required this.policyId,
    required this.value,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('template_$policyId'),
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Шаблон сертификата',
        border: OutlineInputBorder(),
      ),
      items: items
          .map((name) => DropdownMenuItem(value: name, child: Text(name)))
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: (val) => val == null ? 'Выберите шаблон' : null,
    );
  }
}

/// Выпадающий список Хранилищ ключей
class KeyStorageDropdown extends StatelessWidget {
  final KeyStorageType? value;
  final List<KeyStorageType> items;
  final bool enabled;
  final ValueChanged<KeyStorageType?> onChanged;

  const KeyStorageDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<KeyStorageType>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Хранилище ключей',
        border: OutlineInputBorder(),
      ),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: (val) => val == null ? 'Выберите хранилище' : null,
    );
  }
}

/// Кнопка отправки формы
class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Создать\n(Cert.getCert+Cert.signRequest+Cert.installCert)',
              textAlign: TextAlign.center,
            ),
    );
  }
}

extension DssCaPolicyX on DssCaPolicy {
  /// Получает список имен шаблонов
  List<String> get templateNames => ekuTemplates?.keys.toList() ?? [];

  /// Безопасно извлекает и форматирует templateId для конкретного шаблона
  String getTemplateId(String templateName) {
    final raw = ekuTemplates?[templateName];
    if (raw == null) return '';
    if (raw is List) {
      return raw.map((e) => e.toString()).join(',');
    }
    return raw.toString();
  }
}
