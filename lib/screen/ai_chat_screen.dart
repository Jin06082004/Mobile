import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _history = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _history.add(_ChatMessage(message: message, isUser: true));
      _textController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final responseText = await _callOpenAIGPT(message);
      setState(() {
        _history.add(_ChatMessage(message: responseText, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _history.add(
          _ChatMessage(message: 'Đã có lỗi xảy ra: $e', isUser: false),
        );
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  Future<String> _callOpenAIGPT(String userMessage) async {
    final prompt =
        '''
Bạn là trợ lý AI chuyên hỗ trợ đặt khách sạn trong ứng dụng mobile.

Nhiệm vụ của bạn:
- Khi người dùng yêu cầu tìm khách sạn, hãy đề xuất các khách sạn CỤ THỂ
- Trả lời bằng tiếng Việt, giọng thân thiện, dễ hiểu
- Không trả lời chung chung hay chỉ gợi ý website

Với mỗi khách sạn, hãy cung cấp đầy đủ:
- Tên khách sạn
- Khu vực / địa chỉ
- Hạng sao
- Giá tham khảo mỗi đêm
- Tiện ích nổi bật
- Đánh giá trung bình (nếu có)

Nếu người dùng không nói rõ ngân sách hay khu vực, hãy tự đề xuất 3–5 khách sạn phổ biến, phù hợp với đa số du khách.

Câu hỏi của người dùng:
"$userMessage"
''';

    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw 'Lỗi: Không tìm thấy OPENAI_API_KEY trong file .env';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': 512,
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content']?.trim() ??
          'Không có phản hồi từ AI.';
    } else {
      throw 'Lỗi API: ${response.statusCode} - ${response.body}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final chat = _history[index];
                      return _ChatBubble(
                        message: chat.message,
                        isUser: chat.isUser,
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: (_isLoading) ? null : _sendMessage,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String message;
  final bool isUser;
  _ChatMessage({required this.message, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const _ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
