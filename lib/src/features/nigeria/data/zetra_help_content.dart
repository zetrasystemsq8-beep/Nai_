import '../domain/help_topic.dart';

class ZetraHelpContent {
  static const List<HelpSection> sections = [
    HelpSection(
      productName: 'NAI',
      description: "Nigeria's AI Assistant",
      topics: [
        HelpTopic(
          title: 'Creating an account',
          content:
              'Open NAI and tap "Continue" on the welcome screen, then "Create NAI Account" to sign up with your name, ZetraMail, and password. If you already have an account, tap "Sign In" instead.',
        ),
        HelpTopic(
          title: 'Chatting with NAI',
          content:
              'Go to the Chat tab and type any question — general knowledge, coding help, or anything about Nigeria. NAI searches real Nigerian news and Wikipedia sources when relevant, then answers in its own words.',
        ),
        HelpTopic(
          title: "Today's Briefing",
          content:
              'The News tab shows a short AI-written summary of today\\'s top Nigerian stories, refreshed once daily, along with the latest headlines below it.',
        ),
        HelpTopic(
          title: 'Viewing past conversations',
          content:
              'The History tab saves every conversation automatically. Tap any past chat to reopen it, or swipe left on a conversation to delete it.',
        ),
        HelpTopic(
          title: 'Clearing your data',
          content:
              'Go to Settings > Clear Chat History to permanently delete all saved conversations from your device.',
        ),
        HelpTopic(
          title: 'Reporting a bug',
          content:
              'Found something broken? Contact Zetra Systems support through the details below, and describe what happened and what you expected instead.',
        ),
      ],
    ),
    HelpSection(
      productName: 'Nigergram',
      description: "Zetra's social platform",
      topics: [
        HelpTopic(
          title: 'Creating an account',
          content:
              'Download Nigergram and sign up with your ZetraMail or phone number, then verify your account to get started.',
        ),
        HelpTopic(
          title: 'Withdrawing your coins to cash',
          content:
              'Go to your wallet, select "Withdraw," choose your payout method, and follow the on-screen steps to convert your coins to real money.',
        ),
        HelpTopic(
          title: 'Becoming a creator',
          content:
              'Go to your profile settings and select "Switch to Creator Account" to unlock creator tools and monetization features.',
        ),
      ],
    ),
  ];
}
