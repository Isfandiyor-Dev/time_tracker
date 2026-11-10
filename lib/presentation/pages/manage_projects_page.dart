import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../generated/locale_keys.g.dart';
import '../cubit/tracker_cubit.dart';
import '../widgets/app_surface.dart';
import 'project_editor_page.dart';

class ManageProjectsPage extends StatelessWidget {
  const ManageProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.projects_manageTitle.tr())),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-project',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProjectEditorPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(LocaleKeys.home_addProject.tr()),
      ),
      body: BlocBuilder<TrackerCubit, TrackerState>(
        builder: (context, state) {
          if (state.projects.isEmpty) {
            return Center(
              child: Text(
                LocaleKeys.projects_emptyMessage.tr(),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: state.projects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final project = state.projects[index];
              return AppSurface(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectEditorPage(project: project),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        color: AppColors.lime,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            LocaleKeys.projects_perHour.tr(
                              namedArgs: {
                                'rate': formatMoney(
                                  project.hourlyRate,
                                  project.currency,
                                ),
                              },
                            ),
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
