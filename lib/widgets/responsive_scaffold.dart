import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final bool centerTitle;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBarBottom;
  final Widget? leading;

  const ResponsiveScaffold({
    Key? key,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.centerTitle = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.appBarBottom,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: centerTitle,
        actions: actions,
        bottom: appBarBottom,
        leading: leading,
        elevation: ResponsiveHelper.getValueForScreenType<double>(
          context: context,
          mobile: 0,
          tablet: 1,
          desktop: 2,
        ),
      ),
      body: SafeArea(
        child: ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isTablet(context)
            ? Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getResponsiveWidth(context),
                  ),
                  child: body,
                ),
              )
            : body,
      ),
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
    );
  }
}