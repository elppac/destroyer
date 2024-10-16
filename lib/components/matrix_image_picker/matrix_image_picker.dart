import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';

class MatrixImagePicker extends StatefulWidget {
  /// 输入文本变化时回调
  final ValueChanged<List<dynamic>>? onChanged;
  final String title;
  final String? additionInfo;
  final List<dynamic>? initialValue;
  final bool multiple;
  final int limit;
  final TDTagSize size;
  final double? height;
  final double? borderRadius;
  const MatrixImagePicker(
      {super.key,
      this.initialValue,
      this.onChanged,
      required this.title,
      this.additionInfo,
      this.limit = 9,
      this.size = TDTagSize.extraLarge,
      this.multiple = false,
      this.height,
      this.borderRadius});

  @override
  State<StatefulWidget> createState() => _MatrixImagePicker();
}

class _MatrixImagePicker extends State<MatrixImagePicker> {
  late List<dynamic>? value;

  @override
  void initState() {
    super.initState();
    // 初始化时使用传入的initialValue
    value = widget.initialValue;
  }

  @override
  void didUpdateWidget(MatrixImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果initialValue发生变化，则更新value
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        value = widget.initialValue;
      });
    }
  }

  Future<void> _upload(XFile pickedFile) async {
    final dio = Dio();

    var generateResponse =
        await dio.post('http://192.168.127.138:7001/generatePresignedUrl',
            data: jsonEncode({'fileName': pickedFile.name}),
            options: Options(headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            }));
    var generateResponseData = generateResponse.data;

    // 读取文件为字节流
    Uint8List fileBytes = await pickedFile.readAsBytes();
    var decodedImage = await decodeImageFromList(fileBytes);
    String fileName = pickedFile.name; // 通过 XFile 获取文件名

    // 构建 FormData
    // FormData formData = FormData.fromMap({
    //   "fileInfo": MultipartFile.fromBytes(fileBytes, filename: fileName),
    // });

    final uploadDio = Dio();
    uploadDio.options.connectTimeout = const Duration(seconds: 10);
    uploadDio.options.sendTimeout = const Duration(seconds: 10);
    // var fileData = MultipartFile.fromBytes(fileBytes);
    // FormData body = FormData.fromMap({});
    // body.files.add(MapEntry("image", fileData));
    var uploadResponse =
        await uploadDio.post(generateResponseData["data"]['uploadUrl'],
            // data: FormData.fromMap({
            //   'image': fileData,
            // }),
            data: fileBytes,
            options: Options(headers: {
              HttpHeaders.contentTypeHeader: pickedFile.mimeType,
            }));

    setState(() {
      value = [
        {
          "url": generateResponseData['data']['fileUrl'],
          "uid": generateResponseData["data"]['fileCode'],
          "name": fileName,
          'size': fileBytes.length,
          'width': decodedImage.width,
          'height': decodedImage.height
        }
      ];
      widget.onChanged!(value!);
    });
  }

  Future<ImageSource> showAsyncDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true, // 用户可通过点击背景关闭
      builder: (BuildContext context) {
        return AlertDialog(
            content: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.image,
                  size: 56,
                ),
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                  // snapshot.connectionState = ConnectionState.done;
                },
                tooltip: '相册',
              ),
              IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 56,
                ),
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                  // snapshot.connectionState = ConnectionState.done;
                },
                tooltip: '相机',
              ),
            ],
          ),
        ));
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    ImageSource? imageSource =
        kIsWeb ? ImageSource.gallery : await showAsyncDialog(context);
    if (imageSource == null) {
      return;
    }
    final pickedFile = await picker.pickImage(source: imageSource);

    if (pickedFile != null) {
      // 处理选中的图片
      // value = [pickedFile];
      setState(() {
        value = [pickedFile];
      });

      await _upload(pickedFile);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = TDTheme.of(context);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(
                widget.borderRadius ?? theme.radiusExtraLarge)),
        width: double.infinity,
        height: widget.height ?? 144, // 调整高度
        child: value == null
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_sharp),
                  Visibility(
                      visible: widget.title != '', child: Text(widget.title))
                ],
              ))
            : ClipRRect(
                borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? theme.radiusExtraLarge),
                child: _previewImages()),
      ),
    );
  }

  Widget _previewImages() {
    // final Text? retrieveError = _getRetrieveErrorWidget();
    // if (retrieveError != null) {
    //   return retrieveError;
    // }

    int index = 0;
    var item = value![index];
    bool isNetwork = kIsWeb;
    if (item.runtimeType != XFile) {
      isNetwork = true;
    }
    var url = item.runtimeType == XFile ? item.path : item["url"];

    final String? mime = lookupMimeType(url);
    return Semantics(
      label: 'image_picker_preview',
      child: isNetwork
          ? Image.network(
              url,
              fit: BoxFit.fitWidth,
            )
          : (mime == null || mime.startsWith('image/'))
              ? Image.file(
                  File(url),
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return const Center(
                        child: Text('This image type is not supported'));
                  },
                )
              : const Text('Type not supported'),
    );
  }
}
