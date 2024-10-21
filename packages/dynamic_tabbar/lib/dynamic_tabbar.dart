// Copyright (c) 2023 Ali Haider. All rights reserved.
// Use of this source code is governed by MIT License that can be
// found in the LICENSE file.

library dynamic_tabbar;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TabData {
  final int index;
  final Tab title;
  final Widget content;

  TabData({required this.index, required this.title, required this.content});
}

/// Defines where the Tab indicator animation moves to when new Tab is added.
///
///
enum MoveToTab {
  /// The [idol] indicator will remain on current Tab when new Tab is added.
  idol,
  next,
  previous,
  first,
  /// The [last] indicator will move to the Last Tab when new Tab is added.
  last,
  firstThenLast,
  firstThenNext,
  firstThenIdol,

}

/// Dynamic Tabs.
class DynamicTabBarWidget extends TabBar {
  /// List of Tabs.
  ///
  /// TabData contains [index] of the tab and the title which is extension of [TabBar] header.
  /// and the [content] is the extension of [TabBarView] so all the page content is displayed in this section
  ///
  ///
  final List<TabData> dynamicTabs;
  final Function(TabController) onTabControllerUpdated;
  final Function(int?)? onTabChanged;
  final Function(int?)? onTabAdded;
  final Function(int?)? onTabRemoved;

  /// Defines where the Tab indicator animation moves to when new Tab is added.
  ///
  /// Default is move to last
  ///
  final MoveToTab? onAddTabMoveTo;


  /// Defines where the Tab indicator animation moves to when new Tab is removed.
  ///
  /// Default is do not move [idle]
  ///
  final MoveToTab? onRemoveTabMoveTo;


  /// The back icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default back icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? backIcon;

  /// The forward icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default forward icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? nextIcon;

  /// The showBackIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showBackIcon;

  /// The showNextIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showNextIcon;

  /// The leading property is used to add custom leading widget in TabBar.
  ///
  /// By default [leading] widget is null.
  ///
  final Widget? leading;

  /// The leading property is used to add custom trailing widget in TabBar.
  ///
  /// By default [trailing] widget is null.
  ///
  final Widget? trailing;

  /// The physics property is used to set the physics of TabBarView.
  final ScrollPhysics? physicsTabBarView;

  /// The dragStartBehavior property is used to set the dragStartBehavior of TabBarView.
  ///
  /// By default [dragStartBehavior] is DragStartBehavior.start.
  final DragStartBehavior dragStartBehaviorTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final double viewportFractionTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final Clip clipBehaviorTabBarView;

  DynamicTabBarWidget({
    super.key,
    required this.dynamicTabs,
    required this.onTabControllerUpdated,
    this.onTabChanged,
    this.onTabAdded,
    this.onTabRemoved,
    this.onAddTabMoveTo,
    this.onRemoveTabMoveTo,
    super.isScrollable,
    this.backIcon,
    this.nextIcon,
    this.showBackIcon = true,
    this.showNextIcon = true,
    this.leading,
    this.trailing,
    // Default Tab properties :---------------------------------------
    super.padding,
    super.indicatorColor,
    super.automaticIndicatorColorAdjustment = true,
    super.indicatorWeight = 2.0,
    super.indicatorPadding = EdgeInsets.zero,
    super.indicator,
    super.indicatorSize,
    super.dividerColor,
    super.dividerHeight,
    super.labelColor,
    super.labelStyle,
    super.labelPadding,
    super.unselectedLabelColor,
    super.unselectedLabelStyle,
    super.dragStartBehavior = DragStartBehavior.start,
    super.overlayColor,
    super.mouseCursor,
    super.enableFeedback,
    super.onTap,
    super.physics,
    super.splashFactory,
    super.splashBorderRadius,
    super.tabAlignment,
    // Default TabBarView properties :---------------------------------------
    this.physicsTabBarView,
    this.dragStartBehaviorTabBarView = DragStartBehavior.start,
    this.viewportFractionTabBarView = 1.0,
    this.clipBehaviorTabBarView = Clip.hardEdge,
  }) : super(tabs: []);

  @override
  // ignore: library_private_types_in_public_api
  _DynamicTabBarWidgetState createState() => _DynamicTabBarWidgetState();
}

class _DynamicTabBarWidgetState extends State<DynamicTabBarWidget>
    with TickerProviderStateMixin {
  // Tab Controller
  TabController? _tabController;

  int activeTab = 0;

  bool _tabRemoved = false;

  int _tabRemovedDestTabIdx = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('ALERT:DYNAMIC_TABBAR::initState');
    _tabController = getTabController(initialIndex: activeTab);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tabController =
        getTabController(initialIndex: widget.dynamicTabs.length - 1);
    widget.onTabControllerUpdated(_tabController = getTabController());
  }

  @override
  void didUpdateWidget(covariant DynamicTabBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_tabController?.length == widget.dynamicTabs.length) {
      debugPrint('ALERT:DYNAMIC_TABBAR::didUpdateWidget:: no length change in tabs');
      return;
    }

    debugPrint("dynamic_tabbar:: tabController vs widget.dynamicTabs len::${_tabController?.length} vs ${widget.dynamicTabs.length}");
    var isAdd = (_tabController?.length ?? 0) < (widget.dynamicTabs.length ?? 0);

    var activeTabIndex = getActiveTab();
    if (activeTabIndex >= widget.dynamicTabs.length) {
      activeTabIndex = widget.dynamicTabs.length - 1;
    }
    _tabController = getTabController(initialIndex: activeTabIndex);
    if (isAdd) {
        var moveToTab = (widget.onAddTabMoveTo ?? MoveToTab.last);
        var destinationTabIndex = switchOnMoveToTab(moveToTab, _tabController!, activeTabIndex);
        if (widget.onTabAdded != null) {
        Future.delayed(Duration(milliseconds: 50), () {
            widget.onTabAdded!(destinationTabIndex);
        });
        }
    } else {
        var moveToTab = (widget.onRemoveTabMoveTo ?? MoveToTab.next);
        var destinationTabIndex = switchOnMoveToTab(moveToTab, _tabController!, activeTabIndex);
        _tabRemoved = true;
        _tabRemovedDestTabIdx = destinationTabIndex;
        if (widget.onTabRemoved != null) {
        Future.delayed(Duration(milliseconds: 50), () {
            widget.onTabRemoved!(destinationTabIndex);
        });
        }
    }
    
  }

  void FireFutureAnimateTo(TabController tabController, int toTabIndex, Duration wait) {
    Future.delayed(wait, () {
      tabController.animateTo(
        toTabIndex,
      );
      setState(() {
        activeTab = toTabIndex;
      });
    });
  }

  // ignore: body_might_complete_normally_nullable
  int switchOnMoveToTab(MoveToTab? moveToTab, TabController tabController, int activeTab) {
    switch (moveToTab) {
      case MoveToTab.next when activeTab + 1 < widget.dynamicTabs.length:
        FireFutureAnimateTo(tabController, activeTab + 1, const Duration(milliseconds: 50));
        return activeTab + 1;

      case MoveToTab.previous when activeTab - 1 >= 0:
        FireFutureAnimateTo(tabController, activeTab - 1, const Duration(milliseconds: 50));
        return activeTab - 1;

      case MoveToTab.first:
        FireFutureAnimateTo(tabController, 0, const Duration(milliseconds: 50));
        return 0;

      case MoveToTab.last:
        FireFutureAnimateTo(tabController, widget.dynamicTabs.length - 1, const Duration(milliseconds: 50));
        return widget.dynamicTabs.length - 1;

      case MoveToTab.firstThenNext when activeTab + 1 < widget.dynamicTabs.length:
        FireFutureAnimateTo(tabController, 0, const Duration(milliseconds: 30));
        FireFutureAnimateTo(tabController, activeTab + 1, const Duration(milliseconds: 50));
        return activeTab + 1;

      case MoveToTab.firstThenNext when activeTab + 1 >= widget.dynamicTabs.length:
        FireFutureAnimateTo(tabController, 0, const Duration(milliseconds: 30));
        FireFutureAnimateTo(tabController, widget.dynamicTabs.length - 1, const Duration(milliseconds: 50));
        return widget.dynamicTabs.length - 1;

      case MoveToTab.firstThenLast:
        FireFutureAnimateTo(tabController, 0, const Duration(milliseconds: 30));
        FireFutureAnimateTo(tabController, widget.dynamicTabs.length - 1, const Duration(milliseconds: 50));
        return widget.dynamicTabs.length - 1;

      case MoveToTab.firstThenIdol:
        FireFutureAnimateTo(tabController, 0, const Duration(milliseconds: 50));
        FireFutureAnimateTo(tabController, activeTab < widget.dynamicTabs.length ? activeTab : 0, const Duration(milliseconds: 150));
        return activeTab < widget.dynamicTabs.length ? activeTab : 0;

      case MoveToTab.idol:
        return activeTab;

      case null:
        return activeTab;

      default:
        return activeTab;
    }
  }

  TabController getTabController({int initialIndex = 0}) {
    if (initialIndex >= widget.dynamicTabs.length) {
      initialIndex = widget.dynamicTabs.length - 1;
    }
    return TabController(
      initialIndex: initialIndex,
      length: widget.dynamicTabs.length,
      vsync: this,
    )..addListener(() {
        setState(() {
          activeTab = _tabController?.index ?? 0;
          if (_tabController?.indexIsChanging == true) {
            widget.onTabChanged!(_tabController?.index);
          }
        });
      });
  }

  int getActiveTab() {
    // when there are No tabs
    if (activeTab == 0 && widget.dynamicTabs.isEmpty) {
      return 0;
    }
    if (activeTab == widget.dynamicTabs.length) {
      return widget.dynamicTabs.length - 1;
    }
    if (activeTab < widget.dynamicTabs.length) {
      return activeTab;
    }
    return widget.dynamicTabs.length;
  }

  // ignore: body_might_complete_normally_nullable
  int? getOnAddMoveToTab(MoveToTab? moveToTab) {
    switch (moveToTab) {
      case MoveToTab.next:
         return widget.dynamicTabs.length - 1;

      case MoveToTab.previous:
         return widget.dynamicTabs.length - 2;

      case MoveToTab.first:
         return 0;

      case MoveToTab.last:
        return widget.dynamicTabs.length - 1;

      case MoveToTab.firstThenNext:
        return widget.dynamicTabs.length - 1;

      case MoveToTab.idol:
        return null;

      case null:
        // move to Last Tab
        return widget.dynamicTabs.length - 1;
      default:
        // move to Last Tab
        return widget.dynamicTabs.length - 1;

    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _tabController = getTabController(initialIndex: widget.dynamicTabs.length - 1);
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: DefaultTabController(
        length: widget.dynamicTabs.length,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                if (widget.leading != null) widget.leading!,
                if (widget.isScrollable == true && widget.showBackIcon == true)
                  IconButton(
                    icon: widget.backIcon ??
                        const Icon(
                          Icons.arrow_back_ios,
                        ),
                    onPressed: _moveToPreviousTab,
                  ),
                Expanded(
                  child: TabBar(
                    isScrollable: widget.isScrollable,
                    controller: _tabController,
                    tabs: widget.dynamicTabs.map((tab) => tab.title).toList(),
                    // Default Tab properties :---------------------------------------
                    padding: widget.padding,
                    indicatorColor: widget.indicatorColor,
                    automaticIndicatorColorAdjustment:
                        widget.automaticIndicatorColorAdjustment,
                    indicatorWeight: widget.indicatorWeight,
                    indicatorPadding: widget.indicatorPadding,
                    indicator: widget.indicator,
                    indicatorSize: widget.indicatorSize,
                    dividerColor: widget.dividerColor,
                    dividerHeight: widget.dividerHeight,
                    labelColor: widget.labelColor,
                    labelStyle: widget.labelStyle,
                    labelPadding: widget.labelPadding,
                    unselectedLabelColor: widget.unselectedLabelColor,
                    unselectedLabelStyle: widget.unselectedLabelStyle,
                    dragStartBehavior: widget.dragStartBehavior,
                    overlayColor: widget.overlayColor,
                    mouseCursor: widget.mouseCursor,
                    enableFeedback: widget.enableFeedback,
                    onTap: widget.onTap,
                    physics: widget.physics,
                    splashFactory: widget.splashFactory,
                    splashBorderRadius: widget.splashBorderRadius,
                    tabAlignment: widget.tabAlignment,
                  ),
                ),
                if (widget.isScrollable == true && widget.showNextIcon == true)
                  IconButton(
                    icon: widget.nextIcon ??
                        const Icon(
                          Icons.arrow_forward_ios,
                        ),
                    onPressed: _moveToNextTab,
                  ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: widget.physicsTabBarView,
                dragStartBehavior: widget.dragStartBehaviorTabBarView,
                viewportFraction: widget.viewportFractionTabBarView,
                clipBehavior: widget.clipBehaviorTabBarView,
                children: widget.dynamicTabs.map((tab) => tab.content).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _moveToNextTab() {
    if (_tabController != null &&
        _tabController!.index + 1 < _tabController!.length) {
      _tabController!.animateTo(_tabController!.index + 1);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't move forward"),
      // ));
    }
  }

  _moveToPreviousTab() {
    if (_tabController != null && _tabController!.index > 0) {
      _tabController!.animateTo(_tabController!.index - 1);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't go back"),
      // ));
    }
  }
}
