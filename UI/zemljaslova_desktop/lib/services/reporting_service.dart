import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/reports/books_sold_report.dart';
import '../models/reports/books_rented_report.dart';
import 'api_service.dart';

class ReportingService {
  final ApiService _apiService;
  
  ReportingService(this._apiService);
  
  Future<BooksSoldReport?> getBooksSoldReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final response = await _apiService.get(
        'Reporting/books-sold?startDate=$startDateStr&endDate=$endDateStr'
      );
      
      if (response != null) {
        return BooksSoldReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books sold report: $e');
    }
  }
  
  Future<BooksSoldReport?> getBooksSoldReportByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-sold/month/$year/$month'
      );
      
      if (response != null) {
        return BooksSoldReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books sold report by month: $e');
    }
  }
  
  Future<BooksSoldReport?> getBooksSoldReportByQuarter({
    required int year,
    required int quarter,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-sold/quarter/$year/$quarter'
      );
      
      if (response != null) {
        return BooksSoldReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books sold report by quarter: $e');
    }
  }
  
  Future<BooksSoldReport?> getBooksSoldReportByYear({
    required int year,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-sold/year/$year'
      );
      
      if (response != null) {
        return BooksSoldReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books sold report by year: $e');
    }
  }
  
  Future<void> downloadBooksSoldPdfReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final url = '${ApiService.baseUrl}/Reporting/books-sold/pdf?startDate=$startDateStr&endDate=$endDateStr';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_prodaja_knjiga_${startDateStr}_${endDateStr}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF report: $e');
    }
  }
  
  Future<void> downloadBooksSoldPdfReportByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/books-sold/pdf/month/$year/$month';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_prodaja_knjiga_${month}_${year}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF report by month: $e');
    }
  }
  
  Future<void> downloadBooksSoldPdfReportByQuarter({
    required int year,
    required int quarter,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/books-sold/pdf/quarter/$year/$quarter';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_prodaja_knjiga_Q${quarter}_${year}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF report by quarter: $e');
    }
  }
  
  Future<void> downloadBooksSoldPdfReportByYear({
    required int year,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/books-sold/pdf/year/$year';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_prodaja_knjiga_${year}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF report by year: $e');
    }
  }
  
  Future<Uint8List?> _downloadPdfFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _apiService.headers;
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      throw Exception('Error downloading PDF from URL: $e');
    }
  }

  // Books Rented Reports
  Future<BooksRentedReport?> getBooksRentedReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final response = await _apiService.get(
        'Reporting/books-rented?startDate=$startDateStr&endDate=$endDateStr'
      );
      
      if (response != null) {
        return BooksRentedReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books rented report: $e');
    }
  }

  Future<BooksRentedReport?> getBooksRentedReportByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-rented/month/$year/$month'
      );
      
      if (response != null) {
        return BooksRentedReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books rented report by month: $e');
    }
  }

  Future<BooksRentedReport?> getBooksRentedReportByQuarter({
    required int year,
    required int quarter,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-rented/quarter/$year/$quarter'
      );
      
      if (response != null) {
        return BooksRentedReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books rented report by quarter: $e');
    }
  }

  Future<BooksRentedReport?> getBooksRentedReportByYear({
    required int year,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-rented/year/$year'
      );
      
      if (response != null) {
        return BooksRentedReport.fromJson(response);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error getting books rented report by year: $e');
    }
  }

  Future<void> downloadBooksRentedPdfReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final url = '${ApiService.baseUrl}/Reporting/books-rented/pdf?startDate=$startDateStr&endDate=$endDateStr';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_iznajmljivanje_knjiga_${startDateStr}_${endDateStr}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF rental report: $e');
    }
  }

  Future<void> downloadBooksRentedPdfReportByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/books-rented/pdf/month/$year/$month';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_iznajmljivanje_knjiga_${month}_${year}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF rental report by month: $e');
    }
  }

  Future<void> downloadBooksRentedPdfReportByQuarter({
    required int year,
    required int quarter,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/books-rented/pdf/quarter/$year/$quarter';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_iznajmljivanje_knjiga_Q${quarter}_${year}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF rental report by quarter: $e');
    }
  }

  Future<void> downloadBooksRentedPdfReportByYear({
    required int year,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/books-rented/pdf/year/$year';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_iznajmljivanje_knjiga_${year}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Error downloading PDF rental report by year: $e');
    }
  }
}
