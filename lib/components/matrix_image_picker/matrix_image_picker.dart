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
  const MatrixImagePicker(
      {super.key,
      this.initialValue,
      this.onChanged,
      required this.title,
      this.additionInfo,
      this.limit = 9,
      this.size = TDTagSize.extraLarge,
      this.multiple = false});

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
        await dio.post('http://127.0.0.1:7001/generatePresignedUrl',
            data: jsonEncode({'fileName': pickedFile.name}),
            options: Options(headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            }));
    var generateResponseData = generateResponse.data;

    // 读取文件为字节流
    Uint8List fileBytes = await pickedFile.readAsBytes();
    String fileName = pickedFile.name; // 通过 XFile 获取文件名

    // 构建 FormData
    FormData formData = FormData.fromMap({
      "fileInfo": MultipartFile.fromBytes(fileBytes, filename: fileName),
    });

    final uploadDio = Dio();
    uploadDio.options.connectTimeout = Duration(seconds: 10);
    uploadDio.options.sendTimeout = Duration(seconds: 10);
    // var fileData = MultipartFile.fromBytes(fileBytes);
    // FormData body = FormData.fromMap({});
    // body.files.add(MapEntry("image", fileData));
    var uploadResponse =
        await uploadDio.post(generateResponseData["data"]['uploadUrl'],
            // data: FormData.fromMap({
            //   'image': fileData,
            // }),
            data: formData,
            options: Options(headers: {
              HttpHeaders.contentTypeHeader: pickedFile.mimeType,
            }));

    setState(() {
      value = [
        {
          "url": uploadResponse.data['data']['url'],
          "fileCode": generateResponseData["data"]['fileCode'],
          "fileName": fileName,
        }
      ];
      widget.onChanged!(value!);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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
            borderRadius: BorderRadius.circular(theme.radiusDefault)),
        margin: const EdgeInsets.symmetric(horizontal: 16)
            .add(const EdgeInsets.only(top: 20.0)),
        width: double.infinity,
        height: 100, // 调整高度
        child: Center(
          child: value == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text('请上传游戏主页截图'),
                  ],
                )
              : _previewImages(),
        ),
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

    var url = item.runtimeType == XFile ? item.path : item["url"];

    final String? mime = lookupMimeType(url);
    return Semantics(
      label: 'image_picker_preview',
      child: kIsWeb
          ? Image.network(url)
          : (mime == null || mime.startsWith('image/'))
              ? Image.file(
                  File(value![index].path),
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
