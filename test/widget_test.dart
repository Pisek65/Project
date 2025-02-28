import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:account/main.dart'; // ปรับตามชื่อ package ของคุณ

void main() {
  testWidgets('Product page displays correctly', (WidgetTester tester) async {
    // Build the app with MyApp
    await tester.pumpWidget(MyApp());

    // ตรวจสอบว่า ProductPage โหลดมาแสดงผลอะไรบางอย่าง
    expect(find.text('Product 1'), findsOneWidget); // ปรับตามข้อความจริงใน ProductPage

    // ถ้ามีปุ่มใน ProductPage เช่น ปุ่ม "Add Review"
    await tester.tap(find.text('Add Review')); // ปรับตามปุ่มจริง
    await tester.pump();

    // ตรวจสอบผลลัพธ์หลังกดปุ่ม (เช่น มีรีวิวเพิ่ม)
    expect(find.text('Review added'), findsOneWidget); // ปรับตามผลลัพธ์จริง
  });
}