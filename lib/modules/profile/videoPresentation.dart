import 'package:flutter/material.dart';
import 'package:profilecenter/constants/assets_path.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/secure_storage_service.dart';
import 'package:profilecenter/utils/ui/bottom_modal.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/utils/ui/show_snackbar.dart';
import 'package:profilecenter/providers/video_presentation_provider.dart';
import 'package:profilecenter/core/services/document_service.dart';
import 'package:profilecenter/modules/documents/add_document.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/empty_data_card.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPresentation extends StatefulWidget {
  @override
  _VideoPresentationState createState() => _VideoPresentationState();
}

class _VideoPresentationState extends State<VideoPresentation> {
  VideoPlayerController _controller;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    initializeVideoController();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) _controller.dispose();
  }

  void initializeVideoController() async {
    try {
      VideoPresentationProvider videoPresentationProvider =
          Provider.of<VideoPresentationProvider>(context, listen: false);
      if (videoPresentationProvider.videoPresentation != null) {
        String token = await SecureStorageService.readToken();
        _controller = VideoPlayerController.network(
          URL_BACKEND +
              "api/document/decryptFile?file_id=${videoPresentationProvider.videoPresentation.id}",
          httpHeaders: {
            "Authorization": "Bearer $token",
          },
        )..initialize().then((_) {
            setState(() {});
          });
      }
    } catch (e) {}
  }

  void _showDeleteDialog(VideoPresentationProvider videoPresentationProvider) {
    showBottomModal(
        context,
        null,
        getTranslate(context, "DELETE_VIDEO_NOTICE"),
        getTranslate(context, "YES"),
        () async {
          Navigator.of(context).pop();

          try {
            setState(() {
              _isDeleting = true;
            });
            var res = await DocumentService()
                .deleteDocument(videoPresentationProvider.videoPresentation.id);
            if (res.statusCode == 401) return sessionExpired(context);
            if (res.statusCode != 200) throw "ERROR_SERVER";
            videoPresentationProvider.remove();
            showSnackbar(context, getTranslate(context, "DELETE_SUCCESS"));
            setState(() {
              _isDeleting = false;
            });
          } catch (e) {
            setState(() {
              _isDeleting = false;
            });
            showSnackbar(context, getTranslate(context, "ERROR_SERVER"));
          }
        },
        getTranslate(context, "NO"),
        () {
          Navigator.of(context).pop();
        });
  }

  @override
  Widget build(BuildContext context) {
    VideoPresentationProvider videoPresentationProvider =
        Provider.of<VideoPresentationProvider>(context, listen: true);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getTranslate(context, "PRESENTATION_VIDEO1"),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            videoPresentationProvider.videoPresentation != null
                ? IconButton(
                    onPressed: _isDeleting
                        ? () => null
                        : () {
                            _showDeleteDialog(videoPresentationProvider);
                          },
                    icon: _isDeleting
                        ? circularProgress
                        : SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: Image.asset(TRASH_ICON, color: RED_DARK),
                          ))
                : IconButton(
                    onPressed: _isDeleting
                        ? () => null
                        : () {
                            Navigator.of(context).pushNamed(
                                AddDocument.routeName,
                                arguments: AddDocumentArguments(
                                    getTranslate(context, "PRESENTATION_VIDEO"),
                                    VIDEO_PRESENTATION,
                                    false,
                                    VIDEO_EXTENSION));
                          },
                    icon: Icon(
                      Icons.add_circle_rounded,
                      color: RED_DARK,
                      size: 20,
                    )),
          ],
        ),
        videoPresentationProvider.videoPresentation != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: _controller == null || !_controller.value.isInitialized
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
                                        child: Image.asset(PLAY_VIDEO_BUTTON)),
                              ],
                            ),
                          ),
                        ),
                ),
              )
            : EmptyDataCard(getTranslate(context, "NO_DATA")),
      ],
    );
  }
}
