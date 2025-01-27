import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_drag_drop/item_panel.dart';
import 'package:flutter_drag_drop/my_drop_region.dart';
import 'package:flutter_drag_drop/types.dart';

class SplitPanels extends StatefulWidget {
  SplitPanels({
    super.key,
    this.columns = 5,
    this.itemSpacing = 4.0,
  });

  final int columns;
  final double itemSpacing;

  @override
  State<SplitPanels> createState() => _SplitPanelsState();
}

class _SplitPanelsState extends State<SplitPanels> {
  List<String> upper = [];
  List<String> lower = ['a', 'b', 'c', 'd', 'e', 'f'];

  PanelLocation? dragStart;
  PanelLocation? dropPreview;
  String? hoveringData;

  void onDragStart(PanelLocation start) {
    final data = switch (start.$2) {
      Panel.upper => upper[start.$1],
      Panel.lower => lower[start.$1],
    };

    setState(() {
      dragStart = start;
      hoveringData = data;
    });
  }

  void setExternalData(String data) => hoveringData = data;

  void updateDropPreview(PanelLocation update) =>
      setState(() => dropPreview = update);

  void drop() {
    assert(dropPreview != null, 'Can only drop over a known location.');
    assert(hoveringData != null, 'Can only drop when data is being dragged.');
    setState(() {
      if (dragStart != null) {
        if (dragStart!.$2 == Panel.upper) {
          upper.removeAt(dragStart!.$1);
        } else {
          lower.removeAt(dragStart!.$1);
        }
      }

      if (dropPreview!.$2 == Panel.upper) {
        upper.insert(
          min(dropPreview!.$1, upper.length),
          hoveringData!,
        );
      } else {
        lower.insert(
          min(dropPreview!.$1, lower.length),
          hoveringData!,
        );
      }

      dragStart = null;
      dropPreview = null;
      hoveringData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutters = widget.columns + 1;
        final spaceForColumns =
            constraints.maxWidth - (widget.itemSpacing * gutters);
        final columnWidth = spaceForColumns / widget.columns;
        final itemSize = Size(columnWidth, columnWidth);

        return Stack(
          children: [
            Positioned(
              width: constraints.maxWidth,
              height: constraints.maxHeight / 2,
              top: 0,
              child: MyDropRegion(
                childSize: itemSize,
                columns: widget.columns,
                panel: Panel.upper,
                updateDropPreview: updateDropPreview,
                onDrop: drop,
                setExternalData: setExternalData,
                child: ItemPanel(
                  onDragStart: onDragStart,
                  dragStart: dragStart?.$2 == Panel.upper ? dragStart : null,
                  dropPreview:
                      dropPreview?.$2 == Panel.upper ? dropPreview : null,
                  hoveringData:
                      dropPreview?.$2 == Panel.upper ? hoveringData : null,
                  panel: Panel.upper,
                  crossAxisCount: widget.columns,
                  spacing: widget.itemSpacing,
                  items: upper,
                ),
              ),
            ),
            Positioned(
              height: 2,
              width: constraints.maxWidth,
              top: constraints.maxHeight / 2,
              child: ColoredBox(color: Colors.black),
            ),
            Positioned(
              width: constraints.maxWidth,
              height: constraints.maxHeight / 2,
              bottom: 0,
              child: MyDropRegion(
                childSize: itemSize,
                columns: widget.columns,
                panel: Panel.lower,
                updateDropPreview: updateDropPreview,
                onDrop: drop,
                setExternalData: setExternalData,
                child: ItemPanel(
                  onDragStart: onDragStart,
                  dragStart: dragStart?.$2 == Panel.lower ? dragStart : null,
                  dropPreview:
                      dropPreview?.$2 == Panel.lower ? dropPreview : null,
                  hoveringData:
                      dropPreview?.$2 == Panel.lower ? hoveringData : null,
                  panel: Panel.lower,
                  crossAxisCount: widget.columns,
                  spacing: widget.itemSpacing,
                  items: lower,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
