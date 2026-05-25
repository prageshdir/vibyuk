import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_pricing/ai_pricing_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_pricing/ai_pricing_event.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_pricing/ai_pricing_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/cards/ai_pricing_card.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_empty_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_gradient_header.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_loading_shimmer.dart';

class AiPricingScreen extends StatefulWidget {
  const AiPricingScreen({super.key});

  @override
  State<AiPricingScreen> createState() => _AiPricingScreenState();
}

class _AiPricingScreenState extends State<AiPricingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AiPricingBloc>().add(const LoadAllPricingSuggestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AiGradientHeader(
              title: 'Price Optimizer',
              subtitle: 'AI-powered market pricing intelligence',
              trailing: IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onPressed: () => _showGetPricingSheet(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _ServiceTypeFilter(),
          ),
          BlocBuilder<AiPricingBloc, AiPricingState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const SliverToBoxAdapter(
                  child: AiLoadingShimmer(cardCount: 3, cardHeight: 300),
                );
              }

              if (state.hasError && !state.hasData) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(state.failure?.message ?? 'Failed to load pricing'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<AiPricingBloc>()
                              .add(const LoadAllPricingSuggestions()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!state.hasData) {
                return SliverFillRemaining(
                  child: AiEmptyState(
                    title: 'No pricing data yet',
                    message:
                        'Generate AI pricing suggestions for your services',
                    icon: Icons.sell_outlined,
                    actionLabel: 'Get Pricing',
                    onAction: () => _showGetPricingSheet(context),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final suggestion = state.suggestions[i];
                      final isActive =
                          state.activeSuggestion?.id == suggestion.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AiPricingCard(
                          suggestion: suggestion,
                          isActive: isActive,
                          onTap: () => context.read<AiPricingBloc>().add(
                                SelectServiceType(
                                  serviceType: suggestion.serviceType,
                                ),
                              ),
                        ),
                      );
                    },
                    childCount: state.suggestions.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showGetPricingSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<AiPricingBloc>(),
        child: const _GetPricingSheet(),
      ),
    );
  }
}

class _ServiceTypeFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final types = PricingServiceType.values;

    return BlocBuilder<AiPricingBloc, AiPricingState>(
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: types.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final type = types[i];
              final isSelected = state.selectedServiceType == type;
              return GestureDetector(
                onTap: () => context
                    .read<AiPricingBloc>()
                    .add(SelectServiceType(serviceType: type)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: AppColors.brandGradient,
                          )
                        : null,
                    color: isSelected ? null : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _typeLabel(type),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _typeLabel(PricingServiceType type) {
    return switch (type) {
      PricingServiceType.photography => 'Photo',
      PricingServiceType.videography => 'Video',
      PricingServiceType.musicPerformance => 'Music',
      PricingServiceType.djSet => 'DJ',
      PricingServiceType.eventPlanning => 'Events',
      PricingServiceType.speaking => 'Speaking',
      PricingServiceType.brandDesign => 'Design',
      PricingServiceType.socialContent => 'Social',
    };
  }
}

class _GetPricingSheet extends StatefulWidget {
  const _GetPricingSheet();

  @override
  State<_GetPricingSheet> createState() => _GetPricingSheetState();
}

class _GetPricingSheetState extends State<_GetPricingSheet> {
  PricingServiceType _serviceType = PricingServiceType.photography;
  int _experienceYears = 3;
  final _locationCtrl = TextEditingController(text: 'London, UK');

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get AI Pricing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PricingServiceType>(
            value: _serviceType,
            items: PricingServiceType.values.map((t) {
              return DropdownMenuItem(value: t, child: Text(_typeLabel(t)));
            }).toList(),
            onChanged: (v) => setState(() => _serviceType = v!),
            decoration: InputDecoration(
              labelText: 'Service Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Experience: $_experienceYears years',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _experienceYears.toDouble(),
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: AppColors.primary,
            label: '$_experienceYears yrs',
            onChanged: (v) => setState(() => _experienceYears = v.toInt()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AiPricingBloc>().add(
                      GetPricingSuggestion(
                        serviceType: _serviceType,
                        location: _locationCtrl.text.trim(),
                        experienceYears: _experienceYears,
                      ),
                    );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text(
                'Get AI Pricing',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(PricingServiceType type) {
    return switch (type) {
      PricingServiceType.photography => 'Photography',
      PricingServiceType.videography => 'Videography',
      PricingServiceType.musicPerformance => 'Music Performance',
      PricingServiceType.djSet => 'DJ Set',
      PricingServiceType.eventPlanning => 'Event Planning',
      PricingServiceType.speaking => 'Speaking Engagement',
      PricingServiceType.brandDesign => 'Brand Design',
      PricingServiceType.socialContent => 'Social Content',
    };
  }
}
