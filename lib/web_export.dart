import 'dart:convert';
import 'dart:html' as html;

void downloadJsonForWeb(String jsonStr, String fileName) {
  final bytes = utf8.encode(jsonStr);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}