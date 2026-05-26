import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_campaign/ai_campaign_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_campaign/ai_campaign_event.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_campaign/ai_campaign_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/campaign/ai_campaign_timeline.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_empty_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_gradient_header.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_loading_shimmer.dart';

class AiCampaignPlannerScreen extends StatefulWidget {
  const AiCampaignPlannerScreen({super.key});

  @override
  State<AiCampaignPlannerScreen> createState() =>
      _AiCampaignPlannerScreenState();
}

class _AiCampaignPlannerScreenState extends State<AiCampaignPlannerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AiCampaignBloc>().add(const LoadSavedCampaigns());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: AiGradientHeader(
              title: 'Campaign Planner',
              subtitle: 'AI generates your complete marketing roadmap',
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'My Campaigns'),
                  Tab(text: 'Create New'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _CampaignListTab(),
            _CreateCampaignTab(
              onCreated: () => _tabController.animateTo(0),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiCampaignBloc, AiCampaignState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const AiLoadingShimmer(cardCount: 3, cardHeight: 160);
        }

        if (state.hasError && !state.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text(state.failure?.message ?? 'Failed to load campaigns'),
              ],
            ),
          );
        }

        if (!state.hasData) {
          return AiEmptyState(
            title: 'No campaigns yet',
            message: 'Let AI plan your next marketing campaign end-to-end',
            icon: Icons.campaign_outlined,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.campaigns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final campaign = state.campaigns[i];
            final isSelected = state.selectedCampaign?.id == campaign.id;
            return _CampaignListCard(
              campaign: campaign,
              isSelected: isSelected,
              onTap: () {
                context.read<AiCampaignBloc>().add(
                      SelectCampaign(campaignId: campaign.id),
                    );
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<AiCampaignBloc>(),
                    child: _CampaignDetailSheet(campaign: campaign),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CampaignListCard extends StatelessWidget {
  final AiCampaign campaign;
  final bool isSelected;
  final VoidCallback onTap;

  const _CampaignListCard({
    required this.campaign,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (campaign.status) {
      CampaignStatus.active ||
      CampaignStatus.published ||
      CampaignStatus.applications ||
      CampaignStatus.inProgress =>
        AppColors.success,
      CampaignStatus.draft => AppColors.warning,
      CampaignStatus.paused => AppColors.textSecondary,
      CampaignStatus.completed || CampaignStatus.archived => AppColors.tertiary,
      CampaignStatus.cancelled => AppColors.error,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.outline.withOpacity(0.15),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    campaign.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    campaign.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              campaign.objective,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: campaign.progressPercent,
                minHeight: 4,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${campaign.completedSteps}/${campaign.steps.length} steps',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '₹${campaign.budget.toStringAsFixed(0)} budget',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignDetailSheet extends StatelessWidget {
  final AiCampaign campaign;

  const _CampaignDetailSheet({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (campaign.aiSummary != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.06),
                            AppColors.tertiary.withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              campaign.aiSummary!,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AiCampaignTimeline(
                    campaign: campaign,
                    onUpdateStep: (stepId, status) {
                      context.read<AiCampaignBloc>().add(
                            UpdateStep(
                              campaignId: campaign.id,
                              stepId: stepId,
                              status: status,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCampaignTab extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateCampaignTab({required this.onCreated});

  @override
  State<_CreateCampaignTab> createState() => _CreateCampaignTabState();
}

class _CreateCampaignTabState extends State<_CreateCampaignTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();
  final _audienceCtrl = TextEditingController();
  double _budget = 2000;
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 37));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _objectiveCtrl.dispose();
    _audienceCtrl.dispose();
    super.dispose();
  }

  void _generate(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AiCampaignBloc>().add(
          GenerateCampaign(
            title: _titleCtrl.text.trim(),
            objective: _objectiveCtrl.text.trim(),
            targetAudience: _audienceCtrl.text.trim(),
            budget: _budget,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
    widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiCampaignBloc, AiCampaignState>(
      listenWhen: (prev, curr) =>
          !prev.isGenerating && !curr.isGenerating && curr.generatedCampaign != null,
      listener: (context, state) => widget.onCreated(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(
                icon: Icons.auto_awesome_rounded,
                label: 'Describe your campaign',
              ),
              const SizedBox(height: 16),
              _InputField(
                controller: _titleCtrl,
                label: 'Campaign Title',
                hint: 'e.g. Summer Music Festival Promo',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: _objectiveCtrl,
                label: 'Campaign Objective',
                hint: 'e.g. Increase ticket sales by 30%',
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter an objective' : null,
              ),
              const SizedBox(height: 12),
              _InputField(
                controller: _audienceCtrl,
                label: 'Target Audience',
                hint: 'e.g. 25-40 year olds interested in live music',
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please describe your audience' : null,
              ),
              const SizedBox(height: 20),
              _SectionLabel(
                icon: Icons.tune_rounded,
                label: 'Budget & Timeline',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Budget: ₹${_budget.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Slider(
                value: _budget,
                min: 500,
                max: 50000,
                divisions: 99,
                activeColor: AppColors.primary,
                label: '₹${_budget.toStringAsFixed(0)}',
                onChanged: (v) => setState(() => _budget = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Start Date',
                      date: _startDate,
                      onPick: (d) => setState(() => _startDate = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'End Date',
                      date: _endDate,
                      onPick: (d) => setState(() => _endDate = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              BlocBuilder<AiCampaignBloc, AiCampaignState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isGenerating
                          ? null
                          : () => _generate(context),
                      icon: state.isGenerating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(
                        state.isGenerating
                            ? 'AI is planning...'
                            : 'Generate Campaign Plan',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPick,
  });

  String _format(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  _format(date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
