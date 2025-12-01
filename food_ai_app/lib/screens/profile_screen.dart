import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _availableCuisines = [
    'Brasileira',
    'Italiana',
    'Japonesa',
    'Mexicana',
    'Chinesa',
    'Árabe',
    'Indiana',
    'Francesa',
  ];

  final List<String> _availableDietaryRestrictions = [
    'Vegetariano',
    'Vegano',
    'Sem glúten',
    'Sem lactose',
    'Low carb',
    'Kosher',
    'Halal',
  ];

  final List<String> _spiceLevels = ['Suave', 'Médio', 'Picante'];
  final List<String> _budgetRanges = ['Econômico', 'Moderado', 'Premium'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEA1D2C), Color(0xFFFF4757)],
            ),
          ),
        ),
        title: const Text(
          'Preferências',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.preferences == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final prefs = userProvider.preferences ??
              UserPreferences(userId: userProvider.userId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Culinárias Favoritas',
                icon: Icons.restaurant,
                child: _buildMultiSelectChips(
                  options: _availableCuisines,
                  selected: prefs.favoriteCuisines,
                  onChanged: (selected) {
                    userProvider.updatePreferences(
                      prefs.copyWith(favoriteCuisines: selected),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Restrições Alimentares',
                icon: Icons.no_food,
                child: _buildMultiSelectChips(
                  options: _availableDietaryRestrictions,
                  selected: prefs.dietaryRestrictions,
                  onChanged: (selected) {
                    userProvider.updatePreferences(
                      prefs.copyWith(dietaryRestrictions: selected),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Alergias',
                icon: Icons.warning_amber,
                child: _buildAllergiesInput(prefs, userProvider),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Nível de Pimenta',
                icon: Icons.local_fire_department,
                child: _buildSingleSelectChips(
                  options: _spiceLevels,
                  selected: prefs.spiceLevel,
                  onChanged: (selected) {
                    userProvider.updatePreferences(
                      prefs.copyWith(spiceLevel: selected),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Faixa de Preço',
                icon: Icons.attach_money,
                child: _buildSingleSelectChips(
                  options: _budgetRanges,
                  selected: prefs.budgetRange,
                  onChanged: (selected) {
                    userProvider.updatePreferences(
                      prefs.copyWith(budgetRange: selected),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA1D2C), Color(0xFFFF4757)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> options,
    required List<String> selected,
    required Function(List<String>) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool value) {
            final newSelected = List<String>.from(selected);
            if (value) {
              newSelected.add(option);
            } else {
              newSelected.remove(option);
            }
            onChanged(newSelected);
          },
          selectedColor: const Color(0xFFEA1D2C).withOpacity(0.2),
          checkmarkColor: const Color(0xFFEA1D2C),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectChips({
    required List<String> options,
    required String? selected,
    required Function(String?) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool value) {
            onChanged(value ? option : null);
          },
          selectedColor: const Color(0xFFEA1D2C).withOpacity(0.2),
        );
      }).toList(),
    );
  }

  Widget _buildAllergiesInput(
      UserPreferences prefs, UserProvider userProvider) {
    return Column(
      children: [
        ...prefs.allergies.map((allergy) => ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(allergy),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  final newAllergies = List<String>.from(prefs.allergies)
                    ..remove(allergy);
                  userProvider.updatePreferences(
                    prefs.copyWith(allergies: newAllergies),
                  );
                },
              ),
            )),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Alergia'),
          onPressed: () => _showAddAllergyDialog(prefs, userProvider),
        ),
      ],
    );
  }

  void _showAddAllergyDialog(
      UserPreferences prefs, UserProvider userProvider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Alergia'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ex: Amendoim, Frutos do mar...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newAllergies = List<String>.from(prefs.allergies)
                  ..add(controller.text);
                userProvider.updatePreferences(
                  prefs.copyWith(allergies: newAllergies),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
