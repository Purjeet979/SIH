import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_helper.dart';
import 'sync_service.dart';
import 'theme.dart';
import 'login_page.dart';

class AdminDashboardView extends StatefulWidget {
  final VoidCallback? onSwitchRole;
  const AdminDashboardView({super.key, this.onSwitchRole});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> with SingleTickerProviderStateMixin {
  String _selectedZoneFilter = 'All';
  String _officerSearchQuery = '';
  int _localScansCount = 0;
  bool _isSyncing = false;

  // Tab 1 & Tab 2 item limit filters: 5, 10, or -1 (All)
  int _zoneLimit = 5;
  int _officerLimit = 5;

  late TabController _tabController;

  // Complete list of 10 surveillance zones across the state
  final List<ZoneStat> _zones = [
    ZoneStat(
      id: 'z1',
      name: 'Central Commercial Hub',
      districtCode: 'DL-CENTRAL-01',
      officersCount: 6,
      totalScans: 486,
      violationsCount: 68,
      topRiskCategory: 'Packaged Snacks & Dairy',
      complianceRate: 86.0,
      riskLevel: 'Moderate',
      monthlyTarget: 550,
    ),
    ZoneStat(
      id: 'z2',
      name: 'South District Retail Corridor',
      districtCode: 'DL-SOUTH-04',
      officersCount: 5,
      totalScans: 374,
      violationsCount: 32,
      topRiskCategory: 'Cosmetics & Personal Care',
      complianceRate: 91.4,
      riskLevel: 'Low',
      monthlyTarget: 400,
    ),
    ZoneStat(
      id: 'z3',
      name: 'West Industrial & Logistics Hub',
      districtCode: 'DL-WEST-07',
      officersCount: 5,
      totalScans: 312,
      violationsCount: 54,
      topRiskCategory: 'Edible Oils & Commodities',
      complianceRate: 82.7,
      riskLevel: 'High',
      monthlyTarget: 380,
    ),
    ZoneStat(
      id: 'z4',
      name: 'North Wholesale Mandi Zone',
      districtCode: 'DL-NORTH-02',
      officersCount: 4,
      totalScans: 256,
      violationsCount: 14,
      topRiskCategory: 'Grains, Pulses & Spices',
      complianceRate: 94.5,
      riskLevel: 'Low',
      monthlyTarget: 300,
    ),
    ZoneStat(
      id: 'z5',
      name: 'East E-Commerce Fulfillment Belt',
      districtCode: 'DL-EAST-09',
      officersCount: 4,
      totalScans: 218,
      violationsCount: 39,
      topRiskCategory: 'Imported Electronics & Toys',
      complianceRate: 82.1,
      riskLevel: 'High',
      monthlyTarget: 260,
    ),
    ZoneStat(
      id: 'z6',
      name: 'Airport & Air Cargo SEZ',
      districtCode: 'DL-SW-11',
      officersCount: 4,
      totalScans: 195,
      violationsCount: 22,
      topRiskCategory: 'Imported Food Packages',
      complianceRate: 88.7,
      riskLevel: 'Moderate',
      monthlyTarget: 220,
    ),
    ZoneStat(
      id: 'z7',
      name: 'Okhla Industrial Cluster',
      districtCode: 'DL-SE-05',
      officersCount: 3,
      totalScans: 178,
      violationsCount: 31,
      topRiskCategory: 'Pre-Packaged Hardware',
      complianceRate: 82.6,
      riskLevel: 'High',
      monthlyTarget: 200,
    ),
    ZoneStat(
      id: 'z8',
      name: 'Mayapuri Wholesale Enclave',
      districtCode: 'DL-WEST-03',
      officersCount: 3,
      totalScans: 164,
      violationsCount: 18,
      topRiskCategory: 'Beverages & Syrups',
      complianceRate: 89.0,
      riskLevel: 'Moderate',
      monthlyTarget: 180,
    ),
    ZoneStat(
      id: 'z9',
      name: 'Rohini Retail Sub-District',
      districtCode: 'DL-NW-08',
      officersCount: 3,
      totalScans: 142,
      violationsCount: 12,
      topRiskCategory: 'Confectionery & Sweets',
      complianceRate: 91.5,
      riskLevel: 'Low',
      monthlyTarget: 160,
    ),
    ZoneStat(
      id: 'z10',
      name: 'Narela Grain Mandi Terminal',
      districtCode: 'DL-NORTH-06',
      officersCount: 3,
      totalScans: 130,
      violationsCount: 9,
      topRiskCategory: 'Bulk Packaged Staples',
      complianceRate: 93.1,
      riskLevel: 'Low',
      monthlyTarget: 150,
    ),
  ];

  // Complete roster of officers
  final List<OfficerProfile> _officers = [
    OfficerProfile(
      id: 'off_001',
      name: 'Insp. Rajesh Sharma',
      badgeNo: 'LM-DL-104',
      zoneName: 'Central Commercial Hub',
      scansCount: 142,
      scansToday: 16,
      violationsFound: 19,
      status: 'Active on Field',
      phone: '+91 98101 23456',
      lastActive: '12m ago',
      avatarColor: const Color(0xFF2563EB),
    ),
    OfficerProfile(
      id: 'off_002',
      name: 'Insp. Anita Desai',
      badgeNo: 'LM-DL-219',
      zoneName: 'West Industrial & Logistics Hub',
      scansCount: 128,
      scansToday: 14,
      violationsFound: 23,
      status: 'Active on Field',
      phone: '+91 98202 34567',
      lastActive: '5m ago',
      avatarColor: const Color(0xFF7C3AED),
    ),
    OfficerProfile(
      id: 'off_003',
      name: 'Insp. Vikram Malhotra',
      badgeNo: 'LM-DL-308',
      zoneName: 'Central Commercial Hub',
      scansCount: 116,
      scansToday: 11,
      violationsFound: 15,
      status: 'Active on Field',
      phone: '+91 98303 45678',
      lastActive: '22m ago',
      avatarColor: const Color(0xFF059669),
    ),
    OfficerProfile(
      id: 'off_004',
      name: 'Insp. Priya Nair',
      badgeNo: 'LM-DL-412',
      zoneName: 'South District Retail Corridor',
      scansCount: 104,
      scansToday: 9,
      violationsFound: 8,
      status: 'Reporting',
      phone: '+91 98404 56789',
      lastActive: '45m ago',
      avatarColor: const Color(0xFFD97706),
    ),
    OfficerProfile(
      id: 'off_005',
      name: 'Insp. Amit Patel',
      badgeNo: 'LM-DL-515',
      zoneName: 'East E-Commerce Fulfillment Belt',
      scansCount: 98,
      scansToday: 13,
      violationsFound: 18,
      status: 'Active on Field',
      phone: '+91 98505 67890',
      lastActive: '8m ago',
      avatarColor: const Color(0xFFDC2626),
    ),
    OfficerProfile(
      id: 'off_006',
      name: 'Insp. Sunita Rao',
      badgeNo: 'LM-DL-620',
      zoneName: 'North Wholesale Mandi Zone',
      scansCount: 92,
      scansToday: 7,
      violationsFound: 6,
      status: 'Active on Field',
      phone: '+91 98606 78901',
      lastActive: '18m ago',
      avatarColor: const Color(0xFF0891B2),
    ),
    OfficerProfile(
      id: 'off_007',
      name: 'Insp. Harish Chandra',
      badgeNo: 'LM-DL-725',
      zoneName: 'South District Retail Corridor',
      scansCount: 88,
      scansToday: 10,
      violationsFound: 9,
      status: 'Active on Field',
      phone: '+91 98707 89012',
      lastActive: '30m ago',
      avatarColor: const Color(0xFF4F46E5),
    ),
    OfficerProfile(
      id: 'off_008',
      name: 'Insp. Meenakshi Joshi',
      badgeNo: 'LM-DL-833',
      zoneName: 'West Industrial & Logistics Hub',
      scansCount: 84,
      scansToday: 0,
      violationsFound: 14,
      status: 'Off Duty',
      phone: '+91 98808 90123',
      lastActive: 'Yesterday',
      avatarColor: const Color(0xFF64748B),
    ),
    OfficerProfile(
      id: 'off_009',
      name: 'Insp. Rakesh Gupta',
      badgeNo: 'LM-DL-901',
      zoneName: 'Airport & Air Cargo SEZ',
      scansCount: 78,
      scansToday: 8,
      violationsFound: 11,
      status: 'Active on Field',
      phone: '+91 98909 01234',
      lastActive: '15m ago',
      avatarColor: const Color(0xFF0284C7),
    ),
    OfficerProfile(
      id: 'off_010',
      name: 'Insp. Kavita Singhania',
      badgeNo: 'LM-DL-915',
      zoneName: 'Okhla Industrial Cluster',
      scansCount: 74,
      scansToday: 6,
      violationsFound: 12,
      status: 'Active on Field',
      phone: '+91 99010 12345',
      lastActive: '40m ago',
      avatarColor: const Color(0xFF9333EA),
    ),
    OfficerProfile(
      id: 'off_011',
      name: 'Insp. Deepak Verma',
      badgeNo: 'LM-DL-928',
      zoneName: 'Mayapuri Wholesale Enclave',
      scansCount: 68,
      scansToday: 5,
      violationsFound: 7,
      status: 'Active on Field',
      phone: '+91 99111 23456',
      lastActive: '50m ago',
      avatarColor: const Color(0xFF16A34A),
    ),
    OfficerProfile(
      id: 'off_012',
      name: 'Insp. Pooja Agarwal',
      badgeNo: 'LM-DL-942',
      zoneName: 'Rohini Retail Sub-District',
      scansCount: 65,
      scansToday: 4,
      violationsFound: 5,
      status: 'Reporting',
      phone: '+91 99222 34567',
      lastActive: '1h ago',
      avatarColor: const Color(0xFFEA580C),
    ),
    OfficerProfile(
      id: 'off_013',
      name: 'Insp. Sanjay Kulkarni',
      badgeNo: 'LM-DL-955',
      zoneName: 'Narela Grain Mandi Terminal',
      scansCount: 61,
      scansToday: 5,
      violationsFound: 4,
      status: 'Active on Field',
      phone: '+91 99333 45678',
      lastActive: '25m ago',
      avatarColor: const Color(0xFF0D9488),
    ),
    OfficerProfile(
      id: 'off_014',
      name: 'Insp. Neha Srivastava',
      badgeNo: 'LM-DL-968',
      zoneName: 'Central Commercial Hub',
      scansCount: 58,
      scansToday: 3,
      violationsFound: 6,
      status: 'Off Duty',
      phone: '+91 99444 56789',
      lastActive: 'Yesterday',
      avatarColor: const Color(0xFF6B7280),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLocalScansCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalScansCount() async {
    try {
      final db = await DBHelper.instance.database;
      final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM inspections');
      if (result.isNotEmpty && mounted) {
        setState(() {
          _localScansCount = (result.first['cnt'] as int?) ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _performSync() async {
    setState(() => _isSyncing = true);
    final msg = await SyncService.syncOfflineData();
    await _loadLocalScansCount();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: msg.contains('✅') ? AppTheme.passGreenText : AppTheme.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showReassignDialog(OfficerProfile officer) {
    String selectedZone = officer.zoneName;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlueLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.transfer_within_a_station, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Reassign Officer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign ${officer.name} (${officer.badgeNo}) to another surveillance zone:',
                style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderSubtle),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedZone,
                    isExpanded: true,
                    items: _zones.map((z) => DropdownMenuItem(value: z.name, child: Text(z.name, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedZone = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textTertiary)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final idx = _officers.indexWhere((o) => o.id == officer.id);
                  if (idx != -1) {
                    _officers[idx] = officer.copyWith(zoneName: selectedZone);
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${officer.name} reassigned to $selectedZone'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppTheme.violationRed, size: 22),
            SizedBox(width: 8),
            Text('Export Audit Dossier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Download official State Legal Metrology Audit Dossier including zonal surveillance targets and officer enforcement records.',
          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📄 Generating State Audit Dossier (PDF)...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out Admin Portal?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('You will return to the login screen where you can switch roles.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Stay')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onSwitchRole != null) {
                widget.onSwitchRole!();
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.violationRed),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalOfficers = _officers.length + 10; // 24 total field officers
    final int activeOfficers = _officers.where((o) => o.status == 'Active on Field').length + 9; // 19 active
    final int totalScans = _zones.fold(0, (sum, z) => sum + z.totalScans) + _localScansCount;
    final int totalViolations = _zones.fold(0, (sum, z) => sum + z.violationsCount);

    final allFilteredZones = _selectedZoneFilter == 'All'
        ? _zones
        : _zones.where((z) => z.name.toLowerCase().contains(_selectedZoneFilter.toLowerCase())).toList();

    // Apply 5 / 10 / All limit to zones
    final displayedZones = (_zoneLimit == -1 || _zoneLimit >= allFilteredZones.length)
        ? allFilteredZones
        : allFilteredZones.take(_zoneLimit).toList();

    final allFilteredOfficers = _officers.where((o) {
      final matchesSearch = o.name.toLowerCase().contains(_officerSearchQuery.toLowerCase()) ||
          o.badgeNo.toLowerCase().contains(_officerSearchQuery.toLowerCase()) ||
          o.zoneName.toLowerCase().contains(_officerSearchQuery.toLowerCase());
      final matchesZone = _selectedZoneFilter == 'All' || o.zoneName.toLowerCase().contains(_selectedZoneFilter.toLowerCase());
      return matchesSearch && matchesZone;
    }).toList();

    // Apply 5 / 10 / All limit to officers
    final displayedOfficers = (_officerLimit == -1 || _officerLimit >= allFilteredOfficers.length)
        ? allFilteredOfficers
        : allFilteredOfficers.take(_officerLimit).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar for Admin (Completely overflow-proof)
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Admin Command',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFC7D2FE)),
                                    ),
                                    child: const Text('HQ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF4338CA))),
                                  ),
                                ],
                              ),
                              const Text(
                                'Legal Metrology Surveillance',
                                style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          icon: _isSyncing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.sync, color: AppTheme.primaryBlue, size: 22),
                          tooltip: 'Sync Field Data',
                          onPressed: _isSyncing ? null : _performSync,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.logout_rounded, color: AppTheme.textTertiary, size: 22),
                          tooltip: 'Sign Out / Switch Role',
                          onPressed: _confirmSignOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Executive Surveillance Banner (Uses Wrap to never overflow)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: AppTheme.passGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppTheme.passGreen.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle, color: AppTheme.passGreen, size: 7),
                                    SizedBox(width: 5),
                                    Text('NETWORK LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.passGreen)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _showExportReportDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.download, color: Colors.white, size: 13),
                                      SizedBox(width: 4),
                                      Text('Export Dossier', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Statewide Surveillance',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Oversight of 10 industrial/retail zones & 24 field enforcement officers.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Top 4 Stat Cards (Zero overflow with Expanded title and FittedBox value)
                    Row(
                      children: [
                        Expanded(
                          child: _SurveillanceStatCard(
                            title: 'Field Force',
                            value: '$totalOfficers',
                            subValue: '$activeOfficers on duty',
                            subPositive: true,
                            icon: Icons.badge_outlined,
                            iconColor: const Color(0xFF2563EB),
                            bgColor: const Color(0xFFEFF6FF),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SurveillanceStatCard(
                            title: 'Total Scans',
                            value: '$totalScans',
                            subValue: '+${_localScansCount + 72} today',
                            subPositive: true,
                            icon: Icons.document_scanner_outlined,
                            iconColor: const Color(0xFF7C3AED),
                            bgColor: const Color(0xFFF3E8FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SurveillanceStatCard(
                            title: 'Violations',
                            value: '$totalViolations',
                            subValue: '${((totalViolations / (totalScans == 0 ? 1 : totalScans)) * 100).toStringAsFixed(1)}% rate',
                            subPositive: false,
                            icon: Icons.gavel_rounded,
                            iconColor: AppTheme.violationRed,
                            bgColor: AppTheme.violationRedLight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SurveillanceStatCard(
                            title: 'Active Zones',
                            value: '${_zones.length}',
                            subValue: '100% covered',
                            subPositive: true,
                            icon: Icons.map_outlined,
                            iconColor: AppTheme.passGreen,
                            bgColor: AppTheme.passGreenLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tab Bar: Concise labels ('Area Scans' and 'Officers') to never clip
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1)),
                          ],
                        ),
                        labelColor: AppTheme.primaryBlue,
                        unselectedLabelColor: AppTheme.textSecondary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Area Scans'))),
                          Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Officers'))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All Zones (${_zones.length})',
                            isSelected: _selectedZoneFilter == 'All',
                            onTap: () => setState(() => _selectedZoneFilter = 'All'),
                          ),
                          _FilterChip(
                            label: 'Central',
                            isSelected: _selectedZoneFilter == 'Central',
                            onTap: () => setState(() => _selectedZoneFilter = 'Central'),
                          ),
                          _FilterChip(
                            label: 'South',
                            isSelected: _selectedZoneFilter == 'South',
                            onTap: () => setState(() => _selectedZoneFilter = 'South'),
                          ),
                          _FilterChip(
                            label: 'West',
                            isSelected: _selectedZoneFilter == 'West',
                            onTap: () => setState(() => _selectedZoneFilter = 'West'),
                          ),
                          _FilterChip(
                            label: 'North',
                            isSelected: _selectedZoneFilter == 'North',
                            onTap: () => setState(() => _selectedZoneFilter = 'North'),
                          ),
                          _FilterChip(
                            label: 'East',
                            isSelected: _selectedZoneFilter == 'East',
                            onTap: () => setState(() => _selectedZoneFilter = 'East'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Area-Wise Scans with 5 / 10 / All filter
              _buildAreaWiseTab(allFilteredZones, displayedZones),

              // TAB 2: Officers Force with 5 / 10 / All filter
              _buildOfficersRosterTab(allFilteredOfficers, displayedOfficers),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Area-Wise Scans Breakdown ──
  Widget _buildAreaWiseTab(List<ZoneStat> allZones, List<ZoneStat> displayedZones) {
    if (allZones.isEmpty) {
      return const Center(child: Text('No surveillance areas match selected filter.'));
    }

    return Column(
      children: [
        // 5 / 10 / All Item Limit Filter (Completely overflow-proof)
        _buildLimitSelector(
          currentLimit: _zoneLimit,
          displayedCount: displayedZones.length,
          totalCount: allZones.length,
          itemLabel: 'zones',
          onLimitChanged: (val) => setState(() => _zoneLimit = val),
        ),

        // Zones List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
            itemCount: displayedZones.length + (displayedZones.length < allZones.length ? 1 : 0),
            itemBuilder: (context, index) {
              // Footer "See All" button when truncated
              if (index == displayedZones.length) {
                return _buildSeeAllFooter(
                  remainingCount: allZones.length - displayedZones.length,
                  itemLabel: 'zones',
                  onSeeAll: () => setState(() => _zoneLimit = -1),
                );
              }

              final zone = displayedZones[index];
              final progress = (zone.totalScans / zone.monthlyTarget).clamp(0.0, 1.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 1)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zone Header (Zero overflow)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: zone.riskLevel == 'High'
                                ? AppTheme.violationRedLight
                                : (zone.riskLevel == 'Moderate' ? AppTheme.pendingAmberLight : AppTheme.passGreenLight),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: zone.riskLevel == 'High'
                                ? AppTheme.violationRed
                                : (zone.riskLevel == 'Moderate' ? AppTheme.pendingAmber : AppTheme.passGreen),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zone.name,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${zone.districtCode} • ${zone.officersCount} Officers',
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textTertiary, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: zone.riskLevel == 'High'
                                ? AppTheme.violationRedLight
                                : (zone.riskLevel == 'Moderate' ? AppTheme.pendingAmberLight : AppTheme.passGreenLight),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${zone.riskLevel} Risk',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: zone.riskLevel == 'High'
                                  ? AppTheme.violationRed
                                  : (zone.riskLevel == 'Moderate' ? AppTheme.pendingAmberText : AppTheme.passGreenText),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Metrics Row (Each column is wrapped in Expanded to eliminate overflow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _ZoneMetric(label: 'Scans', value: '${zone.totalScans}')),
                          Container(width: 1, height: 20, color: AppTheme.borderSubtle),
                          Expanded(child: _ZoneMetric(label: 'Violations', value: '${zone.violationsCount}', isAlert: zone.violationsCount > 40)),
                          Container(width: 1, height: 20, color: AppTheme.borderSubtle),
                          Expanded(child: _ZoneMetric(label: 'Compliance', value: '${zone.complianceRate.toStringAsFixed(1)}%')),
                          Container(width: 1, height: 20, color: AppTheme.borderSubtle),
                          Expanded(child: _ZoneMetric(label: 'Target', value: '${zone.monthlyTarget}')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quota Progress Bar (Completely overflow-proof)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Quota: ${zone.totalScans}/${zone.monthlyTarget}',
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(progress * 100).toInt()}% Met',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppTheme.surfaceSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 0.85 ? AppTheme.passGreen : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Hotspot Category & View Officers Action
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 13, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Hotspot: ${zone.topRiskCategory}',
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedZoneFilter = zone.name.split(' ').first;
                              _tabController.animateTo(1);
                            });
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Officers', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                              Icon(Icons.chevron_right, size: 15, color: AppTheme.primaryBlue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Officers Force & Individual Scans ──
  Widget _buildOfficersRosterTab(List<OfficerProfile> allOfficers, List<OfficerProfile> displayedOfficers) {
    return Column(
      children: [
        // Officer Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: TextField(
            onChanged: (val) => setState(() => _officerSearchQuery = val),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search officer name, badge # or zone...',
              hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textTertiary),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textTertiary),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.borderSubtle),
              ),
            ),
          ),
        ),

        // 5 / 10 / All Item Limit Filter (Completely overflow-proof)
        _buildLimitSelector(
          currentLimit: _officerLimit,
          displayedCount: displayedOfficers.length,
          totalCount: allOfficers.length,
          itemLabel: 'officers',
          onLimitChanged: (val) => setState(() => _officerLimit = val),
        ),

        // Officers List
        Expanded(
          child: displayedOfficers.isEmpty
              ? const Center(child: Text('No officers match search criteria.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                  itemCount: displayedOfficers.length + (displayedOfficers.length < allOfficers.length ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Footer "See All" button when truncated
                    if (index == displayedOfficers.length) {
                      return _buildSeeAllFooter(
                        remainingCount: allOfficers.length - displayedOfficers.length,
                        itemLabel: 'officers',
                        onSeeAll: () => setState(() => _officerLimit = -1),
                      );
                    }

                    final officer = displayedOfficers[index];
                    final bool isActive = officer.status == 'Active on Field';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderSubtle),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Officer Info Row (Zero overflow)
                          Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: officer.avatarColor.withValues(alpha: 0.15),
                                    child: Text(
                                      officer.name.split(' ').last.substring(0, 1),
                                      style: TextStyle(color: officer.avatarColor, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isActive ? AppTheme.passGreen : Colors.grey,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${officer.name} (${officer.badgeNo})',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      officer.zoneName,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: isActive ? AppTheme.passGreenLight : AppTheme.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  officer.status,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? AppTheme.passGreenText : AppTheme.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Scans Done Stats (Both sides flex safely with zero overflow)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSubtle,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.document_scanner, size: 13, color: AppTheme.primaryBlue),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${officer.scansCount} Scans (+${officer.scansToday})',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, size: 13, color: AppTheme.violationRed),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          '${officer.violationsFound} Violations',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.violationRed),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Action: Reassign Zone & Last Active (Expanded ensures no overflow)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Active: ${officer.lastActive}',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _showReassignDialog(officer),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlueLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_location_alt, size: 11, color: AppTheme.primaryBlue),
                                      SizedBox(width: 3),
                                      Text('Reassign', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── 5 / 10 / All Limit Filter Selector (Completely overflow-proof with FittedBox and Segmented Control) ──
  Widget _buildLimitSelector({
    required int currentLimit,
    required int displayedCount,
    required int totalCount,
    required String itemLabel,
    required ValueChanged<int> onLimitChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Left side: Text wrapped in Expanded so it never pushes the right side off-screen
          Expanded(
            child: Text(
              'Showing $displayedCount of $totalCount $itemLabel',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Right side: Compact segmented control in FittedBox - mathematically impossible to overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              height: 26,
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LimitSegment(
                    label: '5',
                    isSelected: currentLimit == 5,
                    onTap: () => onLimitChanged(5),
                  ),
                  Container(width: 1, height: 14, color: AppTheme.borderSubtle),
                  _LimitSegment(
                    label: '10',
                    isSelected: currentLimit == 10,
                    onTap: () => onLimitChanged(10),
                  ),
                  Container(width: 1, height: 14, color: AppTheme.borderSubtle),
                  _LimitSegment(
                    label: 'All',
                    isSelected: currentLimit == -1,
                    onTap: () => onLimitChanged(-1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── "See All" Footer Banner (Zero overflow with GestureDetector) ──
  Widget _buildSeeAllFooter({
    required int remainingCount,
    required String itemLabel,
    required VoidCallback onSeeAll,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '+$remainingCount more $itemLabel available',
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'See All',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting Widgets ──

class _SurveillanceStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;
  final bool subPositive;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _SurveillanceStatCard({
    required this.title,
    required this.value,
    required this.subValue,
    required this.subPositive,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: subPositive ? AppTheme.passGreen : AppTheme.violationRed,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LimitSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LimitSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _LimitPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LimitPill({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceSubtle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ZoneMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const _ZoneMetric({required this.label, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isAlert ? AppTheme.violationRed : AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, color: AppTheme.textTertiary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Models ──

class ZoneStat {
  final String id;
  final String name;
  final String districtCode;
  final int officersCount;
  final int totalScans;
  final int violationsCount;
  final String topRiskCategory;
  final double complianceRate;
  final String riskLevel;
  final int monthlyTarget;

  const ZoneStat({
    required this.id,
    required this.name,
    required this.districtCode,
    required this.officersCount,
    required this.totalScans,
    required this.violationsCount,
    required this.topRiskCategory,
    required this.complianceRate,
    required this.riskLevel,
    required this.monthlyTarget,
  });
}

class OfficerProfile {
  final String id;
  final String name;
  final String badgeNo;
  final String zoneName;
  final int scansCount;
  final int scansToday;
  final int violationsFound;
  final String status;
  final String phone;
  final String lastActive;
  final Color avatarColor;

  const OfficerProfile({
    required this.id,
    required this.name,
    required this.badgeNo,
    required this.zoneName,
    required this.scansCount,
    required this.scansToday,
    required this.violationsFound,
    required this.status,
    required this.phone,
    required this.lastActive,
    required this.avatarColor,
  });

  OfficerProfile copyWith({String? zoneName, String? status}) {
    return OfficerProfile(
      id: id,
      name: name,
      badgeNo: badgeNo,
      zoneName: zoneName ?? this.zoneName,
      scansCount: scansCount,
      scansToday: scansToday,
      violationsFound: violationsFound,
      status: status ?? this.status,
      phone: phone,
      lastActive: lastActive,
      avatarColor: avatarColor,
    );
  }
}
