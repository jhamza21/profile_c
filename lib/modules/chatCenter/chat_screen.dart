import 'package:flutter/material.dart';
import 'package:profilecenter/constants/app_constants.dart';
import 'package:profilecenter/models/document.dart';
import 'package:profilecenter/modules/chatCenter/raiting_request.dart';
import 'package:profilecenter/utils/helpers/get_chat_room_name.dart';
import 'package:profilecenter/models/chat_room.dart';
import 'package:profilecenter/models/message.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/providers/message_provider.dart';
import 'package:profilecenter/providers/user_provider.dart';
import 'package:profilecenter/utils/helpers/session_expired.dart';
import 'package:profilecenter/core/services/message_service.dart';
import 'package:profilecenter/modules/chatCenter/msg_with_docs.dart';
import 'package:profilecenter/modules/chatCenter/devis_request.dart';
import 'package:profilecenter/modules/chatCenter/devis_response.dart';
import 'package:profilecenter/modules/chatCenter/pay_proposal_card.dart';
import 'package:profilecenter/modules/chatCenter/pay_request.dart';
import 'package:profilecenter/modules/chatCenter/pay_response.dart';
import 'package:profilecenter/modules/chatCenter/project_proposal_card.dart';
import 'package:profilecenter/modules/chatCenter/project_proposal_response_card.dart';
import 'package:profilecenter/modules/chatCenter/qcm_request_card.dart';
import 'package:profilecenter/modules/chatCenter/qcm_response_card.dart';
import 'package:profilecenter/modules/chatCenter/stripe_subscription_request.dart';
import 'package:profilecenter/modules/chatCenter/supply_request.dart';
import 'package:profilecenter/modules/chatCenter/text_message_card.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chatCeneter';
  final ChatRoom chatRoom;
  ChatScreen(this.chatRoom);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String text = "";
  final textHolder = TextEditingController();
  ScrollController _scrollController = new ScrollController();

  bool _errorMsg = false;

  @override
  void initState() {
    super.initState();
    Provider.of<MessageProvider>(context, listen: false)
        .fetchMessages(widget.chatRoom.id);
  }

  void sendMessage() async {
    try {
      final isValid = validMsg(text);
      if (!isValid) {
        setState(() {
          _errorMsg = true;
        });
        return;
      }
      FocusScope.of(context).requestFocus(FocusNode());
      var res = await MessageService()
          .sendTextMessage(widget.chatRoom.id, null, text);
      if (res.statusCode == 401) return sessionExpired(context);
      if (res.statusCode != 200) throw "ERROR_SERVER";
      textHolder.clear();
    } catch (e) {}
  }

  _builtMessageComposer(
      UserProvider userProvider, MessageProvider messageProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      color: BLUE_LIGHT,
      height: 50.0,
      child: Column(
        children: [
          if (_errorMsg) Text(getTranslate(context, "CHATNUM_INTERDIT")),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: textHolder,
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) {
                    text = val;
                    setState(() {
                      _errorMsg = false;
                    });
                  },
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration.collapsed(
                      hintText: getTranslate(context, "TYPE_MSG"),
                      hintStyle: TextStyle(color: GREY_LIGHt)),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.send),
                  iconSize: 25.0,
                  color: Colors.white,
                  onPressed: text == "" || text == null ? null : sendMessage)
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    MessageProvider messageProvider =
        Provider.of<MessageProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getChatRoomName(userProvider.user.id, widget.chatRoom)),
        backgroundColor: BLUE_LIGHT,
      ),
      body: messageProvider.isError
          ? ErrorScreen()
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(top: 15.0),
                        reverse: true,
                        itemCount: messageProvider.messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          Message _message = messageProvider.messages[index];

                          if (_message.type == TEXT_MSG)
                            return textMessageCard(
                                _message, userProvider, context);
                          else if (_message.type == QCM_REQUEST)
                            return QcmRequestCard(_message, userProvider);
                          else if (_message.type == QCM_RESPONSE)
                            return QcmResponseCard(_message, userProvider);
                          else if (_message.type == CV_DOC) {
                            List<Document> _docs = [_message.document];
                            if (index - 1 != -1 &&
                                messageProvider.messages[index - 1].type ==
                                    COVER_LETTER_DOC)
                              _docs.add(
                                  messageProvider.messages[index - 1].document);
                            return MsgWithDocs(_docs, _message, userProvider);
                          } else if (_message.type == PROJECT_PROPOSAL)
                            return ProjectProposalCard(_message, userProvider);
                          else if (_message.type == PROJECT_PROPOSAL_RESPONSE)
                            return ProjectProposalResponseCard(
                                _message, userProvider);
                          else if (_message.type == DEVIS_REQUEST)
                            return DevisRequest(_message, userProvider);
                          else if (_message.type == DEVIS_RESPONSE)
                            return DevisResponse(_message, userProvider);
                          else if (_message.type == SUPPLY_REQUEST &&
                              userProvider.user.role == COMPANY_ROLE)
                            return SupplyRequest(_message, userProvider);
                          else if (_message.type ==
                                  STRIPE_SUBSCRIPTION_REQUEST &&
                              userProvider.user.role == FREELANCE_ROLE)
                            return StripeSubscriptionRequest(
                                _message, userProvider);
                          else if (_message.type == PAY_PROPOSAL &&
                              userProvider.user.role == FREELANCE_ROLE &&
                              _message.response == null)
                            return PayProposalCard(_message, userProvider);
                          else if (_message.type == PAY_REQUEST)
                            return PayRequest(_message, userProvider);
                          else if (_message.type == PAY_RESPONSE)
                            return PayResponse(_message, userProvider);
                          else if (_message.type == RAITING_REQUEST)
                            return RaitingRequestCard(_message, userProvider);
                          return SizedBox.shrink();
                        }),
                  ),
                  SizedBox(height: 10.0),
                  _builtMessageComposer(userProvider, messageProvider),
                ],
              ),
            ),
    );
  }
}

bool validMsg(String text) {
  if (text.contains(new RegExp(r'[0-9]'))) return false;
  if (text.contains('@')) return false;
  return true;
}
