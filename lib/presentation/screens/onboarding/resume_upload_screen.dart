import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/ai_repository.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  final AiRepository _aiRepo = AiRepository();
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  Map<String, dynamic>? _uploadResult;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _uploadResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = "Could not select file: $e");
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      setState(() => _errorMessage = "Please choose a valid PDF or DOCX file.");
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final result = await _aiRepo.uploadResume(
        fileBytes: _selectedFile!.bytes!,
        filename: _selectedFile!.name,
      );

      setState(() {
        _uploadResult = result;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Resume upload failed: $e";
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resume AI Vectorizer"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Upload Your CV / Resume",
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            "HyaUp will automatically extract your technical skills, experience, and vectorize your profile for LangGraph AI matching.",
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Upload Dropzone Area
          InkWell(
            onTap: _isUploading ? null : _pickFile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedFile != null ? AppColors.primary : AppColors.border,
                  width: 1.8,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedFile != null ? Icons.description_rounded : Icons.cloud_upload_outlined,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _selectedFile != null ? _selectedFile!.name : "Tap to browse PDF or DOCX file",
                    style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedFile != null
                        ? "${(_selectedFile!.size / 1024).round()} KB"
                        : "Supports PDF & DOCX up to 10MB",
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.rose),
            ),
          ],

          const SizedBox(height: 20),

          // Upload CTA
          if (_selectedFile != null && _uploadResult == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _handleUpload,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.bolt_rounded, size: 20),
                label: Text(_isUploading ? "Vectorizing Resume..." : "Parse & Vectorize Skills"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          // Extracted Results Card
          if (_uploadResult != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.emerald, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Resume Vectorized Successfully!",
                        style: AppTypography.titleSmall.copyWith(color: AppColors.emerald),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Extracted Skills:",
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (_uploadResult!['extracted_skills'] as List).map((skill) {
                      return Chip(
                        label: Text(skill.toString()),
                        backgroundColor: AppColors.primaryContainer,
                        labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.primaryDark),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    "Education: ${_uploadResult!['education']}",
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Identified Experience: ${_uploadResult!['experience_years']} Years",
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
