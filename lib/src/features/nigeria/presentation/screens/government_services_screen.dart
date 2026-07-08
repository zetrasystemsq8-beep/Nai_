import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import '../providers/government_provider.dart';
import '../widgets/service_card.dart';

class GovernmentServicesScreen extends ConsumerWidget {
  const GovernmentServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(allServicesProvider);
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      appBar: const AppTopBar(title: 'Government Services'),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: services.when(
          data: (serviceList) => serviceList.isEmpty
              ? Center(
                  child: AppEmptyState(
                    title: 'No Services Available',
                    subtitle: 'Check back later',
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.md.w),
                  itemCount: serviceList.length,
                  itemBuilder: (context, index) => ServiceCard(
                    service: serviceList[index],
                    onTap: () {
                      showGlobalToast(
                        message: 'Service selected',
                        status: 'success',
                      );
                    },
                  ),
                ),
          loading: () => const Center(child: AppLoading()),
          error: (error, stack) => Center(
            child: AppErrorWidget(
              title: 'Error loading services',
              message: error.toString(),
              onRetry: () => ref.refresh(allServicesProvider),
            ),
          ),
        ),
      ),
    );
  }
}
