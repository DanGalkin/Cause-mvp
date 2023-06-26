import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmogiPickerDialog extends StatelessWidget {
  const EmogiPickerDialog({required this.onEmojiSelected, super.key});
  final void Function(Emoji emoji) onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 250,
        width: 320,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            onEmojiSelected(emoji);
            Navigator.of(context).pop();
          },
          //textEditingController: _iconController,
          config: const Config(
            columns: 7,
            emojiSizeMax: 32,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            bgColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            backspaceColor: Colors.blue,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            recentTabBehavior: RecentTabBehavior.RECENT,
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: false,
            noRecents: Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
            //loadingIndicator: const SizedBox.shrink(),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
            //checkPlatformCompatibility: true,
          ),
        ),
      ),
    );
  }
}
