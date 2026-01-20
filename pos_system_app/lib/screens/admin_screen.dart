import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_colors.dart';
import '../providers/cart_provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = cart.orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () => cart.clearAll(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Sales Performance Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: orders.isEmpty
                  ? const Center(child: Text("Waiting for sales data..."))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(
                            show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text("O-${value.toInt() + 1}",
                                    style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                            left: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        minX: 0,
                        maxX: orders.length > 1
                            ? (orders.length - 1).toDouble()
                            : 1,
                        minY: 0,
                        maxY: _getMaxY(orders),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateSpots(orders),
                            isCurved: false,
                            color: Colors.green.shade700,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1), //
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                    child: _statCard("Total Revenue",
                        "Rs ${cart.todaySales.toInt()}", Colors.green)),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        _statCard("Orders", "${orders.length}", Colors.blue)),
              ],
            ),

            const SizedBox(height: 16),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(" Recent History",
                    style: TextStyle(fontWeight: FontWeight.bold))),

            /// 3. TRANSACTION LIST
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final o = orders[orders.length - 1 - index];
                  return Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.trending_up, color: Colors.green),
                      title: Text(
                          "Order #${o["id"].toString().substring(o["id"].toString().length - 5)}"),
                      subtitle: Text("Rs ${o["total"]}"),
                      trailing: Chip(
                        backgroundColor: o["status"] == "ready"
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        label: Text(o["status"].toString().toUpperCase(),
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(List<Map<String, dynamic>> orders) {
    return List.generate(orders.length, (index) {
      return FlSpot(
          index.toDouble(), (orders[index]["total"] as num).toDouble());
    });
  }

  double _getMaxY(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) return 1000;
    double max = 0;
    for (var o in orders) {
      if ((o["total"] as num) > max) max = (o["total"] as num).toDouble();
    }
    return max + 500;
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
