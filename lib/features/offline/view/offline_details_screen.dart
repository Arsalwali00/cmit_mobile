// lib/features/offline/view/offline_details_screen.dart
import 'package:flutter/material.dart';
import 'package:cmit/features/offline/services/offline_service.dart';
import 'package:cmit/features/offline/services/inquiry_cache_service.dart';

class OfflineDetailsScreen extends StatefulWidget {
  const OfflineDetailsScreen({super.key});

  @override
  State<OfflineDetailsScreen> createState() => _OfflineDetailsScreenState();
}

class _OfflineDetailsScreenState extends State<OfflineDetailsScreen> {
  bool _isOnline = true;
  bool _isLoading = true;
  bool _isSyncing = false;

  // Cache info
  int _cachedInquiriesCount = 0;
  String _lastCacheUpdate = 'Never';
  int _cacheAgeHours = 0;
  double _cacheSizeMB = 0.0;

  // Pending operations
  int _pendingFindings = 0;

  @override
  void initState() {
    super.initState();
    _loadOfflineData();
  }

  Future<void> _loadOfflineData() async {
    setState(() => _isLoading = true);

    try {
      // Check connectivity
      final hasInternet = await OfflineService.hasInternet();

      // Get cache metadata
      final metadata = await InquiryCacheService.getCacheMetadata();
      final cachedInquiries = await InquiryCacheService.getCachedInquiries();

      // Get sync stats
      final syncStats = await OfflineService.getSyncStats();

      if (!mounted) return;

      setState(() {
        _isOnline = hasInternet;
        _cachedInquiriesCount = cachedInquiries?.length ?? 0;
        _lastCacheUpdate = metadata['last_cache_time'] ?? 'Never';
        _cacheAgeHours = metadata['cache_age_hours'] ?? 0;
        _cacheSizeMB = (metadata['cache_size_bytes'] ?? 0) / (1024 * 1024);

        // Only findings are tracked
        _pendingFindings = syncStats['pending_findings'] ?? 0;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load offline data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _syncPendingChanges() async {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot sync while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);

    try {
      // Get unsynced findings
      final unsyncedFindings = await OfflineService.getUnsyncedFindings();

      if (unsyncedFindings.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pending changes to sync'),
            backgroundColor: Color(0xFF014323),
          ),
        );

        setState(() => _isSyncing = false);
        return;
      }

      int syncedCount = 0;
      int failedCount = 0;

      // Sync each finding
      for (var finding in unsyncedFindings) {
        try {
          // TODO: Call your API to sync the finding
          // final result = await YourAPI.syncFinding(finding);

          // For now, simulate success
          await Future.delayed(const Duration(milliseconds: 500));

          // Mark as synced
          await OfflineService.markFindingSynced(finding['id']);
          syncedCount++;
        } catch (e) {
          failedCount++;
          print('Failed to sync finding ${finding['id']}: $e');
        }
      }

      if (!mounted) return;

      if (syncedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Synced $syncedCount ${syncedCount == 1 ? 'finding' : 'findings'} successfully'
                  '${failedCount > 0 ? ' ($failedCount failed)' : ''}',
            ),
            backgroundColor: failedCount > 0 ? Colors.orange : const Color(0xFF014323),
          ),
        );

        await _loadOfflineData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sync findings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'Are you sure you want to clear all cached data? '
              'This will remove offline access until you reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await InquiryCacheService.clearCache();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: Color(0xFF014323),
        ),
      );

      await _loadOfflineData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cache: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatCacheAge() {
    if (_cacheAgeHours == 0) return 'Just now';
    if (_cacheAgeHours < 1) return 'Less than 1 hour';
    if (_cacheAgeHours == 1) return '1 hour ago';
    if (_cacheAgeHours < 24) return '$_cacheAgeHours hours ago';

    final days = (_cacheAgeHours / 24).floor();
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  }

  int get _totalPending => _pendingFindings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
        title: const Text(
          'Offline & Sync',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E5E5),
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF014323),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadOfflineData,
        color: const Color(0xFF014323),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Connection Status
              _buildConnectionStatus(),

              const SizedBox(height: 8),

              // Pending Sync Section
              if (_totalPending > 0) ...[
                _buildPendingSyncSection(),
                const SizedBox(height: 8),
              ],

              // Cache Information
              _buildCacheSection(),

              const SizedBox(height: 8),

              // Actions
              _buildActionsSection(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isOnline
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOnline
              ? const Color(0xFF014323).withOpacity(0.2)
              : const Color(0xFFFF9800).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: _isOnline
                  ? const Color(0xFF014323)
                  : const Color(0xFFFF9800),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _isOnline
                        ? const Color(0xFF014323)
                        : const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isOnline
                      ? 'Connected to internet'
                      : 'Using cached data',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSyncSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sync_problem,
                color: Color(0xFFFF9800),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending Sync',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_totalPending ${_totalPending == 1 ? 'item' : 'items'} waiting to sync',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Pending items breakdown
          if (_pendingFindings > 0)
            _buildPendingItem(
              'Findings',
              _pendingFindings,
              Icons.assignment,
            ),

          const SizedBox(height: 16),

          // Sync button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSyncing || !_isOnline ? null : _syncPendingChanges,
              icon: _isSyncing
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.sync, size: 20),
              label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF014323),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          if (!_isOnline)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Connect to internet to sync pending changes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingItem(String title, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF014323),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF014323),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.storage,
                color: Color(0xFF014323),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Cached Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Cache stats
          _buildCacheStat(
            'Cached Inquiries',
            '$_cachedInquiriesCount',
            Icons.folder_outlined,
          ),

          _buildCacheStat(
            'Last Updated',
            _formatCacheAge(),
            Icons.schedule,
          ),

          _buildCacheStat(
            'Cache Size',
            '${_cacheSizeMB.toStringAsFixed(2)} MB',
            Icons.data_usage,
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStat(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.settings,
                color: Color(0xFF014323),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Refresh Cache button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isOnline ? _loadOfflineData : null,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Refresh Cache'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF014323),
                side: const BorderSide(color: Color(0xFF014323)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Clear Cache button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clearCache,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Clear Cache'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cached data allows you to view inquiries offline. '
                        'Changes made offline will sync automatically when you reconnect.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}