import 'dart:async';
import 'dart:math';
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_state.dart';

class SearchResultItem {
  final String id;
  final String name;
  final String type;
  final IconData iconData;
  final String description;
  final DateTime lastModified;
  final Color itemColor;
  final Map<String, String> details;

  SearchResultItem({
    required this.id,
    required this.name,
    required this.type,
    required this.iconData,
    required this.description,
    required this.lastModified,
    required this.itemColor,
    required this.details,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _pageIsLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  bool _isSearching = false;
  List<SearchResultItem> _searchResults = [];
  bool _searchPerformed = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final newText = _searchController.text;
      if (_searchText != newText) {
        setState(() {
          _searchText = newText;
        });
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          if (_searchText.length > 1 || _searchText.isEmpty) {
            _performSearch(_searchText);
          } else if (_searchText.length <= 1 && _searchPerformed) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
              _searchPerformed = false;
            });
          }
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _pageIsLoading = false);
    });
  }

  List<SearchResultItem> _getAllSearchableItems(BuildContext context) {
    final l10n = context.l10n;
    return [
      SearchResultItem(
          id: 'srch-001',
          name: 'لپ‌تاپ Dell XPS 15 (سری جدید)',
          type: l10n.searchItemTypeElectronics,
          iconData: Icons.laptop_mac_outlined,
          description: l10n.searchItemDescLaptop,
          lastModified: DateTime.now().subtract(const Duration(days: 5)),
          itemColor: Colors.blueAccent.shade400,
          details: {
            l10n.assetDetailCpu: 'Core i9 13th Gen',
            l10n.assetDetailRam: '32GB DDR5',
            l10n.assetDetailStorage: '1TB NVMe SSD',
            l10n.assetDetailAssetCode: 'LP-00125',
            l10n.assetDetailStatus: 'فعال'
          }),
      SearchResultItem(
          id: 'srch-002',
          name: 'قرارداد نگهداری و پشتیبانی نرم‌افزار CRM',
          type: l10n.searchItemTypeLegal,
          iconData: Icons.article_outlined,
          description: l10n.searchItemDescContract,
          lastModified: DateTime.now().subtract(const Duration(days: 22)),
          itemColor: Colors.green.shade600,
          details: {
            l10n.assetDetailContractNo: 'CRM-SUP-2024',
            l10n.assetDetailContractor: 'شرکت راهکاران پویا',
            l10n.assetDetailExpiryDate: '1404/08/15',
            l10n.assetDetailAmount: '۲۵۰،۰۰۰،۰۰۰ ریال'
          }),
      SearchResultItem(
          id: 'srch-003',
          name: 'دوربین نظارتی محوطه شمالی',
          type: l10n.searchItemTypeSecurity,
          iconData: Icons.videocam_outlined,
          description: l10n.searchItemDescCamera,
          lastModified: DateTime.now().subtract(const Duration(hours: 72)),
          itemColor: Colors.redAccent.shade400,
          details: {
            l10n.assetDetailModel: 'Hikvision DS-2CD2T47G2',
            l10n.assetDetailResolution: '4MP',
            l10n.assetDetailRecordStatus: '24/7',
            l10n.assetDetailLastService: '1403/02/10'
          }),
      SearchResultItem(
          id: 'srch-004',
          name: 'پرینتر چندکاره HP OfficeJet Pro',
          type: l10n.searchItemTypeOffice,
          iconData: Icons.print_outlined,
          description: l10n.searchItemDescPrinter,
          lastModified: DateTime.now().subtract(const Duration(days: 15)),
          itemColor: Colors.cyanAccent.shade700,
          details: {
            l10n.assetDetailModel: 'HP OfficeJet Pro 9010',
            l10n.assetDetailInkType: 'رنگی',
            l10n.assetDetailConnection: 'Wi-Fi, Ethernet',
            l10n.assetDetailDeptCode: 'ACC-PRN-02'
          }),
      SearchResultItem(
          id: 'srch-005',
          name: 'گزارش عملکرد فروش - سه ماهه اول',
          type: l10n.searchItemTypeManagement,
          iconData: Icons.assessment_outlined,
          description: l10n.searchItemDescReport,
          lastModified: DateTime.now().subtract(const Duration(days: 60)),
          itemColor: Colors.orange.shade700,
          details: {
            l10n.assetDetailProducer: 'واحد فروش',
            l10n.assetDetailPeriod: 'Q1-1403',
            l10n.assetDetailKpi: 'رشد 15% نسبت به دوره مشابه سال قبل'
          }),
      SearchResultItem(
          id: 'srch-006',
          name: 'سرور پشتیبان Dell PowerEdge R750',
          type: l10n.searchItemTypeIt,
          iconData: Icons.dns_outlined,
          description: l10n.searchItemDescServer,
          lastModified: DateTime.now().subtract(const Duration(days: 2)),
          itemColor: Colors.indigo.shade400,
          details: {
            l10n.assetDetailCpu: 'Dual Intel Xeon Gold',
            l10n.assetDetailRam: '128GB ECC',
            l10n.assetDetailStorageSpace: '48TB RAID 6',
            l10n.assetDetailOs: 'Windows Server 2022'
          }),
      SearchResultItem(
          id: 'srch-007',
          name: 'مانیتور گیمینگ Samsung Odyssey G7',
          type: l10n.searchItemTypeElectronics,
          iconData: Icons.desktop_windows_outlined,
          description: l10n.searchItemDescMonitor,
          lastModified: DateTime.now().subtract(const Duration(days: 90)),
          itemColor: Colors.tealAccent.shade400,
          details: {
            l10n.assetDetailSize: '27 اینچ',
            l10n.assetDetailResolution: 'QHD (2560x1440)',
            l10n.assetDetailRefreshRate: '240Hz',
            l10n.assetDetailUserCode: 'DES-EMP-017'
          }),
      SearchResultItem(
          id: 'srch-008',
          name: 'دستورالعمل استفاده از تجهیزات آزمایشگاه',
          type: l10n.searchItemTypeTech,
          iconData: Icons.integration_instructions_outlined,
          description: l10n.searchItemDescManual,
          lastModified: DateTime.now().subtract(const Duration(days: 120)),
          itemColor: Colors.brown.shade400,
          details: {
            l10n.assetDetailSection: 'آزمایشگاه تحقیق و توسعه',
            l10n.assetDetailVersion: '3.1',
            l10n.assetDetailLastReview: '1402/11/05'
          }),
      SearchResultItem(
          id: 'srch-009',
          name: 'فاکتور خرید تجهیزات شبکه',
          type: l10n.searchItemTypeFinancial,
          iconData: Icons.receipt_long_outlined,
          description: l10n.searchItemDescInvoice,
          lastModified: DateTime.now().subtract(const Duration(days: 45)),
          itemColor: Colors.lime.shade800,
          details: {
            l10n.assetDetailInvoiceNo: 'INV-NET-2024-0078',
            l10n.assetDetailSupplier: 'شرکت ارتباطات امن',
            l10n.assetDetailTotalAmount: '۸۷۰،۰۰۰،۰۰۰ ریال'
          }),
      SearchResultItem(
          id: 'srch-010',
          name: 'پروژکتور سالن کنفرانس اصلی',
          type: l10n.searchItemTypeAv,
          iconData: Icons.settings_brightness_outlined,
          description: l10n.searchItemDescProjector,
          lastModified: DateTime.now().subtract(const Duration(days: 300)),
          itemColor: Colors.purpleAccent.shade200,
          details: {
            l10n.assetDetailModel: 'Epson EB-L630U',
            l10n.assetDetailBrightness: '6000 Lumens',
            l10n.assetDetailLampStatus: '65% عمر باقیمانده',
            l10n.assetDetailSoftwareUpdate: 'ندارد'
          }),
    ];
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchPerformed = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchPerformed = true;
      _searchResults = [];
    });

    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(400)));

    final allItems = _getAllSearchableItems(context);
    List<SearchResultItem> results = [];
    if (query.isNotEmpty) {
      final qLower = query.toLowerCase();
      results = allItems.where((item) {
        return item.name.toLowerCase().contains(qLower) ||
            item.type.toLowerCase().contains(qLower) ||
            item.description.toLowerCase().contains(qLower) ||
            item.details.values
                .any((detailVal) => detailVal.toLowerCase().contains(qLower)) ||
            item.details.keys
                .any((detailKey) => detailKey.toLowerCase().contains(qLower));
      }).toList();
    }

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch("");
  }

  void _showItemDetailsDialog(BuildContext context, SearchResultItem item) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final detailsTextColor = isDarkMode
        ? Colors.white.withOpacity(0.85)
        : Colors.black.withOpacity(0.75);
    final detailsValueColor = isDarkMode ? Colors.white : Colors.black;
    final modalBackgroundColor =
    isDarkMode ? const Color(0xFF252528) : Colors.grey.shade50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: modalBackgroundColor,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
                children: [
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 0.7.h,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          backgroundColor: item.itemColor.withOpacity(0.15),
                          radius: 7.w,
                          child: Icon(item.iconData,
                              color: item.itemColor, size: 8.w)),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(item.name,
                                style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87),
                                maxLines: 2),
                            SizedBox(height: 0.5.h),
                            Text(item.type,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: detailsTextColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.8.h),
                    child: Text(item.description,
                        style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            color: detailsTextColor,
                            height: 1.5)),
                  ),
                  SizedBox(height: 1.h),
                  _buildDetailRow(
                      l10n.searchDetailsLastModified,
                      '${item.lastModified.day}/${item.lastModified.month}/${item.lastModified.year}',
                      detailsTextColor,
                      detailsValueColor,
                      isDarkMode),
                  SizedBox(height: 2.h),
                  Text(l10n.searchDetailsMoreDetails,
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black87)),
                  SizedBox(height: 1.h),
                  ...item.details.entries.map((entry) => _buildDetailRow(
                      '${entry.key}:',
                      entry.value,
                      detailsTextColor,
                      detailsValueColor,
                      isDarkMode,
                      isDetailEntry: true)),
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor,
      Color valueColor, bool isDarkMode,
      {bool isDetailEntry = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDetailEntry ? 0.7.h : 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: labelColor,
                  fontWeight:
                  isDetailEntry ? FontWeight.w500 : FontWeight.normal)),
          SizedBox(width: 1.5.w),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: valueColor,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor =
    isDarkMode ? Colors.white12.withOpacity(0.15) : Colors.white;
    final textFieldFillColor = isDarkMode
        ? Colors.black.withOpacity(0.15)
        : Colors.white.withOpacity(0.8);
    final hintTextColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final emptyStateIconColor =
    isDarkMode ? Colors.blueGrey.shade200 : Colors.blueGrey.shade500;
    final emptyStateTextColor = isDarkMode
        ? Colors.white.withOpacity(0.65)
        : Colors.black.withOpacity(0.65);

    if (_pageIsLoading) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                  ? Colors.tealAccent.shade100
                  : Colors.teal.shade600),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.5.h),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: l10n.searchPageHintText,
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 12.sp, color: hintTextColor),
                  filled: true,
                  fillColor: textFieldFillColor,
                  prefixIcon:
                  Icon(Icons.search_rounded, color: iconColor, size: 6.w),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear_rounded,
                        color: iconColor, size: 5.5.w),
                    onPressed: _clearSearch,
                  )
                      : null,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.grey.shade700.withOpacity(0.7)
                            : Colors.grey.shade300,
                        width: 0.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.tealAccent.shade100
                            : Colors.teal.shade400,
                        width: 1.5),
                  ),
                ),
                onSubmitted: (value) => _performSearch(value),
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(
                begin: 0, end: 0, duration: 200.ms, curve: Curves.easeOut),
            Expanded(
              child:
              _buildResultsArea(emptyStateIconColor, emptyStateTextColor),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildResultsArea(
      Color emptyStateIconColor, Color emptyStateTextColor) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    if (_isSearching) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                    ? Colors.tealAccent.shade100
                    : Colors.teal.shade600),
              ),
              SizedBox(height: 2.h),
              Text(
                l10n.searchStatusSearchingFor(_searchText),
                style: GoogleFonts.poppins(
                    fontSize: 11.sp, color: emptyStateTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms);
    }

    if (!_searchPerformed && _searchText.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded,
                  color: emptyStateIconColor, size: 22.w),
              SizedBox(height: 2.h),
              Text(
                l10n.searchEmptyStateInitial,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 11.5.sp, color: emptyStateTextColor, height: 1.5),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 100.ms, duration: 300.ms)
          .scale(begin: const Offset(1, 1), curve: Curves.easeOut);
    }

    if (_searchResults.isEmpty && _searchPerformed) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  color: emptyStateIconColor, size: 22.w),
              SizedBox(height: 2.h),
              Text(
                l10n.searchEmptyStateNotFound(_searchText),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 11.5.sp, color: emptyStateTextColor, height: 1.5),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .shake(hz: 2, duration: 200.ms, curve: Curves.easeOut);
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(3.w, 0.5.h, 3.w, 10.h),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _SearchResultItemCard(
          item: item,
          isDarkMode: isDarkMode,
          searchText: _searchText,
          onTap: () => context.go('/assets_detail'),
        )
            .animate(delay: (50 * min(index, 10)).ms)
            .fadeIn(duration: 350.ms)
            .slideX(
          begin: isDarkMode ? 0.2 : -0.2,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }
}

class _SearchResultItemCard extends StatelessWidget {
  final SearchResultItem item;
  final bool isDarkMode;
  final String searchText;
  final VoidCallback onTap;

  const _SearchResultItemCard({
    required this.item,
    required this.isDarkMode,
    required this.searchText,
    required this.onTap,
  });

  List<TextSpan> _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery;

    while ((indexOfQuery =
        text.toLowerCase().indexOf(query.toLowerCase(), start)) !=
        -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfQuery)));
      }
      spans.add(
        TextSpan(
          text: text.substring(indexOfQuery, indexOfQuery + query.length),
          style: TextStyle(
            backgroundColor: isDarkMode
                ? Colors.teal.withOpacity(0.4)
                : Colors.teal.withOpacity(0.2),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = indexOfQuery + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor =
    isDarkMode ? const Color(0xFF2C2D30) : Colors.white;
    final titleColor = isDarkMode
        ? Colors.white.withOpacity(0.95)
        : Colors.black.withOpacity(0.87);
    final subtitleColor = isDarkMode
        ? Colors.white.withOpacity(0.65)
        : Colors.black.withOpacity(0.65);
    final descriptionColor = isDarkMode
        ? Colors.white.withOpacity(0.75)
        : Colors.black.withOpacity(0.7);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.grey.withOpacity(0.25);

    return Card(
      color: cardBackgroundColor,
      elevation: isDarkMode ? 1.5 : 2.5,
      shadowColor: shadowColor,
      margin: EdgeInsets.symmetric(vertical: 0.8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: item.itemColor.withOpacity(isDarkMode ? 0.4 : 0.6),
            width: 0.8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        splashColor: item.itemColor.withOpacity(0.1),
        highlightColor: item.itemColor.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: item.itemColor.withOpacity(0.12),
                radius: 6.w,
                child: Icon(item.iconData, color: item.itemColor, size: 6.5.w),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: titleColor),
                          children:
                          _buildHighlightedText(item.name, searchText)),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      item.type,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.8.h),
                    RichText(
                      text: TextSpan(
                          style: GoogleFonts.poppins(
                              fontSize: 10.5.sp,
                              color: descriptionColor,
                              height: 1.4),
                          children: _buildHighlightedText(
                              item.description, searchText)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 1.w),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 3.5.w, color: subtitleColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}