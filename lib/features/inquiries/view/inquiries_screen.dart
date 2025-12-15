// lib/features/inquiries/view/inquiries_screen.dart - WITH OFFLINE NAVIGATION
import 'package:flutter/material.dart';
import 'package:cmit/core/assign_to_me.dart';
import 'package:cmit/features/inquiries/view/inquiry_card.dart';
import 'package:cmit/features/inquiries/view/inquiry_details_screen.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';
import 'package:cmit/features/offline/services/offline_service.dart';
import 'package:cmit/features/offline/services/inquiry_cache_service.dart';
import 'package:cmit/features/offline/widgets/offline_indicator.dart';
import 'package:cmit/features/offline/view/offline_details_screen.dart';
import 'package:cmit/features/offline/view/offline_inquiry_detail_screen.dart'; // ADD THIS IMPORT

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  List<AssignToMeModel> _inquiries = [];
  List<AssignToMeModel> _filtered = [];
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isFromCache = false;
  String _error = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoad();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Check connectivity and load data accordingly
  Future<void> _checkConnectivityAndLoad() async {
    final hasInternet = await OfflineService.hasInternet();

    setState(() {
      _isOnline = hasInternet;
      _isLoading = true;
    });

    if (hasInternet) {
      await _loadFromAPI();
    } else {
      await _loadFromCache();
    }
  }

  /// Load data from API
  Future<void> _loadFromAPI() async {
    try {
      final result = await AssignToMe.getAssignedInquiries();

      if (!mounted) return;

      if (result['success'] == true) {
        final inquiries = result['inquiries'] as List<AssignToMeModel>;

        // Cache the fresh data
        await InquiryCacheService.cacheInquiries(inquiries);

        setState(() {
          _isLoading = false;
          _isFromCache = false;
          _inquiries = inquiries;
          _filtered = List.from(_inquiries);
          _error = '';
        });
      } else {
        // API error - fallback to cache
        await _loadFromCache();
      }
    } catch (e) {
      // Network error - fallback to cache
      if (!mounted) return;
      await _loadFromCache();
    }
  }

  /// Load data from cache
  Future<void> _loadFromCache() async {
    try {
      final cachedInquiries = await InquiryCacheService.getCachedInquiries();

      if (!mounted) return;

      if (cachedInquiries != null && cachedInquiries.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _isFromCache = true;
          _inquiries = cachedInquiries;
          _filtered = List.from(_inquiries);
          _error = '';
        });

        // No snackbar popup - info shown in banner
      } else {
        // No cache available
        setState(() {
          _isLoading = false;
          _isFromCache = false;
          _error = _isOnline
              ? 'Failed to load inquiries'
              : 'No offline data available. Please connect to internet.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isFromCache = false;
        _error = 'Failed to load data';
      });
    }
  }

  /// Show cache information dialog (only when user taps info icon)
  Future<void> _showCacheInfo() async {
    if (!mounted) return;

    final metadata = await InquiryCacheService.getCacheMetadata();
    final ageHours = metadata['cache_age_hours'] as int?;

    String message = 'Viewing cached data';
    if (ageHours != null) {
      if (ageHours < 1) {
        message = 'Cache is less than 1 hour old';
      } else if (ageHours == 1) {
        message = 'Cache is 1 hour old';
      } else if (ageHours < 24) {
        message = 'Cache is $ageHours hours old';
      } else {
        final days = (ageHours / 24).floor();
        message = 'Cache is $days ${days == 1 ? 'day' : 'days'} old';
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF014323), size: 24),
              SizedBox(width: 12),
              Text('Cache Information'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(
                'You are viewing offline data. Connect to internet to get the latest updates.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF014323),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Manual refresh
  Future<void> _loadInquiries() async {
    final hasInternet = await OfflineService.hasInternet();

    setState(() => _isOnline = hasInternet);

    if (hasInternet) {
      await _loadFromAPI();
    } else {
      await _loadFromCache();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Showing cached data.'),
          backgroundColor: Color(0xFF014323),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _filter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = query.isEmpty
          ? List.from(_inquiries)
          : _inquiries.where((i) {
        return i.title.toLowerCase().contains(query) ||
            i.department.toLowerCase().contains(query) ||
            i.initiator.toLowerCase().contains(query) ||
            i.assignedTo.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Navigate to offline details when offline banner is tapped
  void _navigateToOfflineDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OfflineDetailsScreen(),
      ),
    ).then((_) {
      // Refresh data after returning
      _checkConnectivityAndLoad();
    });
  }

  /// Navigate to inquiry details - UPDATED TO CHECK ONLINE STATUS
  Future<void> _navigateToInquiryDetails(AssignToMeModel inquiry) async {
    final hasInternet = await OfflineService.hasInternet();

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => hasInternet
            ? InquiryDetailsScreen(inquiry: inquiry) // Online: regular screen
            : OfflineInquiryDetailsScreen(inquiry: inquiry), // Offline: read-only screen
      ),
    );

    // Refresh if changes were made (only possible when online)
    if (result == true) {
      _loadInquiries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Inquiries',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Show cache indicator
          if (_isFromCache)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF014323),
                  size: 22,
                ),
                onPressed: _showCacheInfo,
                tooltip: 'Cache Info',
              ),
            ),
          // Offline settings button
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF014323),
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OfflineDetailsScreen(),
                ),
              ).then((_) {
                // Reload after returning
                _checkConnectivityAndLoad();
              });
            },
            tooltip: 'Offline & Sync',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E5E5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Offline Indicator (for pending syncs)
          const OfflineIndicator(),

          // Offline Mode Banner - NOW TAPPABLE
          if (!_isOnline && _isFromCache)
            InkWell(
              onTap: _navigateToOfflineDetails,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFFFF3E0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 18,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offline Mode',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Viewing cached data. Tap for details.',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFFFF9800).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFFFF9800),
                    ),
                  ],
                ),
              ),
            ),

          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search by title, department, or person...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF014323),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF014323),
              ),
            )
                : _error.isNotEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isOnline
                          ? Icons.error_outline
                          : Icons.cloud_off_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadInquiries,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(_isOnline ? 'Retry' : 'Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014323),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No inquiries assigned'
                        : 'No inquiries found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadInquiries,
              color: const Color(0xFF014323),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final inquiry = _filtered[i];
                  return InquiryCard(
                    inquiry: inquiry,
                    onTap: () => _navigateToInquiryDetails(inquiry), // UPDATED
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}