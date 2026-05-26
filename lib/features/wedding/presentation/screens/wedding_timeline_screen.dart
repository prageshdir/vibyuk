import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_timeline/wedding_timeline_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/timeline_task_tile.dart';

class WeddingTimelineScreen extends StatefulWidget {
  final String weddingId;
  const WeddingTimelineScreen({super.key, required this.weddingId});

  @override
  State<WeddingTimelineScreen> createState() => _WeddingTimelineScreenState();
}

class _WeddingTimelineScreenState extends State<WeddingTimelineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phases = TimelinePhase.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _phases.length, vsync: this);
    context
        .read<WeddingTimelineBloc>()
        .add(WeddingTimelineLoadRequested(weddingId: widget.weddingId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Timeline'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _phases.map((p) => Tab(text: _phaseLabel(p))).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<WeddingTimelineBloc, WeddingTimelineState>(
        builder: (context, state) => switch (state) {
          WeddingTimelineInitial() ||
          WeddingTimelineLoading() =>
            const Center(child: CircularProgressIndicator()),
          WeddingTimelineError(:final failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(failure.message),
                  ElevatedButton(
                    onPressed: () => context.read<WeddingTimelineBloc>().add(
                          WeddingTimelineLoadRequested(weddingId: widget.weddingId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          WeddingTimelineLoaded(:final timeline, :final isUpdating) =>
            Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: _phases.map((phase) {
                    final tasks =
                        timeline.tasksByPhase[phase] ?? [];
                    if (tasks.isEmpty) {
                      return Center(
                        child: Text('No tasks for ${_phaseLabel(phase)}'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: tasks.length,
                      itemBuilder: (context, i) => TimelineTaskTile(
                        task: tasks[i],
                        onCompletedChanged: (isCompleted) =>
                            context.read<WeddingTimelineBloc>().add(
                                  WeddingTimelineTaskCompleted(
                                    taskId: tasks[i].id,
                                    isCompleted: isCompleted,
                                  ),
                                ),
                      ),
                    );
                  }).toList(),
                ),
                if (isUpdating)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                // Completion summary
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _CompletionBar(timeline: timeline),
                ),
              ],
            ),
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedPhase = _phases.first.name;
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));
    int priority = 2;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Task'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title *'),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPhase,
                    items: _phases
                        .map((p) => DropdownMenuItem(
                              value: p.name,
                              child: Text(_phaseLabel(p)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedPhase = v ?? _phases.first.name),
                    decoration: const InputDecoration(labelText: 'Phase'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                context.read<WeddingTimelineBloc>().add(WeddingTimelineTaskAdded(
                      title: titleCtrl.text,
                      phase: selectedPhase,
                      dueDate: dueDate,
                      description: descCtrl.text.isEmpty ? null : descCtrl.text,
                      priority: priority,
                    ));
                Navigator.of(ctx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(TimelinePhase p) => switch (p) {
        TimelinePhase.planning => 'Planning',
        TimelinePhase.booking => 'Booking',
        TimelinePhase.confirmed => 'Confirmed',
        TimelinePhase.preparation => 'Preparation',
        TimelinePhase.dayOf => 'Day Of',
        TimelinePhase.postWedding => 'Post-Wedding',
      };
}

class _CompletionBar extends StatelessWidget {
  final WeddingTimelineEntity timeline;
  const _CompletionBar({required this.timeline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${timeline.completedCount}/${timeline.totalCount} done',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: timeline.completionRate,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(timeline.completionRate * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
