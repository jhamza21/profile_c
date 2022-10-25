import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/empty_data_card.dart';
import 'package:video_player/video_player.dart';

class VideoPresentation extends StatefulWidget {
  final int userId;
  VideoPresentation(this.userId);
  @override
  _VideoPresentationState createState() => _VideoPresentationState();
}

class _VideoPresentationState extends State<VideoPresentation> {
  VideoPlayerController _controller;
  Document _document;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDocument();
  }

  void fetchDocument() async {
    try {
      final res =
          await DocumentService().getCandidatVideoPresentation(widget.userId);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      final jsonData = json.decode(res.body);
      if (jsonData["document"] != null) {
        String token = await SecureStorageService.readToken();
        _document = Document.fromJson(jsonData["document"]);
        _controller = VideoPlayerController.network(
          URL_BACKEND +
              "api/document/decryptFile?file_id=" +
              _document.id.toString(),
          httpHeaders: {
            "Authorization": "Bearer $token",
          },
        )..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? circularProgress
        : Column(
            children: [
              _document != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: !_controller.value.isInitialized || _isLoading
                            ? Center(child: circularProgress)
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: Stack(
                                    children: [
                                      VideoPlayer(_controller),
                                      _controller.value.isPlaying
                                          ? SizedBox.shrink()
                                          : Center(
                                              child: Image.asset(
                                                  PLAY_VIDEO_BUTTON)),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    )
                  : EmptyDataCard(getTranslate(context, "NO_DATA"))
            ],
          );
  }
}
