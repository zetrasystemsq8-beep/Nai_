import '../domain/help_topic.dart';

class ZetraHelpContent {
  static const List<HelpSection> sections = [
    HelpSection(
      productName: 'NAI',
      description: "Nigeria's AI Assistant",
      topics: [
        HelpTopic(
          title: 'Creating a Zetra ID',
          content:
              'Open NAI and tap "Continue", then tap "Create Zetra ID". Enter your full name, ZetraMail address, and password to create your universal Zetra account. If you already have one, tap "Sign In".',
        ),
        HelpTopic(
          title: 'Signing in',
          content:
              'Use your ZetraMail address and password to sign in. Your Zetra ID works across all Zetra applications including NAI, ZetraMail, NigerGram, and future Zetra services.',
        ),
        HelpTopic(
          title: 'Chatting with NAI',
          content:
              'Open the Chat tab and ask any question. NAI can answer general questions, programming topics, mathematics, Nigerian topics, science, history, and much more.',
        ),
        HelpTopic(
          title: "Today's Briefing",
          content:
              "The News tab shows a short AI-written summary of today's top Nigerian stories, refreshed every day together with the latest headlines.",
        ),
        HelpTopic(
          title: 'Challenges',
          content:
              'Complete daily challenges to earn ZTC coins. Maintain your streak to unlock bonus rewards and compete on the leaderboard.',
        ),
        HelpTopic(
          title: 'History',
          content:
              'Every conversation is saved automatically. Open the History tab to continue previous chats or delete conversations you no longer need.',
        ),
        HelpTopic(
          title: 'Voice Chat',
          content:
              'Tap the microphone icon to speak with NAI instead of typing.',
        ),
        HelpTopic(
          title: 'Image Analysis',
          content:
              'Upload an image and ask NAI questions about it, extract text, or request explanations.',
        ),
        HelpTopic(
          title: 'Documents',
          content:
              'Upload supported documents and ask NAI to summarize or explain their contents.',
        ),
        HelpTopic(
          title: 'Settings',
          content:
              'Customize the appearance, language, notifications, AI preferences, and other options from the Settings page.',
        ),
        HelpTopic(
          title: 'Clear Chat History',
          content:
              'Use Settings > Clear Chat History to permanently remove conversations stored on your device.',
        ),
        HelpTopic(
          title: 'Report a Problem',
          content:
              'If you discover a bug or unexpected behavior, contact Zetra Systems support and include as much detail as possible.',
        ),
      ],
    ),
    HelpSection(
      productName: 'NigerGram',
      description: "Zetra's social platform",
      topics: [
        HelpTopic(
          title: 'Creating an account',
          content:
              'Sign in with your Zetra ID or create one if you do not already have an account.',
        ),
        HelpTopic(
          title: 'Uploading videos',
          content:
              'Tap the Create button, select or record a video, add a caption and hashtags, then publish it.',
        ),
        HelpTopic(
          title: 'Wallet',
          content:
              'Your wallet stores ZTC earned from gifts, challenges, and other rewards.',
        ),
        HelpTopic(
          title: 'Withdraw earnings',
          content:
              'Open Wallet, choose Withdraw, enter your payout information, and confirm the transaction.',
        ),
        HelpTopic(
          title: 'Creator Account',
          content:
              'Switch to a Creator Account to unlock analytics, monetization tools, and creator features.',
        ),
        HelpTopic(
          title: 'Verification',
          content:
              'Verify your identity using Zetra ID to improve account security and unlock additional features.',
        ),
      ],
    ),
    HelpSection(
      productName: 'ZetraMail',
      description: 'Universal mail service',
      topics: [
        HelpTopic(
          title: 'What is ZetraMail?',
          content:
              'ZetraMail is your universal email for the Zetra ecosystem. Use it to sign in to every Zetra application.',
        ),
        HelpTopic(
          title: 'Security',
          content:
              'Protect your account with a strong password and never share your login credentials with anyone.',
        ),
      ],
    ),
  ];
}
