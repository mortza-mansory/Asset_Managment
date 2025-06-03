import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';

// --- Data Model for Search Result Item ---
class SearchResultItem {
  final String id;
  final String name;
  final String type;
  final IconData iconData;
  final String description; // A brief summary or relevant snippet
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

// --- Search Page Widget ---
class SearchPage extends StatefulWidget {
  final bool isDarkMode;

  const SearchPage({super.key, required this.isDarkMode});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _pageIsLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  bool _isSearching = false;
  List<SearchResultItem> _searchResults = [];
  bool _searchPerformed = false; // To distinguish initial state from no results found
  Timer? _debounce;

  // --- Mock Data Pool for Searching ---
  // (Extending the variety for better search simulation)
  static final List<SearchResultItem> _allSearchableItems = [
    SearchResultItem(id: 'srch-001', name: 'لپ‌تاپ Dell XPS 15 (سری جدید)', type: 'تجهیزات الکترونیکی', iconData: Icons.laptop_mac_outlined, description: 'لپ‌تاپ قدرتمند برای کارهای گرافیکی و پردازشی، موجود در انبار مرکزی.', lastModified: DateTime.now().subtract(const Duration(days: 5)), itemColor: Colors.blueAccent.shade400, details: {'پردازنده': 'Core i9 13th Gen', 'رم': '32GB DDR5', 'حافظه': '1TB NVMe SSD', 'کد اموال': 'LP-00125', 'وضعیت': 'فعال'}),
    SearchResultItem(id: 'srch-002', name: 'قرارداد نگهداری و پشتیبانی نرم‌افزار CRM', type: 'اسناد حقوقی', iconData: Icons.article_outlined, description: 'قرارداد سالانه با شرکت توسعه‌دهنده نرم‌افزار مدیریت ارتباط با مشتری.', lastModified: DateTime.now().subtract(const Duration(days: 22)), itemColor: Colors.green.shade600, details: {'شماره قرارداد': 'CRM-SUP-2024', 'طرف قرارداد': 'شرکت راهکاران پویا', 'تاریخ انقضا': '1404/08/15', 'مبلغ': '۲۵۰،۰۰۰،۰۰۰ ریال'}),
    SearchResultItem(id: 'srch-003', name: 'دوربین نظارتی محوطه شمالی', type: 'تجهیزات امنیتی', iconData: Icons.videocam_outlined, description: 'دوربین IP با قابلیت دید در شب، پوشش کامل پارکینگ شمالی.', lastModified: DateTime.now().subtract(const Duration(hours: 72)), itemColor: Colors.redAccent.shade400, details: {'مدل': 'Hikvision DS-2CD2T47G2', 'رزولوشن': '4MP', 'وضعیت ضبط': '24/7', 'آخرین سرویس': '1403/02/10'}),
    SearchResultItem(id: 'srch-004', name: 'پرینتر چندکاره HP OfficeJet Pro', type: 'ماشین‌های اداری', iconData: Icons.print_outlined, description: 'پرینتر رنگی با قابلیت اسکن، کپی و فکس، طبقه دوم، اتاق حسابداری.', lastModified: DateTime.now().subtract(const Duration(days: 15)), itemColor: Colors.cyanAccent.shade700, details: {'مدل': 'HP OfficeJet Pro 9010', 'نوع جوهر': 'رنگی', 'اتصال': 'Wi-Fi, Ethernet', 'کد بخش': 'ACC-PRN-02'}),
    SearchResultItem(id: 'srch-005', name: 'گزارش عملکرد فروش - سه ماهه اول', type: 'گزارشات مدیریتی', iconData: Icons.assessment_outlined, description: 'تحلیل جامع عملکرد تیم فروش و مقایسه با اهداف تعیین‌شده برای Q1.', lastModified: DateTime.now().subtract(const Duration(days: 60)), itemColor: Colors.orange.shade700, details: {'تهیه‌کننده': 'واحد فروش', 'دوره زمانی': 'Q1-1403', 'شاخص کلیدی': 'رشد 15% نسبت به دوره مشابه سال قبل'}),
    SearchResultItem(id: 'srch-006', name: 'سرور پشتیبان Dell PowerEdge R750', type: 'تجهیزات IT', iconData: Icons.dns_outlined, description: 'سرور اصلی برای بک‌آپ‌گیری روزانه از داده‌های حیاتی سازمان.', lastModified: DateTime.now().subtract(const Duration(days: 2)), itemColor: Colors.indigo.shade400, details: {'پردازنده': 'Dual Intel Xeon Gold', 'رم': '128GB ECC', 'فضای ذخیره‌سازی': '48TB RAID 6', 'سیستم عامل': 'Windows Server 2022'}),
    SearchResultItem(id: 'srch-007', name: 'مانیتور گیمینگ Samsung Odyssey G7', type: 'تجهیزات الکترونیکی', iconData: Icons.desktop_windows_outlined, description: 'مانیتور ۲۷ اینچ خمیده با نرخ بروزرسانی بالا، مورد استفاده تیم طراحی.', lastModified: DateTime.now().subtract(const Duration(days: 90)), itemColor: Colors.tealAccent.shade400, details: {'اندازه': '27 اینچ', 'رزولوشن': 'QHD (2560x1440)', 'نرخ بروزرسانی': '240Hz', 'کد کاربر': 'DES-EMP-017'}),
    SearchResultItem(id: 'srch-008', name: 'دستورالعمل استفاده از تجهیزات آزمایشگاه', type: 'مستندات فنی', iconData: Icons.integration_instructions_outlined, description: 'راهنمای کامل کار با دستگاه اسپکترومتر و میکروسکوپ الکترونی.', lastModified: DateTime.now().subtract(const Duration(days: 120)), itemColor: Colors.brown.shade400, details: {'بخش': 'آزمایشگاه تحقیق و توسعه', 'نسخه': '3.1', 'آخرین بازبینی': '1402/11/05'}),
    SearchResultItem(id: 'srch-009', name: 'فاکتور خرید تجهیزات شبکه', type: 'اسناد مالی', iconData: Icons.receipt_long_outlined, description: 'فاکتور مربوط به خرید سوئیچ‌ها و روترهای سیسکو برای ارتقاء زیرساخت.', lastModified: DateTime.now().subtract(const Duration(days: 45)), itemColor: Colors.lime.shade800, details: {'شماره فاکتور': 'INV-NET-2024-0078', 'تامین‌کننده': 'شرکت ارتباطات امن', 'مبلغ کل': '۸۷۰،۰۰۰،۰۰۰ ریال'}),
    SearchResultItem(id: 'srch-010', name: 'پروژکتور سالن کنفرانس اصلی', type: 'تجهیزات سمعی و بصری', iconData: Icons.settings_brightness_outlined, description: 'پروژکتور Epson با روشنایی بالا، مناسب برای ارائه‌های بزرگ.', lastModified: DateTime.now().subtract(const Duration(days: 300)), itemColor: Colors.purpleAccent.shade200, details: {'مدل': 'Epson EB-L630U', 'روشنایی': '6000 Lumens', 'وضعیت لامپ': '65% عمر باقیمانده', 'آخرین بروزرسانی نرم‌افزار': 'ندارد'}),
  ];


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final newText = _searchController.text;
      if (_searchText != newText) {
        setState(() {
          _searchText = newText;
        });
        // Debounce search
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          if (_searchText.length > 1 || _searchText.isEmpty) { // جستجو با حداقل ۲ کاراکتر یا خالی کردن
            _performSearch(_searchText);
          } else if (_searchText.length <=1 && _searchPerformed) { // اگر کاربر متن را به ۱ یا ۰ کاراکتر کاهش داد و قبلا جستجو کرده بود
            setState(() {
              _searchResults = [];
              _isSearching = false;
              _searchPerformed = false; // برگرداندن به حالت اولیه اگر جستجو خیلی کوتاه شد
            });
          }
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _pageIsLoading = false);
    });
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
      _searchResults = []; // Clear previous results for new search
    });

    // Simulate search delay
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(400)));

    List<SearchResultItem> results = [];
    if (query.isNotEmpty) {
      final qLower = query.toLowerCase();
      results = _allSearchableItems.where((item) {
        return item.name.toLowerCase().contains(qLower) ||
            item.type.toLowerCase().contains(qLower) ||
            item.description.toLowerCase().contains(qLower) ||
            item.details.values.any((detailVal) => detailVal.toLowerCase().contains(qLower)) ||
            item.details.keys.any((detailKey) => detailKey.toLowerCase().contains(qLower));
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
    _performSearch(""); // This will reset states via _performSearch logic
  }

  void _showItemDetailsDialog(BuildContext context, SearchResultItem item) {
    final isDarkMode = widget.isDarkMode;
    final detailsTextColor = isDarkMode ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.75);
    final detailsValueColor = isDarkMode ? Colors.white : Colors.black;
    final modalBackgroundColor = isDarkMode ? const Color(0xFF252528) : Colors.grey.shade50;

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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
                  children: [
                    Center(
                      child: Container(
                        width: 12.w, height: 0.7.h,
                        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(backgroundColor: item.itemColor.withOpacity(0.15), radius: 7.w, child: Icon(item.iconData, color: item.itemColor, size: 8.w)),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(item.name, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87), maxLines: 2),
                              SizedBox(height: 0.5.h),
                              Text(item.type, style: GoogleFonts.poppins(fontSize: 11.sp, color: detailsTextColor, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.8.h),
                      child: Text(item.description, style: GoogleFonts.poppins(fontSize: 11.5.sp, color: detailsTextColor, height: 1.5)),
                    ),
                    SizedBox(height: 1.h),
                    _buildDetailRow('آخرین تغییر:', '${item.lastModified.day}/${item.lastModified.month}/${item.lastModified.year}', detailsTextColor, detailsValueColor, isDarkMode),
                    SizedBox(height: 2.h),
                    Text('جزئیات بیشتر:', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black87)),
                    SizedBox(height: 1.h),
                    ...item.details.entries.map((entry) => _buildDetailRow('${entry.key}:', entry.value, detailsTextColor, detailsValueColor, isDarkMode, isDetailEntry: true)),
                    SizedBox(height: 2.h),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor, Color valueColor, bool isDarkMode, {bool isDetailEntry = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDetailEntry ? 0.7.h : 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: labelColor, fontWeight: isDetailEntry ? FontWeight.w500 : FontWeight.normal)),
          SizedBox(width: 1.5.w),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 11.sp, color: valueColor, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF18191B) : const Color(0xFFF0F2F5);
    final appBarBackgroundColor = isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);
    final headerTextColor = Colors.white;
    final textFieldFillColor = isDarkMode ? Colors.black.withOpacity(0.15) : Colors.white.withOpacity(0.8);
    final hintTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final emptyStateIconColor = isDarkMode ? Colors.blueGrey.shade200 : Colors.blueGrey.shade500;
    final emptyStateTextColor = isDarkMode ? Colors.white.withOpacity(0.65) : Colors.black.withOpacity(0.65);


    if (_pageIsLoading) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: isDarkMode ? 0.5 : 1.0,
        centerTitle: true,
        title: Text(
          'جستجو در اموال',
          style: GoogleFonts.poppins(fontSize: 16.5.sp, fontWeight: FontWeight.w600, color: headerTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: headerTextColor, size: 5.5.w),
          onPressed: () => context.go("/home"),
        ),
      ),
      body: Column(
        children: [
          // --- Search TextField Area ---
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.5.h),
            child: TextField(
              controller: _searchController,
              autofocus: false, // برای شروع، فوکوس خودکار نباشد
              style: GoogleFonts.poppins(fontSize: 13.sp, color: isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'جستجوی نام، نوع، کد، توضیحات و...',
                hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: hintTextColor),
                filled: true,
                fillColor: textFieldFillColor,
                prefixIcon: Icon(Icons.search_rounded, color: iconColor, size: 6.w),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: iconColor, size: 5.5.w),
                  onPressed: _clearSearch,
                )
                    : null,
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700.withOpacity(0.7) : Colors.grey.shade300, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade400, width: 1.5),
                ),
              ),
              onSubmitted: (value) => _performSearch(value),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, duration: 200.ms, curve: Curves.easeOut),
          ),

          // --- Search Results Area ---
          Expanded(
            child: _buildResultsArea(emptyStateIconColor, emptyStateTextColor),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildResultsArea(Color emptyIconColor, Color emptyTextColor) {
    if (_isSearching) {
      return Center(
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  'در حال جستجو برای "${_searchText}"...',
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: emptyTextColor),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
      ).animate().fadeIn(duration: 200.ms);
    }

    if (!_searchPerformed && _searchText.isEmpty) {
      return Center(
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 18.w, color: emptyIconColor),
                SizedBox(height: 2.h),
                Text(
                  'برای شروع جستجو، عبارتی را در کادر بالا وارد کنید.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: emptyTextColor, height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms).scale(begin: const Offset(0.9,0.9), delay: 100.ms)
      );
    }

    if (_searchResults.isEmpty && _searchPerformed) {
      return Center(
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied_outlined, size: 18.w, color: emptyIconColor),
                SizedBox(height: 2.h),
                Text(
                  'موردی با عبارت "${_searchText}" یافت نشد.\nلطفا عبارت دیگری را امتحان کنید.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: emptyTextColor, height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).shake(hz: 2, duration: 300.ms)
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(3.w, 0.5.h, 3.w, 10.h), // Padding for potential navbar
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _SearchResultItemCard(
          item: item,
          isDarkMode: widget.isDarkMode,
          searchText: _searchText, // For highlighting
        )
        // Applying animation here if AnimatedList is not used
            .animate(delay: (50 * min(index, 10)).ms) // Staggered delay, max delay for first 10 items
            .fadeIn(duration: 350.ms)
            .slideX(begin: widget.isDarkMode ? 0.2 : -0.2, duration: 300.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}


// --- Search Result Item Card Widget ---
class _SearchResultItemCard extends StatelessWidget {
  final SearchResultItem item;
  final bool isDarkMode;
  final String searchText; // To highlight the search query

  const _SearchResultItemCard({
    required this.item,
    required this.isDarkMode,
    required this.searchText,
  });

  // Helper to build rich text with highlighted search query
  List<TextSpan> _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery;

    while ((indexOfQuery = text.toLowerCase().indexOf(query.toLowerCase(), start)) != -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfQuery)));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfQuery, indexOfQuery + query.length),
        style: TextStyle(
          backgroundColor: isDarkMode ? Colors.teal.withOpacity(0.4) : Colors.teal.withOpacity(0.2),
          fontWeight: FontWeight.bold,
        ),
      ));
      start = indexOfQuery + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }


  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor = isDarkMode ? const Color(0xFF2C2D30) : Colors.white;
    final titleColor = isDarkMode ? Colors.white.withOpacity(0.95) : Colors.black.withOpacity(0.9);
    final subtitleColor = isDarkMode ? Colors.white.withOpacity(0.65) : Colors.black.withOpacity(0.6);
    final descriptionColor = isDarkMode ? Colors.white.withOpacity(0.75) : Colors.black.withOpacity(0.7);
    final shadowColor = isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.25);

    return Card(
      color: cardBackgroundColor,
      elevation: isDarkMode ? 1.5 : 2.5,
      shadowColor: shadowColor,
      margin: EdgeInsets.symmetric(vertical: 0.8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: item.itemColor.withOpacity(isDarkMode ? 0.4 : 0.6), width: 0.8),
      ),
      child: InkWell(
        onTap: () {
          // Accessing _showItemDetailsDialog from the state via context
          (context as Element).findAncestorStateOfType<_SearchPageState>()?._showItemDetailsDialog(context, item);
        },
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
                        style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: titleColor),
                        children: _buildHighlightedText(item.name, searchText),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      item.type,
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: subtitleColor, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.8.h),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 10.5.sp, color: descriptionColor, height: 1.4),
                        children: _buildHighlightedText(item.description, searchText),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 1.w),
              Icon(Icons.arrow_forward_ios_rounded, size: 3.5.w, color: subtitleColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}