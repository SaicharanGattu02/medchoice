import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

Future<String> postImage(
    Map<String, String> body,
    String urlLink,
    Map<String, String> headers,
    File image
    ) async {
  try {
    // Check the MIME type of the image
    final mimeType = lookupMimeType(image.path);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      print('Selected file is not a valid image.');
      return 'Invalid image file type'; // Return an error message
    }

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(urlLink));

    // Add headers
    request.headers.addAll(headers);

    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // This should match the form field name in your API
        image.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    // Add other form fields
    request.fields.addAll(body);

    // Send the request
    var response = await request.send();

    // Check the response status
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody = await response.stream.bytesToString();
      print("Response Body: $responseBody");
      return responseBody;
    } else {
      print("Error: ${response.reasonPhrase}");
      return 'Error: ${response.reasonPhrase}'; // Return error message
    }
  } catch (e) {
    print('Exception: $e');
    return 'Exception occurred: $e'; // Return exception message
  }
}

Future<String> postImage1(
   Map<String, String> body,
   String urlLink,
   Map<String, String> headers,
  File? image,
) async {
  try {
    // Prepare the URL and request
    var url = Uri.parse(urlLink);
    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..headers['accept'] = 'application/json'; // Assuming you expect JSON responses

    // Add the image file if provided
    if (image != null) {
      String? mimeType = lookupMimeType(image.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        print('Selected file is not a valid image.');
        return 'Invalid image type'; // Return an appropriate error message
      }

      var contentType = MediaType.parse(mimeType);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Field name
          image.path,
          contentType: contentType,
        ),
      );
    }

    // Add other fields from the body
    request.fields.addAll(body);

    // Send the request
    var response = await request.send();

    // Check the response
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var responseData = await response.stream.bytesToString();
      print("Response Body: $responseData");
      return responseData;
    } else {
      var responseData = await response.stream.bytesToString();
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      print("Response Body: $responseData");
      return 'Error: ${response.statusCode}'; // Return an appropriate error message
    }
  } catch (e) {
    print('Exception: $e');
    return 'Exception occurred'; // Return an appropriate error message
  }
}
