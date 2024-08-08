import 'package:flutter/material.dart';
import 'Anterior.dart';
import 'DetailPage.dart';
import 'Posterior.dart';
import 'RCT.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedLabel;
  List<Map<String, dynamic>> toothConditions = List.generate(
    32,
        (index) => {
      'label': '',
      'mesial': null,
      'distal': null,
      'bukal': null,
      'palatal': null,
      'oclusal': null,
      'rct': false,
    },
  );

  void _onShapeTapped(String label) {
    setState(() {
      if (selectedLabel == label) {
        selectedLabel = null; // Hide the DetailPage if the same label is tapped again
      } else {
        selectedLabel = label; // Show the DetailPage for the new label
      }
    });
  }

  void _updateToothCondition(String label, String part, String condition, bool? rct) {
    setState(() {
      int index = toothConditions.indexWhere((element) => element['label'] == label);
      if (index != -1) {
        toothConditions[index][part] = condition;
        if (rct != null) {
          toothConditions[index]['rct'] = rct;
        }
      } else {
        toothConditions.add({
          'label': label,
          'mesial': part == 'mesial' ? condition : null,
          'distal': part == 'distal' ? condition : null,
          'bukal': part == 'bukal' ? condition : null,
          'palatal': part == 'palatal' ? condition : null,
          'oclusal': part == 'oclusal' ? condition : null,
          'rct': rct ?? false,
        });
      }
    });
  }

  void _closeDetailPage() {
    setState(() {
      selectedLabel = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Shape Grid Example'),
      ),
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ShapeGridPage(
              onShapeTapped: _onShapeTapped,
              toothConditions: toothConditions,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: const Offset(0, 0),
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: selectedLabel != null
                  ? DetailPage(
                key: ValueKey<String>(selectedLabel!),
                label: selectedLabel!,
                onClose: _closeDetailPage,
                onConditionChanged: (label, part, condition) => _updateToothCondition(label, part, condition, null),
                onRCTChanged: (label, value) => _updateToothCondition(label, '', '', value),
                toothConditions: toothConditions,
              )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class ShapeGridPage extends StatefulWidget {
  final Function(String) onShapeTapped;
  final List<Map<String, dynamic>> toothConditions;

  const ShapeGridPage({
    super.key,
    required this.onShapeTapped,
    required this.toothConditions,
  });

  @override
  _ShapeGridPageState createState() => _ShapeGridPageState();
}

class _ShapeGridPageState extends State<ShapeGridPage> {
  final List<bool> _isBlueList = List.generate(32, (_) => false);
  int? _selectedIndex;

  void _toggleShapeColor(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _isBlueList[index] = !_isBlueList[index];
        if (!_isBlueList[index]) {
          _selectedIndex = null;
        }
      } else {
        if (_selectedIndex != null) {
          _isBlueList[_selectedIndex!] = false;
        }
        _isBlueList[index] = true;
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = [
      '18', '17', '16', '15', '14', '13', '12', '11', '21', '22', '23', '24', '25', '26', '27', '28',
      '48', '47', '46', '45', '44', '43', '42', '41', '31', '32', '33', '34', '35', '36', '37', '38',
    ];

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 16, // Number of columns
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1, // Ensure the grid items are square
          ),
          itemCount: 32,
          itemBuilder: (context, index) {
            String label = labels[index];

            var toothCondition = widget.toothConditions.firstWhere(
                    (element) => element['label'] == label,
                orElse: () => {'label': label});

            CustomPainter painter;
            if ([
              '18', '17', '16', '15', '14', '24', '25', '26', '27', '28',
              '48', '47', '46', '45', '44', '34', '35', '36', '37', '38'
            ].contains(label)) {
              painter = Posterior(
                isBlue: _isBlueList[index],
                conditions: toothCondition,
                label: label,
              );
            } else {
              painter = Anterior(
                isBlue: _isBlueList[index],
                conditions: toothCondition,
                label: label,
              );
            }

            bool showTriangle = toothCondition['rct'] ?? false;

            return GestureDetector(
              onTap: () {
                _toggleShapeColor(index);
                widget.onShapeTapped(label);
              },
              child: Column(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CustomPaint(
                      painter: painter,
                      child: Container(),
                    ),
                  ),
                  if (showTriangle) InvertedTriangleWidget(),
                  const SizedBox(height: 4),
                  Text(label),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class InvertedTriangleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 40),
      painter: InvertedTrianglePainter(),
    );
  }
}
