import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreakingNewsTicker extends StatefulWidget {
  final String text;
  final String label;
  final VoidCallback? onTap;

  const BreakingNewsTicker({super.key, required this.text, required this.label, this.onTap});

  @override
  State<BreakingNewsTicker> createState() => _BreakingNewsTickerState();
}

class _BreakingNewsTickerState extends State<BreakingNewsTicker> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() async {
    if (!_scrollController.hasClients || _isScrolling) return;
    _isScrolling = true;
    
    // Reset to start
    _scrollController.jumpTo(0);
    
    // Short delay before start
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    double maxScroll = _scrollController.position.maxScrollExtent;
    double viewportWidth = _scrollController.position.viewportDimension;
    
    // We want the news to scroll fully, so we animate to maxScroll + some extra if needed
    // But since it's a SingleChildScrollView, maxScroll is the end of the text.
    
    double speed = 40.0; // pixels per second
    double duration = maxScroll / speed;

    if (duration > 0) {
      await _scrollController.animateTo(
        maxScroll,
        duration: Duration(milliseconds: (duration * 1000).toInt()),
        curve: Curves.linear,
      );
    }
    
    // Stay at the end for a bit
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      _isScrolling = false;
      _startScrolling();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF3399FF),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Marquee Content
          Positioned.fill(
            left: 115,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                alignment: Alignment.centerLeft,
                // Adding extra padding at the end so the news "clears" the view
                padding: const EdgeInsets.only(left: 15, right: 300), 
                child: Text(
                  widget.text,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          
          // Breaking Label
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ClipPath(
              clipper: BreakingClipper(),
              child: Container(
                width: 125,
                color: const Color(0xFFFFEA00),
                padding: const EdgeInsets.only(left: 12, right: 18),
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '// ${widget.label.toUpperCase()} //',
                    maxLines: 1,
                    softWrap: false,
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BreakingClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 15, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
