import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/reports/books_sold_report.dart';
import '../models/reports/books_rented_report.dart';
import '../models/reports/members_report.dart';
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
      
      return BooksSoldReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o prodaji knjiga.');
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
      
      return BooksSoldReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o prodaji knjiga po mjesecu.');
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
      
      return BooksSoldReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o prodaji knjiga po kvartalu.');
    }
  }
  
  Future<BooksSoldReport?> getBooksSoldReportByYear({
    required int year,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-sold/year/$year'
      );
      
      return BooksSoldReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o prodaji knjiga po godini.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o prodaji knjiga.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o prodaji knjiga po mjesecu.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o prodaji knjiga po kvartalu.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o prodaji knjiga po godini.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja.');
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
      
      return BooksRentedReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o iznajmljivanju knjiga.');
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
      
      return BooksRentedReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o iznajmljivanju knjiga po mjesecu.');
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
      
      return BooksRentedReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o iznajmljivanju knjiga po kvartalu.');
    }
  }

  Future<BooksRentedReport?> getBooksRentedReportByYear({
    required int year,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/books-rented/year/$year'
      );
      
      return BooksRentedReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o iznajmljivanju knjiga po godini.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o iznajmljivanju knjiga.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o iznajmljivanju knjiga po mjesecu.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o iznajmljivanju knjiga po kvartalu.');
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
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o iznajmljivanju knjiga po godini.');
    }
  }

  // Members and Memberships Reports
  Future<MembersReport?> getMembersReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final response = await _apiService.get(
        'Reporting/members?startDate=$startDateStr&endDate=$endDateStr'
      );
      
      return MembersReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o članovima.');
    }
  }

  Future<MembersReport?> getMembersReportByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/members/month/$year/$month'
      );
      
      return MembersReport.fromJson(response);
      
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o članovima po mjesecu.');
    }
  }

  Future<MembersReport?> getMembersReportByQuarter({
    required int year,
    required int quarter,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/members/quarter/$year/$quarter'
      );
      
      return MembersReport.fromJson(response);
      
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o članovima po kvartalu.');
    }
  }

  Future<MembersReport?> getMembersReportByYear({
    required int year,
  }) async {
    try {
      final response = await _apiService.get(
        'Reporting/members/year/$year'
      );
      
      return MembersReport.fromJson(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja izvještaja o članovima po godini.');
    }
  }

  Future<void> downloadMembersPdfReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final url = '${ApiService.baseUrl}/Reporting/members/pdf?startDate=$startDateStr&endDate=$endDateStr';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_clanovi_${startDateStr}_${endDateStr}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o članovima.');
    }
  }

  Future<void> downloadMembersPdfReportByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/members/pdf/month/$year/$month';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
          final filePath = '${downloadsDir?.path}/izvjestaj_clanovi_${month}_${year}.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o članovima po mjesecu.');
    }
  }

  Future<void> downloadMembersPdfReportByQuarter({
    required int year,
    required int quarter,
  }) async {
    try {
      final response = await _downloadPdfFromUrl(
        '${ApiService.baseUrl}/Reporting/members/pdf/quarter/$year/$quarter'
      );
      
      if (response != null) {
        final downloadsDir = await getDownloadsDirectory();
        final filePath = '${downloadsDir?.path}/izvjestaj_clanovi_Q${quarter}_${year}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response);
      }
    } catch (e) {
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o članovima po kvartalu.');
    }
  }

  Future<void> downloadMembersPdfReportByYear({
    required int year,
  }) async {
    try {
      final url = '${ApiService.baseUrl}/Reporting/members/pdf/year/$year';
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final response = await _downloadPdfFromUrl(url);
        if (response != null) {
          final downloadsDir = await getDownloadsDirectory();
                  final filePath = '${downloadsDir?.path}/izvjestaj_clanovi_${year}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response);
        }
      }
    } catch (e) {
      throw Exception('Greška prilikom preuzimanja PDF izvještaja o članovima po godini.');
    }
  }
}
