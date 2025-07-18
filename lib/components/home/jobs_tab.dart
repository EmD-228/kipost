import 'package:flutter/material.dart';
import 'package:kipost/components/jobs/jobs_widgets.dart';

class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  late final JobsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = JobsController();
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _handleError(dynamic error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Barre d'en-tête avec recherche et filtres
          JobsAppBar(
            search: _controller.search,
            categories: _controller.categories,
            selectedCategoryId: _controller.selectedCategoryId,
            onSearchChanged: (value) async {
              try {
                await _controller.onSearchChanged(value);
              } catch (e) {
                _handleError(e);
              }
            },
            onCategoryChanged: (categoryName) async {
              try {
                await _controller.onCategoryChanged(categoryName);
              } catch (e) {
                _handleError(e);
              }
            },
          ),

          // Liste des annonces
          AnnouncementsList(
            announcements: _controller.announcements,
            isLoading: _controller.isLoading,
            isEmpty: _controller.announcements.isEmpty && !_controller.isLoading,
          ),

          // Contrôles de pagination
          SliverToBoxAdapter(
            child: PaginationControls(
              isLoading: _controller.isLoading,
              hasNextPage: _controller.hasNextPage,
              hasPreviousPage: _controller.hasPreviousPage,
              paginationInfo: _controller.paginationInfo,
              announcementsCount: _controller.announcements.length,
              onPreviousPage: () async {
                try {
                  await _controller.previousPage();
                } catch (e) {
                  _handleError(e);
                }
              },
              onNextPage: () async {
                try {
                  await _controller.nextPage();
                } catch (e) {
                  _handleError(e);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
